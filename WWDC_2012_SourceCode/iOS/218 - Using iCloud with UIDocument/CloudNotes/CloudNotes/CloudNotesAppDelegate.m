
/*
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
 
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
 
 
 WWDC 2012 License 
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012 
 Session. Please refer to the applicable WWDC 2012 Session for further 
 information. 
 
 IMPORTANT: This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
 
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a non-exclusive license, under 
 Apple's copyrights in this original Apple software (the "Apple 
 Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
 
 */ 


#import "CloudNotesAppDelegate.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "CloudManager.h"

@interface CloudNotesAppDelegate ()
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@end


@implementation CloudNotesAppDelegate
{
    UIView* _waitingHudView;
}

- (void)checkUbiquitousTokenFromPreviousLaunch:(id)currentToken
{
    // Fetch a previously stored value for the ubiquity identity token from NSUserDefaults.
    // That value can be compared to the current token to determine if the iCloud login has changed since the last launch of our application
    
    NSData* oldTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.apple.CloudNotes.UbiquityIdentityToken"];
    id oldToken = oldTokenData ? [NSKeyedUnarchiver unarchiveObjectWithData:oldTokenData] : nil;
    if (oldTokenData && ![oldToken isEqual:currentToken]) {
        // If we had a token, we were signed in before.
        // If the token has change, a signout has occurred - either switching to another account or deleting iCloud entirely.
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"iCloud Sign-Out" message:@"You have signed out of the iCloud account previously used to store documents. Sign back in to access those documents" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)storeCurrentUbiquityToken:(id)currentToken
{
    // Write the ubquity identity token to NSUserDefaults if it exists.
    // Otherwise, remove the key.
    
    if (currentToken) {
        NSData* newTokenData = [NSKeyedArchiver archivedDataWithRootObject:currentToken];
        [[NSUserDefaults standardUserDefaults] setObject:newTokenData forKey:@"com.apple.CloudNotes.UbiquityIdentityToken"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"com.apple.CloudNotes.UbiquityIdentityToken"];
    }
}

- (void)checkUserICloudPreferenceAndSetupIfNecessary
{
    // Check to see whether the user has previously selected the iCloud storage option.
    // If so, check the iCloud storage state from previous launch.
    // If the user has previously chosen to use iCloud and we're still signed in, setup the CloudManager with cloud storage enabled.
    // If no user choice is recorded, use a UIAlert to fetch the user's preference.
    
    id currentToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* userICloudChoice = [userDefaults stringForKey:@"com.apple.CloudNotes.UseICloudStorage"];
    
    if ([userICloudChoice isEqualToString:@"YES"]) {
        [self checkUbiquitousTokenFromPreviousLaunch:currentToken];
    }
    
    if (currentToken) {
        if ([userICloudChoice length] == 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Choose Storage Option" message:@"Should documents be stored in iCloud or on just this device?" delegate:self cancelButtonTitle:@"Local only" otherButtonTitles:@"iCloud", nil];
            [alert show];
        }
        else if ([userICloudChoice isEqualToString:@"YES"]) {            
            [[CloudManager sharedManager] setIsCloudEnabled:YES];
        }
    }
    else {
        [[CloudManager sharedManager] setIsCloudEnabled:NO];
        
        // Since the user is signed out of iCloud, reset the preference to not use iCloud, so if they sign in again we will prompt them to move data
        [userDefaults removeObjectForKey:@"com.apple.CloudNotes.UseICloudStorage"];
    }
    
    [self storeCurrentUbiquityToken:currentToken];
}

- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"com.apple.CloudNotes.UseICloudStorage"];
        [[CloudManager sharedManager] setIsCloudEnabled:YES];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"com.apple.CloudNotes.UseICloudStorage"];
        [[CloudManager sharedManager] setIsCloudEnabled:NO];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Right away check the user's iCloud storage preference and register for relevant notifications.
    
    [self checkUserICloudPreferenceAndSetupIfNecessary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBeginFetchingUbiquitousContainer) name:UbiquitousContainerFetchingWillBeginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndFetchingUbiquitousContainer) name:UbiquitousContainerFetchingDidEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserICloudPreferenceAndSetupIfNecessary) name:NSUbiquityIdentityDidChangeNotification object:nil];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        RootViewController *controller = [[RootViewController alloc] initWithNibName:@"RootViewController_iPhone" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        self.window.rootViewController = self.navigationController;
    } else {
        RootViewController *controller = [[RootViewController alloc] initWithNibName:@"RootViewController_iPad" bundle:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil];
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, detailViewController, nil];
        
        self.window.rootViewController = self.splitViewController;
    }
    [self.window makeKeyAndVisible];    
    return YES;
}

- (void)displayWaitingHud
{
    if (!_waitingHudView) {
        _waitingHudView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        _waitingHudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        CGRect hudBounds = _waitingHudView.bounds;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"Waiting for iCloud setup...";
        [label sizeToFit];
        CGSize labelSize = label.frame.size;
        label.frame = CGRectMake((CGRectGetWidth(hudBounds) - labelSize.width) / 2.0, (CGRectGetHeight(hudBounds) - labelSize.height) / 2.0, labelSize.width, labelSize.height);
        [_waitingHudView addSubview:label];
        [[[UIApplication sharedApplication] keyWindow] addSubview:_waitingHudView];
    }
}

- (void)willBeginFetchingUbiquitousContainer
{
    [self performSelector:@selector(displayWaitingHud) withObject:nil afterDelay:0.15];
}

- (void)didEndFetchingUbiquitousContainer
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayWaitingHud) object:nil];
    [_waitingHudView removeFromSuperview];
}

@end
