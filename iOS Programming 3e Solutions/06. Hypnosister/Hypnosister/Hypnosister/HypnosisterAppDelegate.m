//
//  HypnosisterAppDelegate.m
//  Hypnosister
//
//  Created by joeconway on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HypnosisterAppDelegate.h"
#import "HypnosisView.h"
// Challenge:
//#import "LogoView.h"

@implementation HypnosisterAppDelegate

@synthesize window = _window;

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return view;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                        withAnimation:UIStatusBarAnimationFade];
    
    CGRect screenRect = [[self window] bounds];
    
    // Create the UIScrollView to have the size of the window, matching its size
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:screenRect];
    [scrollView setMaximumZoomScale:5];
    [scrollView setDelegate:self];
    [[self window] addSubview:scrollView];

    // Create the HypnosisView with a frame that is twice the size of the screen
    CGRect bigRect = screenRect;

    view = [[HypnosisView alloc] initWithFrame:screenRect];
    // Add the HypnosisView as a subview of the scrollView instead of the window
    [scrollView addSubview:view];
    
    // Challenge:
    //LogoView *lv = [[LogoView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //[view addSubview:lv];
    
    // Tell the scrollView how big its subview is
    [scrollView setContentSize:bigRect.size];

    BOOL success = [view becomeFirstResponder];
    if(success) {
        NSLog(@"HypnosisView became the first responder");
    } else {
        NSLog(@"Could not become first responder");
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
