
/*
     File: MotionSynchronizer.m
 Abstract: Sychronizes motion samples with video samples
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "MotionSynchronizer.h"
#import <CoreMotion/CoreMotion.h>

#define MOTION_DEFAULT_SAMPLES_PER_SECOND 60
#define VIDEO_ARRAY_SIZE 10
#define MOTION_ARRAY_SIZE 60

@interface MotionSynchronizer () {
	id<MotionSynchronizationDelegate> delegate;
	dispatch_queue_t clientQueue;
}

@property(nonatomic, retain) __attribute__((NSObject)) CMClockRef motionSampleClock;
@property(nonatomic, retain) NSOperationQueue *motionQueue;
@property(nonatomic, retain) CMMotionManager *motionManager;
@property(nonatomic, retain) NSMutableArray *videoSamples;
@property(nonatomic, retain) NSMutableArray *motionSamples;

- (void)appendMotionForSynchronization:(CMDeviceMotion*)motion;

@end

@implementation MotionSynchronizer

- (id)init
{
    self = [super init];
    if (self != nil) {
		
		[self setVideoSamples:[NSMutableArray arrayWithCapacity:VIDEO_ARRAY_SIZE]];
		[self setMotionSamples:[NSMutableArray arrayWithCapacity:MOTION_ARRAY_SIZE]];
		
		NSOperationQueue *motionQueue = [[NSOperationQueue alloc] init];
		[motionQueue setMaxConcurrentOperationCount:1]; // Make serial
		[self setMotionQueue:motionQueue];
		[motionQueue release];
		
		CMMotionManager *motionManager = [[CMMotionManager alloc] init];
		[self setMotionManager:motionManager];
		[self setMotionRate:MOTION_DEFAULT_SAMPLES_PER_SECOND];
		[motionManager release];
		
		// CoreMotion operates on the host time clock
		[self setMotionSampleClock:CMClockGetHostTimeClock()];
	}
	
	return self;
}

- (void)dealloc
{
	[[self motionManager] stopDeviceMotionUpdates];
	[self setMotionManager:nil];
	[self setMotionQueue:nil];
	[self setMotionSamples:nil];
	[self setVideoSamples:nil];
	[self setSampleBufferClock:NULL];
	[self setMotionSampleClock:NULL];
	
	[super dealloc];
}

- (void)start
{
	if ( self.sampleBufferClock == NULL ) {
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"No sampleBufferClock. Please set one before calling start." userInfo:nil];
		return;
	}
	
	if ( [[self motionManager] isDeviceMotionAvailable] ) {
		CMDeviceMotionHandler motionHandler = ^(CMDeviceMotion *motion, NSError *error) {
			if ( !error ) {
				[self appendMotionForSynchronization:motion];
			}
			else {
				NSLog(@"%@", error);
			}
		};

		[[self motionManager] startDeviceMotionUpdatesToQueue:[self motionQueue] withHandler:motionHandler];
	}
}

- (void)stop
{
    if ([[self motionManager] isDeviceMotionActive]) {
        [[self motionManager] stopDeviceMotionUpdates];
	}
}

- (int)motionRate
{
	int motionHz = 1.0 / [[self motionManager] deviceMotionUpdateInterval];
	return motionHz;
}

- (void)setMotionRate:(int)motionRate
{
	NSTimeInterval updateIntervalSeconds = 1.0 / motionRate;
	[[self motionManager] setDeviceMotionUpdateInterval:updateIntervalSeconds];
}

- (void)sync
{
	for ( int videoIndex = 0; videoIndex < [[self videoSamples] count]; videoIndex++ ) {
		
		CMSampleBufferRef sampleBuffer = (CMSampleBufferRef)[[self videoSamples] objectAtIndex:videoIndex];
		
		CFDictionaryRef remappedPTSDict = CMGetAttachment(sampleBuffer, CFSTR("RemappedPTS"), NULL);
		CMTime remappedPTS = CMTimeMakeFromDictionary(remappedPTSDict);

		double videoTimeSeconds = CMTimeGetSeconds(remappedPTS);
		double motionTimeSeconds = [[[self motionSamples] objectAtIndex:0] timestamp];
		double closestDifference = fabs(videoTimeSeconds - motionTimeSeconds);
		int closestIndex = 0;
		
		for ( int motionIndex = 1; motionIndex < [[self motionSamples] count]; motionIndex++ ) {
			
			motionTimeSeconds = [[[self motionSamples] objectAtIndex:motionIndex] timestamp];
			double difference = videoTimeSeconds - motionTimeSeconds;
			
			if ( fabs(difference) > fabs(closestDifference)
				|| (( motionIndex == [[self motionSamples] count] - 1) && [[self videoSamples] count] > VIDEO_ARRAY_SIZE ) ) // Don't hold onto too many video samples
			{
				CMSetAttachment(sampleBuffer, CFSTR("DeviceMotion"), [[self motionSamples] objectAtIndex:closestIndex], kCMAttachmentMode_ShouldPropagate);
				CFRetain(sampleBuffer);
				dispatch_async(clientQueue, ^{
					if ( [delegate respondsToSelector:@selector(motionManager:didOutputSampleBuffer:)] )
						[delegate motionManager:self didOutputSampleBuffer:sampleBuffer];
					CFRelease(sampleBuffer);
				});
				
				[[self videoSamples] removeObjectAtIndex:videoIndex];
				videoIndex--;
				
				break;
			}
			else {
				closestDifference = difference;
				closestIndex = motionIndex;
			}
		}
		
		[[self motionSamples] removeObjectsInRange:NSMakeRange(0, closestIndex)]; // Remove motion samples older than the closest
		
		if ( [[self motionSamples] count] > MOTION_ARRAY_SIZE ) {
			[[self motionSamples] removeObjectsInRange:NSMakeRange(0, [[self motionSamples] count] - MOTION_ARRAY_SIZE)]; // Don't hold onto too many motion samples
		}
	}
}

- (void)appendMotionForSynchronization:(CMDeviceMotion*)motion
{
	@synchronized(self) {
		[[self motionSamples] addObject:motion];
		
		[self sync];
	}
}

- (void)appendSampleBufferForSynchronization:(CMSampleBufferRef)sampleBuffer
{
	// We remap into the motion clock so that we can compare timestamps from the sample buffers and core motion samples directly.
	CMTime originalPTS = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
	CMTime remappedPTS = CMSyncConvertTime(originalPTS, self.sampleBufferClock, self.motionSampleClock);
	CFDictionaryRef remappedPTSDict = CMTimeCopyAsDictionary(remappedPTS, kCFAllocatorDefault);
	CMSetAttachment(sampleBuffer, CFSTR("RemappedPTS"), remappedPTSDict, kCMAttachmentMode_ShouldPropagate);
	CFRelease(remappedPTSDict);
	
	@synchronized(self) {
		
		[[self videoSamples] addObject:(id)sampleBuffer];
		
		[self sync];
	}
}

- (void)setSynchronizedSampleBufferDelegate:(id<MotionSynchronizationDelegate>)sampleBufferDelegate queue:(dispatch_queue_t)sampleBufferCallbackQueue;
{
	delegate = sampleBufferDelegate;
	
	if ( sampleBufferCallbackQueue != clientQueue ) {
		dispatch_queue_t oldQueue = clientQueue;
		clientQueue = sampleBufferCallbackQueue;
		
		if (sampleBufferCallbackQueue)
			dispatch_retain(sampleBufferCallbackQueue);
		if (oldQueue)
			dispatch_release(oldQueue);
	}
}

@end
