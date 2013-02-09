//
//  RandomNumberAppDelegate.h
//  RandomNumber
//
//  Created by Gary Bennett on 7/2/10.
//  Copyright xcelme.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RandomNumberViewController;

@interface RandomNumberAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RandomNumberViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RandomNumberViewController *viewController;

@end

