//
//  BridgeAppDelegate.h
//  Bridge
//
//  Created by Carlo Chung on 11/26/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BridgeViewController;

@interface BridgeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BridgeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BridgeViewController *viewController;

@end

