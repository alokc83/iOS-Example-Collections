//
//  FacadeAppDelegate.h
//  Facade
//
//  Created by Carlo Chung on 11/15/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FacadeViewController;

@interface FacadeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FacadeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FacadeViewController *viewController;

@end

