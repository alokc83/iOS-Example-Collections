
/*
     File: MovieRecorder.m
 Abstract: Real-time movie recorder which is totally non-blocking
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

#import "MovieRecorder.h"

#import <AVFoundation/AVAssetWriter.h>
#import <AVFoundation/AVAssetWriterInput.h>

#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVVideoSettings.h>
#import <AVFoundation/AVAudioSettings.h>

#include <objc/runtime.h> // for objc_loadWeak() and objc_storeWeak()

enum {
	MovieRecorderStatusIdle = 0,
	MovieRecorderStatusPreparingToRecord,
	MovieRecorderStatusRecording,
	MovieRecorderStatusFinishingRecording,
	MovieRecorderStatusFinished,	// terminal state
	MovieRecorderStatusFailed		// terminal state
};
typedef NSInteger MovieRecorderStatus; // internal state machine


@interface MovieRecorder ()
{
	MovieRecorderStatus _status;

	__weak id <MovieRecorderDelegate> _delegate; // __weak doesn't actually do anything under non-ARC
	dispatch_queue_t _delegateCallbackQueue;
	
	dispatch_queue_t _writingQueue;
	
	AVAssetWriter *_assetWriter;
	BOOL _haveStartedSession;
	
	BOOL _addedAudioTrack;
	CMFormatDescriptionRef _audioTrackSourceFormatDescription;
	AVAssetWriterInput *_audioInput;

	BOOL _addedVideoTrack;
	CMFormatDescriptionRef _videoTrackSourceFormatDescription;
	CGAffineTransform _videoTrackTransform;
	AVAssetWriterInput *_videoInput;
}
@end

@implementation MovieRecorder

#pragma mark -
#pragma mark API

- (id)init
{
	if ( self = [super init] ) {
		_writingQueue = dispatch_queue_create( "MovieRecorder writing queue", DISPATCH_QUEUE_SERIAL );
		_videoTrackTransform = CGAffineTransformIdentity;
	}
	return self;
}

- (void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription transform:(CGAffineTransform)transform
{
	if ( formatDescription == NULL ) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL format description" userInfo:nil];
		return;			
	}
	
	@synchronized( self ) {
		if ( _status != MovieRecorderStatusIdle ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
			return;
		}
		
		if ( _addedVideoTrack ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add more than one video track" userInfo:nil];
			return;
		}
		
		_addedVideoTrack = YES;
		_videoTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain( formatDescription );
		_videoTrackTransform = transform;
	}
}

- (void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription
{
	if ( formatDescription == NULL ) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL format description" userInfo:nil];
		return;			
	}
	
	@synchronized( self ) {
		if ( _status != MovieRecorderStatusIdle ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
			return;
		}
		
		if ( _addedAudioTrack ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add more than one audio track" userInfo:nil];
			return;
		}
		
		_addedAudioTrack = YES;
		_audioTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain( formatDescription );
	}
}

- (id<MovieRecorderDelegate>)_delegate
{
	id <MovieRecorderDelegate> delegate = nil;
	@synchronized( self ) {
		delegate = objc_loadWeak( &_delegate ); // unnecessary under ARC, just assign to delegate directly
	}
	return delegate;
}

- (void)setDelegate:(id<MovieRecorderDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue; // delegate is weak referenced
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

- (void)prepareToRecordToURL:(NSURL*)URL
{
	@synchronized( self ) {
		if ( _status != MovieRecorderStatusIdle ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already prepared, cannot prepare again" userInfo:nil];
			return;
		}
		
		[self _transitionToStatus:MovieRecorderStatusPreparingToRecord error:nil];
	}
	
	dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0 ), ^{
		@autoreleasepool {
			NSError *error = nil;
			
			// AVAssetWriter will not write over an existing file.
			[[NSFileManager defaultManager] removeItemAtURL:URL error:NULL];
			
			_assetWriter = [[AVAssetWriter alloc] initWithURL:URL fileType:AVFileTypeQuickTimeMovie error:&error];
			
			// Create and add inputs
			if ( ! error && _addedVideoTrack ) {
				[self _setupAssetWriterVideoInput:_videoTrackSourceFormatDescription transform:_videoTrackTransform error:&error];
				CFRelease( _videoTrackSourceFormatDescription );
				_videoTrackSourceFormatDescription = NULL;
			}
			
			if ( ! error && _addedAudioTrack ) {
				[self _setupAssetWriterAudioInput:_audioTrackSourceFormatDescription error:&error];
				CFRelease( _audioTrackSourceFormatDescription );
				_audioTrackSourceFormatDescription = NULL;
			}
			
			if ( ! error ) {
				BOOL success = [_assetWriter startWriting];
				if ( ! success )
					error = _assetWriter.error;
			}
			
			@synchronized( self ) {
				if ( error )
					[self _transitionToStatus:MovieRecorderStatusFailed error:error];
				else
					[self _transitionToStatus:MovieRecorderStatusRecording error:nil];
			}
		}
	});
}

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	[self _appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
	[self _appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
}

- (void)finishRecording;
{
	@synchronized( self ) {
		if ( _status < MovieRecorderStatusRecording ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not yet recording" userInfo:nil];
			return;
		}
		else if ( ( _status == MovieRecorderStatusFinishingRecording ) || ( _status == MovieRecorderStatusFinished ) ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already finishing or finished recording" userInfo:nil];
			return;
		}
		if ( _status == MovieRecorderStatusFailed ) {
			NSLog( @"Alread failed, nothing to do" );
			return;
		}
		
		[self _transitionToStatus:MovieRecorderStatusFinishingRecording error:nil];
	}
	
	dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
		@autoreleasepool {
			// Make sure there are no sample buffers inflight.
			// It is not safe to call -[AVAssetWriter finishWriting] concurrently with -[AVAssetWriterInput appendSampleBuffer:]
			dispatch_sync( _writingQueue, ^{} );
			
			// Note that we may have transitioned to an error state as we flushed inflight buffers.
			// Thats fine, we will call -[AVAssetWriter finishWriting] which will return false.
			// We will then attempt a second transition to MovieRecorderStatusFailed which is harmless (and wouldn't call the client back a second time)
			
			BOOL success = [_assetWriter finishWriting]; // May take a while
			
			@synchronized( self ) {
				if ( success )
					[self _transitionToStatus:MovieRecorderStatusFinished error:nil];
				else {
					[self _transitionToStatus:MovieRecorderStatusFailed error:_assetWriter.error];
				}
			}
		}
	});
}

- (void)dealloc
{
	objc_storeWeak( &_delegate, nil ); // unregister _delegate as a weak reference
	
	if ( _delegateCallbackQueue )
		dispatch_release( _delegateCallbackQueue );
	
	if ( _writingQueue )
		dispatch_release( _writingQueue );
	
	[self _teardownAssetWriterAndInputs];

	if ( _audioTrackSourceFormatDescription )
		CFRelease( _audioTrackSourceFormatDescription );
	if ( _videoTrackSourceFormatDescription )
		CFRelease( _videoTrackSourceFormatDescription );
	
	[super dealloc];
}

#pragma mark -
#pragma mark Internal

- (void)_appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType
{
	if ( sampleBuffer == NULL ) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL sample buffer" userInfo:nil];
		return;			
	}
	
	@synchronized( self ) {
		if ( _status < MovieRecorderStatusRecording ) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not ready to record yet" userInfo:nil];
			return;	
		}
	}
	
	CFRetain( sampleBuffer );
	dispatch_async( _writingQueue, ^{
		@synchronized( self ) {
			if ( _status != MovieRecorderStatusRecording ) {
//				NSLog( @"%@ status is not recording (its %@), ignoring", NSStringFromSelector(_cmd), [self _stringForStatus:_status] );
				CFRelease( sampleBuffer );
				return;
			}
		}
		
		if ( ! _haveStartedSession ) {
			[_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
			_haveStartedSession = YES;
		}
		
		AVAssetWriterInput *input = ( mediaType == AVMediaTypeVideo ) ? _videoInput : _audioInput;
		if ( input == nil ) {
			NSLog( @"no input of type %@, ignoring", mediaType );
			CFRelease( sampleBuffer );
			return;
		}
		
		// do the actual append
		if ( input.readyForMoreMediaData ) {
			BOOL success = [input appendSampleBuffer:sampleBuffer];
			if ( ! success ) {
				NSError *error = _assetWriter.error;
				@synchronized( self ) {
					[self _transitionToStatus:MovieRecorderStatusFailed error:error];
				}
			}
		}
		else {
			NSLog( @"%@ input not ready for more media data, dropping buffer", mediaType );
		}
		CFRelease( sampleBuffer );
	});
}

- (NSString*)_stringForStatus:(MovieRecorderStatus)status
{
	NSString *statusString = nil;
	
	switch ( status ) {
		case MovieRecorderStatusIdle:
			statusString = @"Idle";
			break;
		case MovieRecorderStatusPreparingToRecord:
			statusString = @"PreparingToRecord";
			break;
		case MovieRecorderStatusRecording:
			statusString = @"Recording";
			break;
		case MovieRecorderStatusFinishingRecording:
			statusString = @"FinishingRecording";
			break;
		case MovieRecorderStatusFinished:
			statusString = @"Finished";
			break;
		case MovieRecorderStatusFailed:
			statusString = @"Failed";
			break;
		default:
			statusString = @"Unknown";
			break;
	}
	return statusString;
	
}

// call under @synchonized( self )
- (void)_transitionToStatus:(MovieRecorderStatus)newStatus error:(NSError*)error
{
	BOOL shouldNotifyDelegate = NO;
	
//	NSLog( @"MovieRecorder state transition: %@->%@", [self _stringForStatus:_status], [self _stringForStatus:newStatus] );
	
	if ( newStatus != _status ) {
		// terminal states
		if ( ( newStatus == MovieRecorderStatusFinished ) || ( newStatus == MovieRecorderStatusFailed ) ) {
			shouldNotifyDelegate = YES;
			// make sure there are no more sample buffers in flight before we tear down the asset writer and inputs
			dispatch_async( _writingQueue, ^{
				[self _teardownAssetWriterAndInputs];
			});
		}
		else if ( newStatus == MovieRecorderStatusRecording ) {
			shouldNotifyDelegate = YES;
		}
		
		_status = newStatus;
	}

	if ( shouldNotifyDelegate && [self _delegate] ) {
		dispatch_async( _delegateCallbackQueue, ^{
			@autoreleasepool {
				switch ( newStatus ) {
					case MovieRecorderStatusRecording:
						[[self _delegate] recorderDidFinishPreparingToRecord:self];
						break;
					case MovieRecorderStatusFinished:
						[[self _delegate] recorderDidFinishRecording:self];
						break;
					case MovieRecorderStatusFailed:
						[[self _delegate] recorder:self didFailWithError:error];
						break;
					default:
						break;
				}
			}
		});
	}
}

- (NSError*)_cannotSetupInputError
{
	NSString *localizedDescription = NSLocalizedString( @"Recording cannot be started", nil );
	NSString *localizedFailureReason = NSLocalizedString( @"Cannot setup asset writer input.", nil );
	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   localizedDescription, NSLocalizedDescriptionKey, 
							   localizedFailureReason, NSLocalizedFailureReasonErrorKey, 
							   nil];
	return [NSError errorWithDomain:@"VideoSnake" code:0 userInfo:errorDict];
}

- (BOOL)_setupAssetWriterAudioInput:(CMFormatDescriptionRef)audioFormatDescription error:(NSError**)errorOut
{
	BOOL supportsFormatHint = [AVAssetWriterInput instancesRespondToSelector:@selector(initWithMediaType:outputSettings:sourceFormatHint:)]; // supported on iOS 6 and later
	
	NSDictionary *audioCompressionSettings = nil;
	
	if ( supportsFormatHint ) {
		audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
									nil];
	}
	else {
		const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDescription);
		
		size_t aclSize = 0;
		const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(audioFormatDescription, &aclSize);
		NSData *currentChannelLayoutData = nil;
		
		// AVChannelLayoutKey must be specified, but if we don't know any better give an empty data and let AVAssetWriter decide.
		if ( currentChannelLayout && aclSize > 0 )
			currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
		else
			currentChannelLayoutData = [NSData data];
		
		audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
									[NSNumber numberWithFloat:currentASBD->mSampleRate], AVSampleRateKey,
									[NSNumber numberWithInt:64000], AVEncoderBitRatePerChannelKey,
									[NSNumber numberWithInteger:currentASBD->mChannelsPerFrame], AVNumberOfChannelsKey,
									currentChannelLayoutData, AVChannelLayoutKey,
									nil];
	}
	if ([_assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
		if ( supportsFormatHint )
			_audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings sourceFormatHint:audioFormatDescription];
		else
			_audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
		_audioInput.expectsMediaDataInRealTime = YES;
		if ([_assetWriter canAddInput:_audioInput])
			[_assetWriter addInput:_audioInput];
		else {
			if ( errorOut )
				*errorOut = [self _cannotSetupInputError];
            return NO;
		}
	}
	else {
		if ( errorOut )
			*errorOut = [self _cannotSetupInputError];
        return NO;
	}
    
    return YES;
}

- (BOOL)_setupAssetWriterVideoInput:(CMFormatDescriptionRef)videoFormatDescription transform:(CGAffineTransform)transform error:(NSError**)errorOut
{
	BOOL supportsFormatHint = [AVAssetWriterInput instancesRespondToSelector:@selector(initWithMediaType:outputSettings:sourceFormatHint:)]; // supported on iOS 6 and later
	
	float bitsPerPixel;
	CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(videoFormatDescription);
	int numPixels = dimensions.width * dimensions.height;
	int bitsPerSecond;
	
	// Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
	if ( numPixels < (640 * 480) )
		bitsPerPixel = 4.05; // This bitrate matches the quality produced by AVCaptureSessionPresetMedium or Low.
	else
		bitsPerPixel = 11.4; // This bitrate matches the quality produced by AVCaptureSessionPresetHigh.
	
	bitsPerSecond = numPixels * bitsPerPixel;
	
	NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  AVVideoCodecH264, AVVideoCodecKey,
											  [NSNumber numberWithInteger:dimensions.width], AVVideoWidthKey,
											  [NSNumber numberWithInteger:dimensions.height], AVVideoHeightKey,
											  [NSDictionary dictionaryWithObjectsAndKeys:
											   [NSNumber numberWithInteger:bitsPerSecond], AVVideoAverageBitRateKey,
											   [NSNumber numberWithInteger:30], AVVideoMaxKeyFrameIntervalKey,
											   nil], AVVideoCompressionPropertiesKey,
											  nil];
	if ([_assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
		if ( supportsFormatHint )
			_videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings sourceFormatHint:videoFormatDescription];
		else
			_videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
		_videoInput.expectsMediaDataInRealTime = YES;
		_videoInput.transform = transform;
		if ([_assetWriter canAddInput:_videoInput])
			[_assetWriter addInput:_videoInput];
		else {
			if ( errorOut )
				*errorOut = [self _cannotSetupInputError];
            return NO;
		}
	}
	else {
		if ( errorOut )
			*errorOut = [self _cannotSetupInputError];
        return NO;
	}
    
    return YES;
}

- (void)_teardownAssetWriterAndInputs
{
	[_videoInput release];
	_videoInput = nil;
	[_audioInput release];
	_audioInput = nil;

	[_assetWriter release];
	_assetWriter = nil;
}

@end
