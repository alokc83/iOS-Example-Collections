
/*
     File: VideoSnakeSessionManager.m
 Abstract: The class that creates and manages the AVCaptureSession
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

#import "VideoSnakeSessionManager.h"

#import "MovieRecorder.h"
#import "MotionSynchronizer.h"

#import <CoreMedia/CMBufferQueue.h>
#import <CoreMedia/CMAudioClock.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/CGImageProperties.h>

#include <objc/runtime.h> // for objc_loadWeak() and objc_storeWeak()

#define BYTES_PER_PIXEL 4
#define POOL_MAX_BUFFER_COUNT 6

enum {
	VideoSnakeSessionManagerStatusIdle = 0,
	VideoSnakeSessionManagerStatusStartingRecording,
	VideoSnakeSessionManagerStatusRecording,
	VideoSnakeSessionManagerStatusStoppingRecording,
};
typedef NSInteger VideoSnakeSessionManagerStatus; // internal state machine

@interface VideoSnakeSessionManager () <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, MovieRecorderDelegate, MotionSynchronizationDelegate>
{	
	VideoSnakeSessionManagerStatus _status;
	
	__weak id <VideoSnakeSessionManagerDelegate> _delegate; // __weak doesn't actually do anything under non-ARC
	dispatch_queue_t _delegateCallbackQueue;
	
	NSMutableArray *_previousSecondTimestamps;
	Float64 _videoFrameRate;
	CMVideoDimensions _videoDimensions;
	CMVideoCodecType _videoType;
	
	AVCaptureSession *_captureSession;
	AVCaptureConnection *_audioConnection;
	AVCaptureConnection *_videoConnection;
	CMBufferQueueRef _previewBufferQueue;
	
	NSURL *_movieURL;
	
	AVCaptureVideoOrientation _referenceOrientation;
	AVCaptureVideoOrientation _videoOrientation;
	
	MotionSynchronizer *_motionSynchronizer;
	dispatch_queue_t _motionSynchronizationQueue;
	
	CMFormatDescriptionRef _videoFormatDescription;
	CMFormatDescriptionRef _audioFormatDescription;
	
	MovieRecorder *_recorder;
	
	CVPixelBufferPoolRef _outputBufferPool;
	CFDictionaryRef _outputBufferPoolAuxAttributes;
	CVPixelBufferRef _lastRenderPixelBuffer;
	CMTime _lastRenderPixelBufferTime;
}

// Redeclared as readwrite so that we can write to the property and still be atomic with external readers.
@property (readwrite) Float64 videoFrameRate;
@property (readwrite) CMVideoDimensions videoDimensions;
@property (readwrite) CMVideoCodecType videoType;

@property (readwrite) AVCaptureVideoOrientation videoOrientation;

@property(retain) MotionSynchronizer *motionSynchronizer;

@property (retain) __attribute__((NSObject)) CMFormatDescriptionRef videoFormatDescription;
@property (retain) __attribute__((NSObject)) CMFormatDescriptionRef audioFormatDescription;

@property (nonatomic, retain) MovieRecorder *recorder;

@end

@implementation VideoSnakeSessionManager

@synthesize videoFrameRate = _videoFrameRate;
@synthesize videoDimensions = _videoDimensions;
@synthesize videoType = _videoType;
@synthesize referenceOrientation = _referenceOrientation;
@synthesize videoOrientation = _videoOrientation;

@synthesize motionSynchronizer = _motionSynchronizer;

@synthesize videoFormatDescription = _videoFormatDescription;
@synthesize audioFormatDescription = _audioFormatDescription;
@synthesize recorder = _recorder;

- (id)init
{
	if (self = [super init]) {
		_previousSecondTimestamps = [[NSMutableArray alloc] init];
		_referenceOrientation = UIDeviceOrientationPortrait;
		
		// The temporary path for the video before saving it to the photo album
		_movieURL = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"Movie.MOV"]];
	}
	return self;
}

- (void)dealloc 
{
	objc_storeWeak( &_delegate, nil ); // unregister _delegate as a weak reference
	
	if ( _delegateCallbackQueue )
		dispatch_release( _delegateCallbackQueue );
	
	[_previousSecondTimestamps release];
	[_movieURL release];
	
	[_captureSession release];
	
	if (_previewBufferQueue)
		CFRelease(_previewBufferQueue);
	
	[_motionSynchronizer release];
	
	if ( _motionSynchronizationQueue )
		dispatch_release( _motionSynchronizationQueue );
	
	if ( _videoFormatDescription )
		CFRelease( _videoFormatDescription );
	
	if ( _audioFormatDescription )
		CFRelease( _audioFormatDescription );
	
	[_recorder release];
	
	if ( _outputBufferPool )
		CFRelease( _outputBufferPool );
	
	if ( _outputBufferPoolAuxAttributes )
		CFRelease( _outputBufferPoolAuxAttributes );
	
	if ( _lastRenderPixelBuffer )
		CFRelease( _lastRenderPixelBuffer );
	
	[super dealloc];
}

- (id<VideoSnakeSessionManagerDelegate>)_delegate
{
	id <VideoSnakeSessionManagerDelegate> delegate = nil;
	@synchronized( self ) {
		delegate = objc_loadWeak( &_delegate ); // unnecessary under ARC, just assign delegate to _delegate directly
	}
	return delegate;
}

- (void)setDelegate:(id<VideoSnakeSessionManagerDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue; // delegate is weak referenced
{
	if ( delegate && ( delegateCallbackQueue == NULL ) )
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Caller must provide a delegateCallbackQueue" userInfo:nil];
	
	@synchronized( self ) {
		objc_storeWeak( &_delegate, delegate ); // unnecessary under ARC, just assign to _delegate directly
		if ( delegateCallbackQueue != _delegateCallbackQueue  ) {
			if ( delegateCallbackQueue )
				dispatch_retain( delegateCallbackQueue );
			if ( _delegateCallbackQueue )
				dispatch_release( _delegateCallbackQueue );
			_delegateCallbackQueue = delegateCallbackQueue;
		}
	}
}

#pragma mark Utilities

- (void)calculateFramerateAtTimestamp:(CMTime) timestamp
{
	[_previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];
	
	CMTime oneSecond = CMTimeMake( 1, 1 );
	CMTime oneSecondAgo = CMTimeSubtract( timestamp, oneSecond );
	
	while( CMTIME_COMPARE_INLINE( [[_previousSecondTimestamps objectAtIndex:0] CMTimeValue], <, oneSecondAgo ) )
		[_previousSecondTimestamps removeObjectAtIndex:0];
	
	Float64 newRate = (Float64) [_previousSecondTimestamps count];
	self.videoFrameRate = (self.videoFrameRate + newRate) / 2;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGFloat angle = 0.0;
	
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			angle = 0.0;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			angle = -M_PI_2;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			angle = M_PI_2;
			break;
		default:
			break;
	}

	return angle;
}

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGAffineTransform transform = CGAffineTransformIdentity;

	// Calculate offsets from an arbitrary reference orientation (portrait)
	CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
	CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.videoOrientation];
	
	// Find the difference in angle between the passed in orientation and the current video orientation
	CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
	transform = CGAffineTransformMakeRotation(angleOffset);
	
	return transform;
}

static CVPixelBufferPoolRef CreatePixelBufferPool( int32_t width, int32_t height, OSType pixelFormat, int32_t maxBuferCount )
{
	CVPixelBufferPoolRef outputPool = NULL;
	
    CFMutableDictionaryRef sourcePixelBufferOptions = CFDictionaryCreateMutable( kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
    CFNumberRef number = CFNumberCreate( kCFAllocatorDefault, kCFNumberSInt32Type, &pixelFormat );
    CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelBufferPixelFormatTypeKey, number );
    CFRelease( number );
    
    number = CFNumberCreate( kCFAllocatorDefault, kCFNumberSInt32Type, &width );
    CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelBufferWidthKey, number );
    CFRelease( number );
    
    number = CFNumberCreate( kCFAllocatorDefault, kCFNumberSInt32Type, &height );
    CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelBufferHeightKey, number );
    CFRelease( number );
    
    CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelFormatOpenGLESCompatibility, kCFBooleanTrue );
    
    CFDictionaryRef ioSurfaceProps = CFDictionaryCreate( kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
    if (ioSurfaceProps) {
        CFDictionaryAddValue( sourcePixelBufferOptions, kCVPixelBufferIOSurfacePropertiesKey, ioSurfaceProps );
        CFRelease(ioSurfaceProps);
    }
    
	number = CFNumberCreate( kCFAllocatorDefault, kCFNumberSInt32Type, &maxBuferCount );
	CFDictionaryRef pixelBufferPoolOptions = CFDictionaryCreate( kCFAllocatorDefault, (const void**)&kCVPixelBufferPoolMinimumBufferCountKey, (const void**)&number, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
	CFRelease( number );
	
    CVPixelBufferPoolCreate( kCFAllocatorDefault, pixelBufferPoolOptions, sourcePixelBufferOptions, &outputPool );
    
    CFRelease( sourcePixelBufferOptions );
	CFRelease( pixelBufferPoolOptions );
	
	return outputPool;
}

static CFDictionaryRef CreatePixelBufferPoolAuxAttributes( int32_t maxBufferCount )
{
	// CVPixelBufferPoolCreatePixelBufferWithAuxAttributes() will return kCVReturnWouldExceedAllocationThreshold if we have already vended the max number of buffers
	NSDictionary *auxAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:maxBufferCount], (id)kCVPixelBufferPoolAllocationThresholdKey, nil];
	return (CFDictionaryRef)auxAttributes;
}

static void PreallocatePixelBuffersInPool( CVPixelBufferPoolRef pool, CFDictionaryRef auxAttributes )
{
	// Preallocate buffers in the pool, since this is for real-time display/capture
	NSMutableArray *pixelBuffers = [[NSMutableArray alloc] init];
	while ( 1 ) {
		CVPixelBufferRef pixelBuffer = NULL;
		OSStatus err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, pool, auxAttributes, &pixelBuffer );
		
		if ( err == kCVReturnWouldExceedAllocationThreshold )
			break;
		assert( err == noErr );
		
		[pixelBuffers addObject:(id)pixelBuffer];
		CFRelease( pixelBuffer );
	}
	[pixelBuffers release];	
}

#pragma mark Recording

- (void)startRecording
{
	@synchronized( self ) {
		if ( _status != VideoSnakeSessionManagerStatusIdle ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already recording" userInfo:nil];
			return;
		}
		
		[self _transitionToStatus:VideoSnakeSessionManagerStatusStartingRecording error:nil];
	}

	// Create an movie recorder
	MovieRecorder *recorder = [[[MovieRecorder alloc] init] autorelease];
	
	[recorder addAudioTrackWithSourceFormatDescription:self.audioFormatDescription]; // Some day maybe we could actually get this from the capture session :(

	CGAffineTransform videoTransform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
	[recorder addVideoTrackWithSourceFormatDescription:self.videoFormatDescription transform:videoTransform];
	
	dispatch_queue_t callbackQueue = dispatch_queue_create( "MovieRecorder delegate callback queue", DISPATCH_QUEUE_SERIAL ); // guarantee ordering of callbacks with a serial queue
	[recorder setDelegate:self callbackQueue:callbackQueue];
	dispatch_release( callbackQueue );
	self.recorder = recorder;
	
	[recorder prepareToRecordToURL:_movieURL]; // asynchronous, will call us back with recorderDidFinishPreparing: or recorder:didFailWithError: when done
}

- (void)stopRecording
{
	@synchronized( self ) {
		if ( _status != VideoSnakeSessionManagerStatusRecording ) {
//			NSLog( @"-[%@ %@]: state is %@, nothing to do", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [self _stringForStatus:_status] );
			return;
		}
		
		[self _transitionToStatus:VideoSnakeSessionManagerStatusStoppingRecording error:nil];
	}
	
	[self.recorder finishRecording]; // asynchronous, will call us back with recorderDidFinishRecording: or recorder:didFailWithError: when done
}

#pragma mark MovieRecorder Delegate

- (void)recorderDidFinishPreparingToRecord:(MovieRecorder*)recorder
{
	@synchronized( self ) {
		if ( _status != VideoSnakeSessionManagerStatusStartingRecording ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StartingRecording state" userInfo:nil];
			return;
		}
		
		[self _transitionToStatus:VideoSnakeSessionManagerStatusRecording error:nil];
	}
}

- (void)recorder:(MovieRecorder*)recorder didFailWithError:(NSError*)error
{
	@synchronized( self ) {
		[self _transitionToStatus:VideoSnakeSessionManagerStatusIdle error:error];
	}
}

- (void)recorderDidFinishRecording:(MovieRecorder*)recorder
{
	@synchronized( self ) {
		if ( _status != VideoSnakeSessionManagerStatusStoppingRecording ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StoppingRecording state" userInfo:nil];
			return;
		}
		
		// No state transition, we are still in the process of stopping.
		// We will be stopped once we save to the assets library.
	}
	
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library writeVideoAtPathToSavedPhotosAlbum:_movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
		
		[[NSFileManager defaultManager] removeItemAtURL:_movieURL error:NULL];
		
		@synchronized( self ) {
			if ( _status != VideoSnakeSessionManagerStatusStoppingRecording ) {
				@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StoppingRecording state" userInfo:nil];
				return;
			}
			[self _transitionToStatus:VideoSnakeSessionManagerStatusIdle error:error];
		}
	}];
	[library release];
}

#pragma mark State Machine

// debugging/logging only
- (NSString*)_stringForStatus:(VideoSnakeSessionManagerStatus)status
{
	NSString *statusString = nil;
		
	switch ( status ) {
		case VideoSnakeSessionManagerStatusIdle:
			statusString = @"Idle";
			break;
		case VideoSnakeSessionManagerStatusStartingRecording:
			statusString = @"StartingRecording";
			break;
		case VideoSnakeSessionManagerStatusRecording:
			statusString = @"Recording";
			break;
		case VideoSnakeSessionManagerStatusStoppingRecording:
			statusString = @"StoppingRecording";
			break;
		default:
			statusString = @"Unknown";
			break;
	}
	return statusString;
	
}

// call under @synchonized( self )
- (void)_transitionToStatus:(VideoSnakeSessionManagerStatus)newStatus error:(NSError*)error
{
	SEL delegateSelector = NULL;
	VideoSnakeSessionManagerStatus oldStatus = _status;
	_status = newStatus;
	
//	NSLog( @"VideoSnakeSessionManager state transition: %@->%@", [self _stringForStatus:oldStatus], [self _stringForStatus:newStatus] );
	
	if ( newStatus != oldStatus ) {		
		if ( newStatus == VideoSnakeSessionManagerStatusIdle ) {
			// no need to flush our video/audio queues because the appends are synchronized with state transitions
			self.recorder = nil; // Won't be needing the recorder anymore
		}
		
		if ( error && ( newStatus == VideoSnakeSessionManagerStatusIdle ) )
			delegateSelector = @selector(recordingDidFailWithError:);
		else {
			error = nil; // only the above delegate method takes an error
			if ( ( oldStatus == VideoSnakeSessionManagerStatusStartingRecording ) && ( newStatus == VideoSnakeSessionManagerStatusRecording ) )
				delegateSelector = @selector(recordingDidStart);
			else if ( ( oldStatus == VideoSnakeSessionManagerStatusRecording ) && ( newStatus == VideoSnakeSessionManagerStatusStoppingRecording ) )
				delegateSelector = @selector(recordingWillStop);
			else if ( ( oldStatus == VideoSnakeSessionManagerStatusStoppingRecording ) && ( newStatus == VideoSnakeSessionManagerStatusIdle ) )
				delegateSelector = @selector(recordingDidStop);
		}
	}
	
	if ( delegateSelector && [self _delegate] ) {
		dispatch_async( _delegateCallbackQueue, ^{
			@autoreleasepool {
				if ( error )
					[[self _delegate] performSelector:delegateSelector withObject:error];
				else
					[[self _delegate] performSelector:delegateSelector];
			}
		});
	}

}

#pragma mark Capture

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection 
{
	CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
	
	if ( connection == _videoConnection ) {
		[self.motionSynchronizer appendSampleBufferForSynchronization:sampleBuffer];
	}
	else if ( connection == _audioConnection ) {
		self.audioFormatDescription = formatDescription;
		@synchronized( self ) {
			if ( _status == VideoSnakeSessionManagerStatusRecording ) {
				[self.recorder appendAudioSampleBuffer:sampleBuffer];
			}
		}
	}
}

- (void)appendPixelBuffer:(CVImageBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime
{
	CMSampleBufferRef sampleBuffer = NULL;
	
	CMSampleTimingInfo timingInfo = {0,};
	timingInfo.duration = kCMTimeInvalid;
	timingInfo.decodeTimeStamp = kCMTimeInvalid;
	timingInfo.presentationTimeStamp = presentationTime;
	
	CMSampleBufferCreateForImageBuffer( kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, self.videoFormatDescription, &timingInfo, &sampleBuffer );
	[self.recorder appendVideoSampleBuffer:sampleBuffer];
	CFRelease( sampleBuffer );
}

- (void)setupVideoPipelineForSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
	
	self.videoDimensions = CMVideoFormatDescriptionGetDimensions( formatDescription );
	
	if ( _outputBufferPool )
		CFRelease( _outputBufferPool );
	_outputBufferPool = CreatePixelBufferPool( self.videoDimensions.width, self.videoDimensions.height, kCVPixelFormatType_32BGRA, POOL_MAX_BUFFER_COUNT );
	if ( _outputBufferPoolAuxAttributes )
		CFRelease( _outputBufferPoolAuxAttributes );
	_outputBufferPoolAuxAttributes = CreatePixelBufferPoolAuxAttributes( POOL_MAX_BUFFER_COUNT );
	
	PreallocatePixelBuffersInPool( _outputBufferPool, _outputBufferPoolAuxAttributes );
	
	CMFormatDescriptionRef outputFormatDescrition = NULL;
	CVPixelBufferRef testPixelBuffer = NULL;
	CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, _outputBufferPool, _outputBufferPoolAuxAttributes, &testPixelBuffer );
	CMVideoFormatDescriptionCreateForImageBuffer( kCFAllocatorDefault, testPixelBuffer, &outputFormatDescrition );
	self.videoFormatDescription = outputFormatDescrition; // used to tell the MovieRecorder what format we will be feeding it
	CFRelease( outputFormatDescrition );
	CFRelease( testPixelBuffer );
	
	float focalLenIn35mmFilm = 35.;
	CFDictionaryRef exifAttachments = CMGetAttachment( sampleBuffer, kCGImagePropertyExifDictionary, NULL );
	if ( exifAttachments ) {
		CFNumberRef focalLenIn35Number = CFDictionaryGetValue( exifAttachments, kCGImagePropertyExifFocalLenIn35mmFilm );
		if ( focalLenIn35Number ) {
			CFNumberGetValue( focalLenIn35Number, kCFNumberFloatType, &focalLenIn35mmFilm );
		}
	}
	
	@synchronized( self ) { // make sure _delegateCallbackQueue is valid
		dispatch_async( _delegateCallbackQueue, ^{
			[[self _delegate] setDimensions:self.videoDimensions focalLenIn35mmFilm:focalLenIn35mmFilm];
		});
	}	
}

- (void)motionManager:(MotionSynchronizer *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{	
	// Get framerate
	CMTime timestamp = CMSampleBufferGetPresentationTimeStamp( sampleBuffer );
	[self calculateFramerateAtTimestamp:timestamp];
	
	// Get frame dimensions and format description
	if ( ( self.videoDimensions.width == 0 ) && ( self.videoDimensions.height == 0 ) ) {
		[self setupVideoPipelineForSampleBuffer:sampleBuffer];
	}
	
	CMDeviceMotion *motion = (CMDeviceMotion*)CMGetAttachment(sampleBuffer, CFSTR("DeviceMotion"), NULL);
	CVImageBufferRef sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	
	CFRetain( sourcePixelBuffer );
	@synchronized( self ) {
		id <VideoSnakeSessionManagerDelegate> delegate = [self _delegate];
		dispatch_async( _delegateCallbackQueue, ^{
			CVPixelBufferRef dstPixelBuffer = NULL;
			OSStatus err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes( kCFAllocatorDefault, _outputBufferPool, _outputBufferPoolAuxAttributes, &dstPixelBuffer );
			if ( err == kCVReturnWouldExceedAllocationThreshold ) {
				NSLog(@"Pool is out of buffers, dropping frame");
				CFRelease( sourcePixelBuffer );
				return;
			}
			else {
				NSAssert1( ( err == noErr ), @"Error creating pixel buffer (%i)", (int)err );
			}
			
			// We pipeline the CPU and GPU work to improve performance.
			// The GPU is allowed to work on the previous frame until now.
			// If it is able to keep up with real-time then the finishRenderingPixelBuffer call should be non-blocking.
			if ( _lastRenderPixelBuffer ) {
				[delegate finishRenderingPixelBuffer];
				@synchronized( self ) {
					if ( _status == VideoSnakeSessionManagerStatusRecording ) {
						[self appendPixelBuffer:_lastRenderPixelBuffer withPresentationTime:_lastRenderPixelBufferTime];
					}
				}
				CFRelease(_lastRenderPixelBuffer);
				_lastRenderPixelBuffer = NULL;
			}
			[delegate displayAndRenderPixelBuffer:sourcePixelBuffer toPixelBuffer:dstPixelBuffer motion:motion];
			_lastRenderPixelBuffer = dstPixelBuffer;
			_lastRenderPixelBufferTime = timestamp;
			CFRelease( sourcePixelBuffer );
		});
	}
}

- (void)captureSessionDidStopRunning:(NSNotification *)notification
{
	[self stopRecording]; // does nothing if we aren't currently recording
}

- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position 
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices)
		if ([device position] == position)
			return device;
	
	return nil;
}

- (AVCaptureDevice *)audioDevice
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
	if ([devices count] > 0)
		return [devices objectAtIndex:0];
	
	return nil;
}

- (BOOL)setupCaptureSession 
{
	/*
	 Overview: VideoSnake uses separate GCD queues for audio and video capture.  If a single GCD queue
	 is used to deliver both audio and video buffers, and our video processing consistently takes
	 too long, the delivery queue can back up, resulting in audio being dropped.
	 */
	
	/*
	 * Create capture session
	 */
	_captureSession = [[AVCaptureSession alloc] init];
		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionDidStopRunning:) name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
	
	/*
	 * Create audio connection
	 */
	AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
	if ([_captureSession canAddInput:audioIn])
		[_captureSession addInput:audioIn];
	[audioIn release];
	
	AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
	dispatch_queue_t audioCaptureQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
	[audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
	dispatch_release(audioCaptureQueue);
	if ([_captureSession canAddOutput:audioOut])
		[_captureSession addOutput:audioOut];
	_audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
	[audioOut release];
	
	/*
	 * Create video connection
	 */
	AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];
	if ([_captureSession canAddInput:videoIn])
		[_captureSession addInput:videoIn];
	[videoIn release];
	
	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	dispatch_queue_t videoCaptureQueue = dispatch_queue_create( "Video Capture Queue", DISPATCH_QUEUE_SERIAL );
	dispatch_set_target_queue( videoCaptureQueue, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0) );
	[videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
	dispatch_release(videoCaptureQueue);
	if ([_captureSession canAddOutput:videoOut])
		[_captureSession addOutput:videoOut];
	_videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];

	/*
	 VideoSnake prefers to discard late video frames early in the capture pipeline, since its
	 processing can take longer than real-time on some platforms (such as iPhone 3GS).
	 Clients whose image processing is faster than real-time should consider setting AVCaptureVideoDataOutput's
	 alwaysDiscardsLateVideoFrames property to NO. 
	 */
	[videoOut setAlwaysDiscardsLateVideoFrames:NO];
	
	// For single core systems like iPhone 3GS, iPhone 4 and iPod Touch 4th Generation we use a lower resolution and framerate to increase performance.
	CMTime frameDuration = kCMTimeInvalid;
	if ( [[NSProcessInfo processInfo] processorCount] == 1 ) {
		if ( [_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480] )
			_captureSession.sessionPreset = AVCaptureSessionPreset640x480;
		frameDuration = CMTimeMake( 1, 15 );
	}
	else {
		frameDuration = CMTimeMake( 1, 30 );
	}
	
	if ( _videoConnection.supportsVideoMinFrameDuration )
		_videoConnection.videoMinFrameDuration = frameDuration;
	if ( _videoConnection.supportsVideoMaxFrameDuration )
		_videoConnection.videoMaxFrameDuration = frameDuration;
	
	self.videoOrientation = [_videoConnection videoOrientation];
	[videoOut release];
	
	// Create a shallow queue for buffers going to the display for preview.
	CMBufferQueueCreate( kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &_previewBufferQueue );
	
	// Set up motion synchronizer
	MotionSynchronizer *motionSynchronizer = [[MotionSynchronizer alloc] init];
	_motionSynchronizationQueue = dispatch_queue_create( "Motion Queue", DISPATCH_QUEUE_SERIAL );
	[motionSynchronizer setMotionRate:60];
	[motionSynchronizer setSynchronizedSampleBufferDelegate:self queue:_motionSynchronizationQueue];
	
	// We add an audio data ouput, which means that the video buffer timestamps are remapped into the audio clock.
	// If we were not adding an audio data output we would use CMClockGetHostTimeClock() here instead.
	CMClockRef sbufClock = NULL;
	CMAudioClockCreate( kCFAllocatorDefault, &sbufClock );
	[motionSynchronizer setSampleBufferClock:sbufClock];
	CFRelease( sbufClock );
	
	self.motionSynchronizer = motionSynchronizer;
	[motionSynchronizer release];
	[self.motionSynchronizer start];
	
	return YES;
}

- (void)setupAndStartCaptureSession
{
	if ( !_captureSession )
		[self setupCaptureSession];
	
	if ( !_captureSession.isRunning )
		[_captureSession startRunning];
}

- (void)pauseCaptureSession
{
	if ( _captureSession.isRunning )
		[_captureSession stopRunning];
}

- (void)resumeCaptureSession
{
	if ( !_captureSession.isRunning )
		[_captureSession startRunning];
}

- (void)stopAndTearDownCaptureSession
{
	[_captureSession stopRunning];
	if ( _captureSession ) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
		
		[_captureSession release];
		_captureSession = nil;
		
		if (_previewBufferQueue) {
			CFRelease(_previewBufferQueue);
			_previewBufferQueue = NULL;
		}
		
		[_motionSynchronizer stop];
		[_motionSynchronizer release];
		_motionSynchronizer = nil;
	}
}

@end
