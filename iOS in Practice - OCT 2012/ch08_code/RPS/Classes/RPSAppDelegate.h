//
//  RPSAppDelegate.h
//  RPS
//
//  Created by Bear Cahill on 9/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

#define appKey @"u_aS1HNlRzCKExUZgV-fcg" // @"GKGMkGlQTV-8r_U1jsQfKg"
#define appSecret @"WvIHnQqcThuloGOxXITVFw" // @"ODEGzAbgQHCzDzkuyavpQQ"
#define masterSecret @"rhOWyvkOT7qRK7r86AqCyQ" // @"0H6qg43qRuyq54rl2TKopg"

@class RPSViewController;

@interface RPSAppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;

    RPSViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) IBOutlet RPSViewController *viewController;

+ (NSString*)base64forData:(NSData*)theData; 

@end

