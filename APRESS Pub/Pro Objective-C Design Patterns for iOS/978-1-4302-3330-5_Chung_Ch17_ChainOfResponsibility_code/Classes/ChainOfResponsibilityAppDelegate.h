//
//  ChainOfResponsibilityAppDelegate.h
//  ChainOfResponsibility
//
//  Created by Carlo Chung on 11/28/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChainOfResponsibilityViewController;

@interface ChainOfResponsibilityAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ChainOfResponsibilityViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ChainOfResponsibilityViewController *viewController;

@end

