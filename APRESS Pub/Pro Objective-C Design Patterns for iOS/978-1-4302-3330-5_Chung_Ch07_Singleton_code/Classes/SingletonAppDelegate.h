//
//  SingletonAppDelegate.h
//  Singleton
//
//  Created by Carlo Chung on 6/10/10.
//  Copyright Carlo Chung 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingletonAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

