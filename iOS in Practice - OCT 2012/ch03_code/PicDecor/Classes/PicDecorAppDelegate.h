//
//  PicDecorAppDelegate.h
//  PicDecor
//
//  Created by Bear Cahill on 12/20/09.
//  Copyright Brainwash Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PicDecorViewController;

@interface PicDecorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PicDecorViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PicDecorViewController *viewController;

@end

