//
//  APNSender.h
//  RPS
//
//  Created by Bear Cahill on 9/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPSAppDelegate.h"


@interface APNSender : NSObject {
    
}

+(void)sendAPNWithMsg:(NSString*)msg;

@end
