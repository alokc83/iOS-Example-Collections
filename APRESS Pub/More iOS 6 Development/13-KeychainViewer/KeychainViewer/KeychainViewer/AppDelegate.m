//
//  AppDelegate.m
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/4/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "AppDelegate.h"
#import <Security/Security.h>
#import "KeychainCertificate.h"
#import "KeychainIdentity.h"

@interface AppDelegate ()
- (BOOL)isAnchorCertLoaded;
- (void)addAnchorCertificate;
- (void)addIdentity;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([self isAnchorCertLoaded]) {
        [self addIdentity];
        [self addAnchorCertificate];
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)isAnchorCertLoaded
{
    return ([[NSUserDefaults standardUserDefaults] valueForKey:@"anchor_certificate"] == nil);
}

- (void)addAnchorCertificate
{
    NSString *rootCertificatePath = [[NSBundle mainBundle] pathForResource:@"root" ofType:@"der"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:rootCertificatePath];
    KeychainCertificate *cert = [[KeychainCertificate alloc] initWithData:data options:nil];
    if (cert) {
        NSError *error;
        BOOL saved = [cert save:&error];
        if (!saved) {
            NSLog(@"Error Saving Certificate: %@", [error localizedDescription]);
            abort();;
        }
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cert.persistentRef forKey:@"anchor_certificate"];
        [userDefaults synchronize];
    }
}

- (void)addIdentity
{
    NSString *identityPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"p12"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:identityPath];
    NSString *password = @"@Super2048Cat";
    
    KeychainIdentity *ident = [[KeychainIdentity alloc] initWithData:data options:@{ (__bridge id)kSecImportExportPassphrase : password }];
    if (ident) {
        NSError *error;
        BOOL saved = [ident save:&error];
        if (!saved) {
            NSLog(@"Error Saving Identity: %@", [error localizedDescription]);
            abort();
        }
    }
}

@end
