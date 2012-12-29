//
//  TimeDownAppDelegate.m
//  TimeDown
//
//  Created by Bear Cahill on 8/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TimeDownAppDelegate.h"
#import "TimeDownViewController.h"

@implementation TimeDownAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSObject *timeSettings = [settings objectForKey:@"timeSettings"];
	
	if (nil == timeSettings)
	{		
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"5" forKey:@"timeSettings"];
		[settings registerDefaults:appDefaults];
		[settings synchronize];	
	}
	
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}




@end
