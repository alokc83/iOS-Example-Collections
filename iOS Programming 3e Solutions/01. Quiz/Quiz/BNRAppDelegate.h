//
//  BNRAppDelegate.h
//  Quiz
//
//  Created by Michael Ward on 5/9/12.
//  Copyright (c) 2012 Big Nerd Ranch, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BNRViewController;

@interface BNRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BNRViewController *viewController;

@end
