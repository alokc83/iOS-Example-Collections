//
//  WhereAmIParkedAppDelegate.h
//  WhereAmIParked
//
//  Created by Bear Cahill on 1/29/10.
//  Copyright Brainwash Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WhereAmIParkedViewController;

@interface WhereAmIParkedAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    WhereAmIParkedViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WhereAmIParkedViewController *viewController;

@end

