/*
     File: GSDocument.m
 Abstract: Main document
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

#import "GSDocument.h"

#import <AVFoundation/AVFoundation.h>

#import "GSPlayerView.h"

@implementation GSDocument

{
	AVPlayer *_player;
	id _observer;
}

#pragma mark -

- (id)init
{
	self = [super init];
	
	if (self)
	{
		_player = [[AVPlayer alloc] init];
		
		__weak GSDocument *_self = self;
		_observer = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			GSDocument *doc = _self;
			if (doc)
				[doc->_currentTimeSlider setDoubleValue:(CMTimeGetSeconds(time) / CMTimeGetSeconds([[doc->_player currentItem] duration]))];
		}];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	
	[_player removeTimeObserver:_observer];
}

#pragma mark -

@synthesize playerView = _playerView;
@synthesize playPauseButton = _playPauseButton;
@synthesize currentTimeSlider = _currentTimeSlider;
@synthesize chromaKeyColorWell = _chromaKeyColorWell;

#pragma mark -

- (NSString *)windowNibName
{
	return @"GSDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
	[super windowControllerDidLoadNib:windowController];
	
	[_playerView bind:@"playerItem" toObject:_player withKeyPath:@"currentItem" options:nil];
	
	[_currentTimeSlider setDoubleValue:0.0];
	
	[_chromaKeyColorWell bind:@"value" toObject:_playerView withKeyPath:@"chromaKeyColor" options:nil];
}

- (void)close
{
	[_chromaKeyColorWell unbind:@"value"];
	
	[_playerView unbind:@"playerItem"];
	
	[super close];
}

#pragma mark -

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
	AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
	if (playerItem)
	{
		[_player replaceCurrentItemWithPlayerItem:playerItem];
		return YES;
	}
	
	return NO;
}

#pragma mark -

- (IBAction)togglePlayPause:(id)sender
{
	if (CMTIME_COMPARE_INLINE([[_player currentItem] currentTime], >=, [[_player currentItem] duration]))
		[[_player currentItem] seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
	
	[_player setRate:([_player rate] == 0.0f ? 1.0f : 0.0f)];
	
	[(NSButton *)sender setTitle:([_player rate] == 0.0f ? @"Play" : @"Pause")];
}

- (IBAction)seekToTime:(id)sender
{
	[[_player currentItem] seekToTime:CMTimeMultiplyByFloat64([[_player currentItem] duration], (Float64)[(NSSlider *)sender doubleValue]) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark -

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
	if ([_player currentItem] == [notification object])
	{
		[(NSButton *)_playPauseButton setTitle:([_player rate] == 0.0f ? @"Play" : @"Pause")];
	}
}

@end
