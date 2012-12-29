//
//  RPSAppDelegate.m
//  RPS
//
//  Created by Bear Cahill on 9/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import "RPSAppDelegate.h"

#import "RPSViewController.h"

@implementation RPSAppDelegate


@synthesize window;

@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
     
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

    [[UIApplication sharedApplication]
        registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                            UIRemoteNotificationTypeSound |
                                            UIRemoteNotificationTypeAlert)];
    
    return YES;
}

+ (NSString*)base64forData:(NSData*)theData; 
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error Server Response: %@", 
          [error userInfo]);
}


- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response 
{
    NSLog(@"Server Response: %@\nStatus Code: %d", 
          [(NSHTTPURLResponse *)response allHeaderFields],
          [(NSHTTPURLResponse *)response statusCode]);
}

- (void)application:(UIApplication *)app 
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
	NSString *stringToken = [[[[deviceToken description]
			stringByReplacingOccurrencesOfString: @"<" withString: @""] 
			stringByReplacingOccurrencesOfString: @">" withString: @""] 
			stringByReplacingOccurrencesOfString: @" " withString: @""];
	
    NSLog(@"stringToken: %@",stringToken);
    
    NSString *UAServer = @"https://go.urbanairship.com/api/device_tokens/";
    NSString *urlString = [NSString stringWithFormat:@"%@%@/", 
                           UAServer, stringToken];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"PUT"];
    
    NSString *keySecret = [NSString stringWithFormat:@"%@:%@",
                            appKey,
                            appSecret];
    NSString *base64KeySecret = [RPSAppDelegate base64forData:
                                 [keySecret dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest addValue:[NSString stringWithFormat:@"Basic %@", base64KeySecret] 
      forHTTPHeaderField:@"Authorization"];
    
	NSLog(@"Sending auth request...");
    [[NSURLConnection connectionWithRequest:urlRequest delegate:self] start];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
     NSLog(@"APN Registration Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"APN: %@", [userInfo description]);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"APN" 
                                                    message: [userInfo description]
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

    // Save data if appropriate.
}


@end

