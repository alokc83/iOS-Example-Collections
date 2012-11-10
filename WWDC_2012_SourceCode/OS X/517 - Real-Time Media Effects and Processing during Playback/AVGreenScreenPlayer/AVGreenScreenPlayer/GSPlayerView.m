/*
     File: GSPlayerView.m
 Abstract: Player view using AVPlayerItemVideoOutput with chroma key filter.
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

#import "GSPlayerView.h"

#import <AVFoundation/AVFoundation.h>

#define FREEWHEELING_PERIOD_IN_SECONDS 0.5
#define ADVANCE_INTERVAL_IN_SECONDS 0.1

@interface GSPlayerView ()
{
	AVPlayerItem *_playerItem;
	
	AVPlayerItemVideoOutput *_playerItemVideoOutput;
	CVDisplayLinkRef _displayLink;
	CVPixelBufferRef _currentPixelBuffer;
	uint64_t _lastHostTime;
	dispatch_queue_t _queue;
}
@end

@interface GSPlayerView (AVPlayerItemOutputPullDelegate) <AVPlayerItemOutputPullDelegate>
@end

#pragma mark -

@implementation GSPlayerView

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
	{
		_queue = dispatch_queue_create(NULL, NULL);
		
		_playerItemVideoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil]]; // kCVPixelFormatType_32ARGB, kCVPixelFormatType_32BGRA, kCVPixelFormatType_422YpCbCr8
		if (_playerItemVideoOutput)
		{
			[_playerItemVideoOutput setDelegate:self queue:_queue];
			[_playerItemVideoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ADVANCE_INTERVAL_IN_SECONDS];
			
			CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
			CVDisplayLinkSetOutputCallback(_displayLink, displayLinkCallback, (__bridge void *)self);
		}
		
		[self setLayer:[CALayer layer]];
		[self setWantsLayer:YES];
		
		[[self layer] setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
		[[self layer] setContentsGravity:kCAGravityResizeAspect];
		
		CIFilter *chromaKeyFilter = [CIFilter filterWithName:@"GSChromaKeyFilter"];
		[chromaKeyFilter setName:@"chromaKeyFilter"];
		
		[[self layer] setFilters:@[chromaKeyFilter]];
	}
	
	return self;
}

- (void)dealloc
{
	if (_displayLink)
	{
		CVDisplayLinkStop(_displayLink);
		CVDisplayLinkRelease(_displayLink);
	}
	
	if (_currentPixelBuffer)
		CFRelease(_currentPixelBuffer);
	
	dispatch_sync(_queue, ^{
		[_playerItemVideoOutput setDelegate:nil queue:NULL];
	});
}

#pragma mark -

- (AVPlayerItem *)playerItem
{
	return _playerItem;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
	if (_playerItem != playerItem)
	{
		if (_playerItem)
			[_playerItem removeOutput:_playerItemVideoOutput];
		
		_playerItem = playerItem;
		
		if (_playerItem)
			[_playerItem addOutput:_playerItemVideoOutput];
	}
}

- (NSColor *)chromaKeyColor
{
	return [NSColor colorWithCIColor:[self valueForKeyPath:@"layer.filters.chromaKeyFilter.inputColor"]];
}

- (void)setChromaKeyColor:(NSColor *)chromaKeyColor
{
	[self setValue:[CIColor colorWithCGColor:[chromaKeyColor CGColor]] forKeyPath:@"layer.filters.chromaKeyFilter.inputColor"];
}

#pragma mark -

- (void)usePixelBuffer:(CVPixelBufferRef)pixelBuffer
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	// Retain the pixel buffer to prevent its IOSurface being recycled while it is being displayed.
	if (_currentPixelBuffer)
		CFRelease(_currentPixelBuffer);
	_currentPixelBuffer = pixelBuffer;
	if (_currentPixelBuffer)
		CFRetain(_currentPixelBuffer);
	
	[[self layer] setContents:(__bridge id)CVPixelBufferGetIOSurface(_currentPixelBuffer)];
	
	[CATransaction commit];
}

#pragma mark -

static CVReturn displayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
	GSPlayerView *self = (__bridge GSPlayerView *)displayLinkContext;
	AVPlayerItemVideoOutput *playerItemVideoOutput = self->_playerItemVideoOutput;
	
	CMTime outputItemTime = [playerItemVideoOutput itemTimeForCVTimeStamp:*inOutputTime];
	if ([playerItemVideoOutput hasNewPixelBufferForItemTime:outputItemTime])
	{
		self->_lastHostTime = inOutputTime->hostTime;
		
		CVPixelBufferRef pixBuff = [playerItemVideoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
		
		[self usePixelBuffer:pixBuff];
		
		CVBufferRelease(pixBuff);
	}
	else
	{
		CMTime elapsedTime = CMClockMakeHostTimeFromSystemUnits(inNow->hostTime - self->_lastHostTime);
		if (CMTimeGetSeconds(elapsedTime) > FREEWHEELING_PERIOD_IN_SECONDS)
		{
			// No new images for a while.  Shut down the display link to conserve power, but request a wakeup call if new images are coming.
			
			[playerItemVideoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ADVANCE_INTERVAL_IN_SECONDS];
			
			CVDisplayLinkStop(self->_displayLink);
		}
	}
	
	return kCVReturnSuccess;
}

@end

#pragma mark -

@implementation GSPlayerView (AVPlayerItemOutputPullDelegate)

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
	// Start running again.
	_lastHostTime = CVGetCurrentHostTime();
	CVDisplayLinkStart(_displayLink);
}

@end
