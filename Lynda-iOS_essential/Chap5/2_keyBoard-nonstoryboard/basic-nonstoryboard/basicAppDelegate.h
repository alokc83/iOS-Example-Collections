//
//  basicAppDelegate.h
//  basic-nonstoryboard
//
//  Created by Alix Cewall on 10/27/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class basicViewController;

@interface basicAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) basicViewController *viewController;

@end
