/*
     File: SSTheme.m
 Abstract: The SSTheme protocol that must be adopted by themes and the SSThemeManager that gives access to the current theme.
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

#import "SSTheme.h"

#import "SSDefaultTheme.h"
#import "SSTintedTheme.h"
#import "SSMetalTheme.h"

@implementation SSThemeManager

+ (id <SSTheme>)sharedTheme
{
    static id <SSTheme> sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Create and return the theme:
//        sharedTheme = [[SSDefaultTheme alloc] init];
//        sharedTheme = [[SSTintedTheme alloc] init];
        sharedTheme = [[SSMetalTheme alloc] init];
    });
    
    return sharedTheme;
}

+ (void)customizeAppAppearance
{
    id <SSTheme> theme = [self sharedTheme];
    
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBackgroundImage:[theme navigationBackgroundForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setBackgroundImage:[theme navigationBackgroundForBarMetrics:UIBarMetricsLandscapePhone] forBarMetrics:UIBarMetricsLandscapePhone];
    [navigationBarAppearance setShadowImage:[theme topShadow]];
    
    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone];
    
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone];
    [barButtonItemAppearance setBackgroundImage:[theme barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone];
    
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [barButtonItemAppearance setBackButtonBackgroundImage:[theme backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
    
    UISegmentedControl *segmentedAppearance = [UISegmentedControl appearance];
    [segmentedAppearance setBackgroundImage:[theme segmentedBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedAppearance setBackgroundImage:[theme segmentedBackgroundForState:UIControlStateSelected barMetrics:UIBarMetricsDefault] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [segmentedAppearance setBackgroundImage:[theme segmentedBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [segmentedAppearance setBackgroundImage:[theme segmentedBackgroundForState:UIControlStateSelected barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateSelected barMetrics:UIBarMetricsLandscapePhone];
    
    [segmentedAppearance setDividerImage:[theme segmentedDividerForBarMetrics:UIBarMetricsDefault] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedAppearance setDividerImage:[theme segmentedDividerForBarMetrics:UIBarMetricsLandscapePhone] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    UITabBar *tabBarAppearance = [UITabBar appearance];
    [tabBarAppearance setBackgroundImage:[theme tabBarBackground]];
    [tabBarAppearance setSelectionIndicatorImage:[theme tabBarSelectionIndicator]];
    [tabBarAppearance setShadowImage:[theme bottomShadow]];
    
    UIToolbar *toolbarAppearance = [UIToolbar appearance];
    [toolbarAppearance setBackgroundImage:[theme toolbarBackgroundForBarMetrics:UIBarMetricsDefault] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [toolbarAppearance setBackgroundImage:[theme toolbarBackgroundForBarMetrics:UIBarMetricsLandscapePhone] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsLandscapePhone];
    [toolbarAppearance setShadowImage:[theme bottomShadow] forToolbarPosition:UIToolbarPositionAny];
    
    UISearchBar *searchBarAppearance = [UISearchBar appearance];
    [searchBarAppearance setBackgroundImage:[theme searchBackground]];
    [searchBarAppearance setSearchFieldBackgroundImage:[theme searchFieldImage] forState:UIControlStateNormal];
    [searchBarAppearance setImage:[theme searchImageForIcon:UISearchBarIconSearch state:UIControlStateNormal] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [searchBarAppearance setImage:[theme searchImageForIcon:UISearchBarIconClear state:UIControlStateNormal] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [searchBarAppearance setImage:[theme searchImageForIcon:UISearchBarIconClear state:UIControlStateHighlighted] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
    [searchBarAppearance setScopeBarBackgroundImage:[theme searchBackground]];
    [searchBarAppearance setScopeBarButtonBackgroundImage:[theme searchScopeButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [searchBarAppearance setScopeBarButtonBackgroundImage:[theme searchScopeButtonBackgroundForState:UIControlStateSelected] forState:UIControlStateSelected];
    [searchBarAppearance setScopeBarButtonDividerImage:[theme searchScopeButtonDivider] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    
    UISlider *sliderAppearance = [UISlider appearance];
    [sliderAppearance setThumbImage:[theme sliderThumbForState:UIControlStateNormal] forState:UIControlStateNormal];
    [sliderAppearance setThumbImage:[theme sliderThumbForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [sliderAppearance setMinimumTrackImage:[theme sliderMinTrack] forState:UIControlStateNormal];
    [sliderAppearance setMaximumTrackImage:[theme sliderMaxTrack] forState:UIControlStateNormal];
    
    UIProgressView *progressAppearance = [UIProgressView appearance];
    [progressAppearance setTrackImage:[theme progressTrackImage]];
    [progressAppearance setProgressImage:[theme progressProgressImage]];
    
    UISwitch *switchAppearance = [UISwitch appearance];
    [switchAppearance setOnImage:[theme onSwitchImage]];
    [switchAppearance setOffImage:[theme offSwitchImage]];
    [switchAppearance setTintColor:[theme switchTintColor]];
    [switchAppearance setOnTintColor:[theme switchOnColor]];
    [switchAppearance setThumbTintColor:[theme switchThumbColor]];

    UIStepper *stepperAppearance = [UIStepper appearance];
    [stepperAppearance setBackgroundImage:[theme stepperBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [stepperAppearance setBackgroundImage:[theme stepperBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [stepperAppearance setBackgroundImage:[theme stepperBackgroundForState:UIControlStateDisabled] forState:UIControlStateDisabled];
    [stepperAppearance setDividerImage:[theme stepperDividerForState:UIControlStateNormal] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    [stepperAppearance setDividerImage:[theme stepperDividerForState:UIControlStateHighlighted] forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateNormal];
    [stepperAppearance setDividerImage:[theme stepperDividerForState:UIControlStateHighlighted] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateHighlighted];
    [stepperAppearance setIncrementImage:[theme stepperIncrementImage] forState:UIControlStateNormal];
    [stepperAppearance setDecrementImage:[theme stepperDecrementImage] forState:UIControlStateNormal];
    
    NSMutableDictionary *titleTextAttributes = [[NSMutableDictionary alloc] init];
    UIColor *mainColor = [theme mainColor];
    if (mainColor) {
        [titleTextAttributes setObject:mainColor forKey:UITextAttributeTextColor];
    }
    UIColor *shadowColor = [theme shadowColor];
    if (shadowColor) {
        [titleTextAttributes setObject:shadowColor forKey:UITextAttributeTextShadowColor];
        CGSize shadowOffset = [theme shadowOffset];
        [titleTextAttributes setObject:[NSValue valueWithCGSize:shadowOffset] forKey:UITextAttributeTextShadowOffset];
    }
    [navigationBarAppearance setTitleTextAttributes:titleTextAttributes];
    [barButtonItemAppearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [barButtonItemAppearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateHighlighted];
    [segmentedAppearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [searchBarAppearance setScopeBarButtonTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    
    UILabel *headerLabelAppearance = [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil];
    UIColor *accentTintColor = [theme accentTintColor];
    if (accentTintColor) {
        [sliderAppearance setMaximumTrackTintColor:accentTintColor];
        [progressAppearance setTrackTintColor:accentTintColor];
        UIBarButtonItem *toolbarBarButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil];
        [toolbarBarButtonItemAppearance setTintColor:accentTintColor];
        [tabBarAppearance setSelectedImageTintColor:accentTintColor];
    }
    UIColor *baseTintColor = [theme baseTintColor];
    if (baseTintColor) {
        [navigationBarAppearance setTintColor:baseTintColor];
        [barButtonItemAppearance setTintColor:baseTintColor];
        [segmentedAppearance setTintColor:baseTintColor];
        [tabBarAppearance setTintColor:baseTintColor];
        [toolbarAppearance setTintColor:baseTintColor];
        [searchBarAppearance setTintColor:baseTintColor];
        [sliderAppearance setThumbTintColor:baseTintColor];
        [sliderAppearance setMinimumTrackTintColor:baseTintColor];
        [progressAppearance setProgressTintColor:baseTintColor];
        [stepperAppearance setTintColor:baseTintColor];
        [headerLabelAppearance setTextColor:baseTintColor];
    } else if (mainColor) {
        [headerLabelAppearance setTextColor:mainColor];
    }
}

+ (void)customizeView:(UIView *)view
{
    id <SSTheme> theme = [self sharedTheme];
    UIColor *backgroundColor = [theme backgroundColor];
    if (backgroundColor) {
        [view setBackgroundColor:backgroundColor];
    }
}

+ (void)customizeTableView:(UITableView *)tableView
{
    id <SSTheme> theme = [self sharedTheme];
    UIImage *backgroundImage = [theme tableBackground];
    UIColor *backgroundColor = [theme backgroundColor];
    if (backgroundImage) {
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
        [tableView setBackgroundView:background];
    } else if (backgroundColor) {
        [tableView setBackgroundView:nil];
        [tableView setBackgroundColor:backgroundColor];
    }
}

+ (void)customizeTabBarItem:(UITabBarItem *)item forTab:(SSThemeTab)tab
{
    id <SSTheme> theme = [self sharedTheme];
    UIImage *image = [theme imageForTab:tab];
    if (image) {
        // If we have a regular image, set that
        [item setImage:image];
    } else {
        // Otherwise, set the finished images
        UIImage *selectedImage = [theme finishedImageForTab:tab selected:YES];
        UIImage *unselectedImage = [theme finishedImageForTab:tab selected:NO];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
    }
}

+ (void)customizeDoorButton:(UIButton *)button
{
    id <SSTheme> theme = [SSThemeManager sharedTheme];
    [button setBackgroundImage:[theme doorImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
    [button setBackgroundImage:[theme doorImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [button setBackgroundImage:[theme doorImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[theme doorImageForState:UIControlStateSelected] forState:UIControlStateSelected];
    [button setBackgroundImage:[theme doorImageForState:UIControlStateSelected | UIControlStateHighlighted] forState:UIControlStateSelected | UIControlStateHighlighted];
}

@end
