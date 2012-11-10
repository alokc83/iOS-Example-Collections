/*
     File: SSMetalTheme.m
 Abstract: This theme uses a custom metal appearance.
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

#import "SSMetalTheme.h"

@implementation SSMetalTheme

- (UIColor *)mainColor
{
    return [UIColor colorWithWhite:0.20 alpha:1.0];
}

- (UIColor *)highlightColor
{
    return [UIColor colorWithWhite:0.9 alpha:1.0];
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithWhite:1.0 alpha:0.5];
}

- (UIColor *)backgroundColor
{
    return [UIColor colorWithWhite:0.85 alpha:1.0];
}

- (UIColor *)baseTintColor
{
    return nil;
}

- (UIColor *)accentTintColor
{
    return nil;
}

- (UIColor *)switchThumbColor
{
    return [UIColor colorWithWhite:0.75 alpha:1.0];
}

- (UIColor *)switchOnColor
{
    return [UIColor colorWithWhite:0.25 alpha:1.0];
}

- (UIColor *)switchTintColor
{
    return [UIColor colorWithWhite:0.85 alpha:1.0];
}

- (CGSize)shadowOffset
{
    return CGSizeMake(0.0, 1.0);
}

- (UIImage *)topShadow
{
    return [UIImage imageNamed:@"topShadow"];
}

- (UIImage *)bottomShadow
{
    return [UIImage imageNamed:@"bottomShadow"];
}

- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    NSString *name = @"navigationBackground";
    if (metrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"Landscape"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
    return image;
}

- (UIImage *)barButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics
{
    NSString *name = @"barButton";
    if (style == UIBarButtonItemStyleDone) {
        name = [name stringByAppendingString:@"Done"];
    }
    if (barMetrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"Landscape"];
    }
    if (state == UIControlStateHighlighted) {
        name = [name stringByAppendingString:@"Highlighted"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 13.0, 0.0, 13.0)];
    return image;
}

- (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    NSString *name = @"backButton";
    if (barMetrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"Landscape"];
    }
    if (state == UIControlStateHighlighted) {
        name = [name stringByAppendingString:@"Highlighted"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 21.0, 0.0, 13.0)];
    return image;
}

- (UIImage *)toolbarBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    NSString *name = @"toolbarBackground";
    if (metrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"Landscape"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
    return image;
}

- (UIImage *)searchBackground
{
    return [UIImage imageNamed:@"searchBackground"];
}

- (UIImage *)searchFieldImage
{
    UIImage *image = [UIImage imageNamed:@"searchField"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)];
    return image;
}

- (UIImage *)searchScopeButtonBackgroundForState:(UIControlState)state
{
    NSString *name = @"searchScopeButton";
    if (state == UIControlStateSelected) {
        name = [name stringByAppendingString:@"Selected"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 13.0, 0.0, 13.0)];
    return image;
}

- (UIImage *)searchScopeButtonDivider
{
    return [UIImage imageNamed:@"searchScopeDivider"];
}

- (UIImage *)searchImageForIcon:(UISearchBarIcon)icon state:(UIControlState)state
{
    NSString *name;
    if (icon == UISearchBarIconSearch) {
        name = @"searchIconSearch";
    } else if (icon == UISearchBarIconClear) {
        name = @"searchIconClear";
        if (state == UIControlStateHighlighted) {
            name = [name stringByAppendingString:@"Highlighted"];
        }
    }
    return (name ? [UIImage imageNamed:name] : nil);
}

- (UIImage *)segmentedBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
{
    NSString *name = @"segmentedBackground";
    if (barMetrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"Landscape"];
    }
    if (state == UIControlStateSelected) {
        name = [name stringByAppendingString:@"Selected"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 13.0, 0.0, 13.0)];
    return image;
}

- (UIImage *)segmentedDividerForBarMetrics:(UIBarMetrics)barMetrics
{
    NSString *name = @"segmentedDivider";
    if (barMetrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"Landscape"];
    }
    return [UIImage imageNamed:name];
}

- (UIImage *)tableBackground
{
    UIImage *image = [UIImage imageNamed:@"tableBackground"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsZero];
    return image;
}

- (UIImage *)onSwitchImage
{
    return [UIImage imageNamed:@"onSwitch"];
}

- (UIImage *)offSwitchImage
{
    return [UIImage imageNamed:@"offSwitch"];
}

- (UIImage *)sliderThumbForState:(UIControlState)state
{
    NSString *name = @"sliderThumb";
    if (state == UIControlStateHighlighted) {
        name = [name stringByAppendingString:@"Highlighted"];
    }
    return [UIImage imageNamed:name];
}

- (UIImage *)sliderMinTrack
{
    UIImage *image = [UIImage imageNamed:@"sliderMinTrack"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
    return image;
}

- (UIImage *)sliderMaxTrack
{
    UIImage *image = [UIImage imageNamed:@"sliderMaxTrack"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
    return image;
}

- (UIImage *)speedSliderMinImage
{
    return [UIImage imageNamed:@"slowShip"];
}

- (UIImage *)speedSliderMaxImage
{
    return [UIImage imageNamed:@"fastShip"];
}

- (UIImage *)progressTrackImage
{
    UIImage *image = [UIImage imageNamed:@"progressTrack"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
    return image;
}

- (UIImage *)progressProgressImage
{
    UIImage *image = [UIImage imageNamed:@"progressProgress"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
    return image;
}

- (UIImage *)stepperBackgroundForState:(UIControlState)state
{
    NSString *name = @"stepperBackground";
    if (state == UIControlStateHighlighted) {
        name = [name stringByAppendingString:@"Highlighted"];
    } else if (state == UIControlStateDisabled) {
        name = [name stringByAppendingString:@"Disabled"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 13.0, 0.0, 13.0)];
    return image;
}

- (UIImage *)stepperDividerForState:(UIControlState)state
{
    NSString *name = @"stepperDivider";
    if (state == UIControlStateHighlighted) {
        name = [name stringByAppendingString:@"Highlighted"];
    }
    return [UIImage imageNamed:name];
}

- (UIImage *)stepperIncrementImage
{
    return [UIImage imageNamed:@"stepperIncrement"];
}

- (UIImage *)stepperDecrementImage
{
    return [UIImage imageNamed:@"stepperDecrement"];
}

- (UIImage *)buttonBackgroundForState:(UIControlState)state
{
    NSString *name = @"button";
    if (state == UIControlStateHighlighted) {
        name = [name stringByAppendingString:@"Highlighted"];
    } else if (state == UIControlStateDisabled) {
        name = [name stringByAppendingString:@"Disabled"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)];
    return image;
}

- (UIImage *)tabBarBackground
{
    return [UIImage imageNamed:@"tabBarBackground"];
}

- (UIImage *)tabBarSelectionIndicator
{
    return [UIImage imageNamed:@"tabBarSelectionIndicator"];
}

- (UIImage *)imageForTab:(SSThemeTab)tab
{
    return nil;
}

- (UIImage *)finishedImageForTab:(SSThemeTab)tab selected:(BOOL)selected
{
    NSString *name = nil;
    if (tab == SSThemeTabDoor) {
        name = @"doorTab";
    } else if (tab == SSThemeTabPower) {
        name = @"powerTab";
    } else if (tab == SSThemeTabControls) {
        name = @"controlsTab";
    }
    if (selected) {
        name = [name stringByAppendingString:@"Selected"];
    }
    return (name ? [UIImage imageNamed:name] : nil);
}

- (UIImage *)doorImageForState:(UIControlState)state
{
    NSString *name;
    if (state & UIControlStateDisabled) {
        name = @"doorDisabled";
    } else {
        if (state & UIControlStateSelected) {
            name = @"doorOpen";
        } else {
            name = @"doorClosed";
        }
        if (state & UIControlStateHighlighted) {
            name = [name stringByAppendingString:@"Highlighted"];
        }
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(16.0, 0.0, 15.0, 0.0)];
    return image;
}

@end
