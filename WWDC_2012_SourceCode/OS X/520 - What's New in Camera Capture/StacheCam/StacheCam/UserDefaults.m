
/*
     File: UserDefaults.m
 Abstract: Utility class for managing persistent user settings
  Version: 2.1
 
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


#import "UserDefaults.h"

static NSString* USING_FRONT_CAMERA_DEFAULTS_KEY = @"usingFrontCamera";
static NSString* DISPLAY_AVF_MUSTACHES_DEFAULTS_KEY = @"displayAVFMustaches";
static NSString* DISPLAY_AVF_RECTS_DEFAULTS_KEY = @"displayAVFRects";
static NSString* DISPLAY_CI_RECTS_DEFAULTS_KEY = @"displayCIRects";
static NSString* USING_ANIMATION_DEFAULTS_KEY = @"usingAnimation";

@implementation UserDefaults

+ (void) initialize {
	[[NSUserDefaults standardUserDefaults] registerDefaults: @{
		USING_FRONT_CAMERA_DEFAULTS_KEY : [NSNumber numberWithBool:YES],
		DISPLAY_AVF_MUSTACHES_DEFAULTS_KEY : [NSNumber numberWithBool:YES],
		DISPLAY_AVF_RECTS_DEFAULTS_KEY : [NSNumber numberWithBool:NO],
		DISPLAY_CI_RECTS_DEFAULTS_KEY : [NSNumber numberWithBool:NO],
		USING_ANIMATION_DEFAULTS_KEY : [NSNumber numberWithBool:NO],
	 }];
}

+ (BOOL) usingFrontCamera { return [[NSUserDefaults standardUserDefaults] boolForKey:USING_FRONT_CAMERA_DEFAULTS_KEY]; }
+ (void) setUsingFrontCamera:(BOOL)x { [[NSUserDefaults standardUserDefaults] setBool:x forKey:USING_FRONT_CAMERA_DEFAULTS_KEY]; }

+ (BOOL) displayAVFMustaches { return [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_AVF_MUSTACHES_DEFAULTS_KEY]; }
+ (void) setDisplayAVFMustaches:(BOOL)x { [[NSUserDefaults standardUserDefaults] setBool:x forKey:DISPLAY_AVF_MUSTACHES_DEFAULTS_KEY]; }

+ (BOOL) displayAVFRects { return [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_AVF_RECTS_DEFAULTS_KEY]; }
+ (void) setDisplayAVFRects:(BOOL)x { [[NSUserDefaults standardUserDefaults] setBool:x forKey:DISPLAY_AVF_RECTS_DEFAULTS_KEY]; }

+ (BOOL) displayCIRects { return [[NSUserDefaults standardUserDefaults] boolForKey:DISPLAY_CI_RECTS_DEFAULTS_KEY]; }
+ (void) setDisplayCIRects:(BOOL)x { [[NSUserDefaults standardUserDefaults] setBool:x forKey:DISPLAY_CI_RECTS_DEFAULTS_KEY]; }

+ (BOOL) usingAnimation { return [[NSUserDefaults standardUserDefaults] boolForKey:USING_ANIMATION_DEFAULTS_KEY]; }
+ (void) setUsingAnimation:(BOOL)x { [[NSUserDefaults standardUserDefaults] setBool:x forKey:USING_ANIMATION_DEFAULTS_KEY]; }

@end