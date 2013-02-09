//
//  TouchPainterAppDelegate.h
//  TouchPainter
//
//  Created by Carlo Chung on 8/21/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoordinatingController.h"

@interface TouchPainterAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

