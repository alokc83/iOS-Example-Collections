//
//  MinutesToMidnightAppDelegate.m
//  MinutesToMidnight
//
//  Created by apple on 10/1/08.
//  Copyright Amuck LLC 2008. All rights reserved.
//

#import "MinutesToMidnightAppDelegate.h"
#import "MinutesToMidnightViewController.h"

@implementation MinutesToMidnightAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];	
    [window addSubview:viewController.view];
	[window makeKeyAndVisible];
}

- (void)onTimer {
	[viewController updateLabel];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[timer invalidate];
}

- (void)dealloc {
	[timer release];
    [viewController release];
	[window release];
	[super dealloc];
}


@end
