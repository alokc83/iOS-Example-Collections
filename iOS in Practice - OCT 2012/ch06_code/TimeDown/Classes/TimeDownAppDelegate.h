//
//  TimeDownAppDelegate.h
//  TimeDown
//
//  Created by Bear Cahill on 8/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeDownViewController;

@interface TimeDownAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TimeDownViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TimeDownViewController *viewController;

@end

