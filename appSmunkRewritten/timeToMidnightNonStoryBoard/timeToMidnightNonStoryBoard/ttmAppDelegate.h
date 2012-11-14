//
//  ttmAppDelegate.h
//  timeToMidnightNonStoryboard
//
//  Created by Alix Cewall on 11/13/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ttmViewController;

@interface ttmAppDelegate : UIResponder <UIApplicationDelegate>{
    
    NSTimer *timer;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ttmViewController *viewController;

// for timer
-(void) onTimer;

@end
