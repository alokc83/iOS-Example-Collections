//
//  TemplateMethodAppDelegate.h
//  TemplateMethod
//
//  Created by Carlo Chung on 7/31/10.
//  Copyright Carlo Chung 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TemplateMethodViewController;

@interface TemplateMethodAppDelegate : NSObject <UIApplicationDelegate> 
{
  UIWindow *window;
  TemplateMethodViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TemplateMethodViewController *viewController;

@end

