//
//  AbstractFactoryAppDelegate.h
//  AbstractFactory
//
//  Created by Carlo Chung on 11/1/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AbstractFactoryViewController;

@interface AbstractFactoryAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AbstractFactoryViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AbstractFactoryViewController *viewController;

@end

