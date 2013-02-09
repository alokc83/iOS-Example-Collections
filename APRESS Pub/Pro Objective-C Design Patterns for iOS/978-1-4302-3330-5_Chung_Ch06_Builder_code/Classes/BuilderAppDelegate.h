//
//  BuilderAppDelegate.h
//  Builder
//
//  Created by Carlo Chung on 11/27/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuilderViewController;

@interface BuilderAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BuilderViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BuilderViewController *viewController;

@end

