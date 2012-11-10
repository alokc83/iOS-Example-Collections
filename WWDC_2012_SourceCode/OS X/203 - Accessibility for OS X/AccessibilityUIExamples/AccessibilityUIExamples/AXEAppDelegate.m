/*
 
     File: AXEAppDelegate.m
 Abstract: Application delegate.
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

#import "AXEAppDelegate.h"
#import "AXEViewController.h"

#define AXE_CONFIGURATION_NAME  @"Configuration"
#define AXE_CONTROLLERS_KEY     @"Controllers"
#define AXE_CONTROLLER_KEY      @"Controller"
#define AXE_CLASS_KEY           @"Class"
#define AXE_TITLE_KEY           @"Title"
#define AXE_NIB_KEY             @"Nib"
#define AXE_HIDE_KEY            @"Hide"

@implementation AXEAppDelegate

@synthesize viewControllers = mViewControllers;
@synthesize demoViewArea = mDemoViewArea;

- (void)awakeFromNib
{
    [self loadConfiguration];
    [super awakeFromNib];
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] setIgnoresMouseEvents:NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [mViewControllers setSelectionIndex:[[mViewControllers arrangedObjects] count]-1];
    [mViewControllers setSelectionIndex:0];

}

- (void)unloadCurrentDemoView
{
    for ( NSView *subview in [mDemoViewArea subviews] )
    {
        [subview removeFromSuperview];
    }
}

- (void)showViewWithController:(AXEViewController *)controller
{
    if ( [controller isEqualTo:mCurrentController] )
    {
        return;
    }
    
    [self unloadCurrentDemoView];
    
    NSView *view = [controller view];
    if ( view != nil )
    {
        [[self demoViewArea] addSubview:view];
    }
    mCurrentController = controller;
    
    [[self window] recalculateKeyViewLoop];
}

- (void)showSelectedViewController
{
    NSMutableDictionary *controllerInfo = [[[self viewControllers] selectedObjects] lastObject];
    AXEViewController *selectedController = [controllerInfo objectForKey:AXE_CONTROLLER_KEY];
    
    if ( selectedController == nil )
    {
        NSString *className = [controllerInfo objectForKey:AXE_CLASS_KEY];
        Class class = NSClassFromString(className);
        selectedController = (AXEViewController *)[[class alloc] init];
        
        if ( selectedController != nil )
        {
            [controllerInfo setObject:selectedController forKey:AXE_CONTROLLER_KEY];
        }
    }
    [self showViewWithController:selectedController];
}

- (void)loadConfiguration
{
    if ( mConfigLoaded )
    {
        return;
    }
    mConfigLoaded = YES;
    NSString *configPath = [[NSBundle mainBundle] pathForResource:AXE_CONFIGURATION_NAME ofType:@"plist"];
    
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
    NSArray *controllers = [config objectForKey:AXE_CONTROLLERS_KEY];
    for ( NSDictionary *controller in controllers )
    {
        if ( [[controller objectForKey:AXE_HIDE_KEY] boolValue] )
        {
            continue;
        }
        
        NSString *title = [controller objectForKey:AXE_TITLE_KEY];

        NSString *className = [controller objectForKey:AXE_CLASS_KEY];
        if ( [className length] > 0 && [title length] > 0 )
        {
            Class class = NSClassFromString(className);
            if ( class != nil )
            {
                NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:title, AXE_TITLE_KEY, className, AXE_CLASS_KEY, nil];
                [[self viewControllers] addObject:entry];
            }
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *) notification
{
    [self showSelectedViewController];
}


@end
