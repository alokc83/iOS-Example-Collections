//
//  StrategyAppDelegate.h
//  Strategy
//
//  Created by Carlo Chung on 8/2/10.
//  Copyright Carlo Chung 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StrategyViewController;

@interface StrategyAppDelegate : NSObject <UIApplicationDelegate> 
{
  UIWindow *window;
  StrategyViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet StrategyViewController *viewController;

@end

