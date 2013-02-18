//
//  MinutesToMidnightAppDelegate.h
//  MinutesToMidnight
//
//  Created by apple on 10/1/08.
//  Copyright Amuck LLC 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MinutesToMidnightViewController;

@interface MinutesToMidnightAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet MinutesToMidnightViewController *viewController;
	NSTimer *timer;
}
-(void)onTimer;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) MinutesToMidnightViewController *viewController;

@end

