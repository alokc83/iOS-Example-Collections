//
//  DecoratorAppDelegate.h
//  Decorator
//
//  Created by Carlo Chung on 11/15/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DecoratorViewController;

@interface DecoratorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    DecoratorViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DecoratorViewController *viewController;

@end

