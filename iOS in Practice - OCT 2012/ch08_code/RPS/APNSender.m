//
//  APNSender.m
//  RPS
//
//  Created by Bear Cahill on 9/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "APNSender.h"


@implementation APNSender

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

+(NSString*)HTTPPost:(NSString *)urlString body:(NSString*)body; 
{
	NSData *postData = [body dataUsingEncoding:NSASCIIStringEncoding 
                          allowLossyConversion:YES];
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest 
                                       requestWithURL:url 
                                       cachePolicy:NSURLRequestReturnCacheDataElseLoad 
                                       timeoutInterval:10.0];
    
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setValue:@"application/json; charset=utf-8" 
      forHTTPHeaderField:@"Content-Type"];	
	[urlRequest setHTTPBody:postData];
   
    NSString *keySecret = [NSString stringWithFormat:@"%@:%@",
						   appKey,
						   masterSecret];
    NSString *base64KeySecret = [RPSAppDelegate base64forData:
                                 [keySecret dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest addValue:[NSString stringWithFormat:@"Basic %@", base64KeySecret] 
      forHTTPHeaderField:@"Authorization"];
	
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest 
                                    returningResponse:&response 
                                                error:&error];
	
	if (!urlData)
		return @"";

	NSString *dataString = [[NSString alloc] initWithData:urlData 
                                                  encoding:NSASCIIStringEncoding];
    return dataString;
}


+(void)sendAPNWithMsg:(NSString*)msg;
{
    // HTTP POST to /api/push/broadcast/
//    {
//        "aps": {
//            "badge": 15,
//            "alert": "Hello from Urban Airship!",
//            "sound": "cat.caf"
//        },
//        "exclude_tokens": [
//                           "device token you want to skip",
//                           "another device token you want to skip"
//                           ]
//    }
//
//

    NSString *url = @"https://go.urbanairship.com/api/push/broadcast/";
    NSString *payload = [NSString 
						 stringWithFormat:@"{\"aps\":{\"alert\":\"%@\"}}", msg];
    
    NSString *resp = [APNSender HTTPPost:url body:payload];
    NSLog(@"Response: %@", resp);
}
            


@end
