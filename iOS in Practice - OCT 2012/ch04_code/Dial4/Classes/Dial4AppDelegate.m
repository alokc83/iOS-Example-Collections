//
//  Dial4AppDelegate.m
//  Dial4
//
//  Created by Bear Cahill on 12/21/09.
//  Copyright Brainwash Inc. 2009. All rights reserved.
//

#import "Dial4AppDelegate.h"
#import "RootViewController.h"


@implementation Dial4AppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management



@end

