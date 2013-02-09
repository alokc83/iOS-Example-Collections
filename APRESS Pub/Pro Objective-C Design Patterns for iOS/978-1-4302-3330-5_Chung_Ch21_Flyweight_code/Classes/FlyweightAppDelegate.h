//
//  FlyweightAppDelegate.h
//  Flyweight
//
//  Created by Carlo Chung on 11/28/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlyweightViewController;

@interface FlyweightAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    FlyweightViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FlyweightViewController *viewController;

@end

