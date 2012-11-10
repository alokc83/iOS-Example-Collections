/*
     File: SSPowerViewController.m
 Abstract: The controller for the Controls tab.
  Version: 1.0
 
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

#import "SSPowerViewController.h"

#import "SSLogsViewController.h"
#import "SSSpaceship.h"
#import "SSTheme.h"

@interface SSPowerViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *powerImageView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIButton *toggleButton;

@property (nonatomic) BOOL activating;
@property (nonatomic) float activationStatus;
@end

@implementation SSPowerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SSThemeManager customizeView:[self view]];
    
    id <SSTheme> theme = [SSThemeManager sharedTheme];
    UIImage *normalImage = [theme buttonBackgroundForState:UIControlStateNormal];
    if (normalImage) {
        [[self toggleButton] setBackgroundImage:normalImage forState:UIControlStateNormal];
    }
    UIImage *highlightedImage = [theme buttonBackgroundForState:UIControlStateHighlighted];
    if (highlightedImage) {
        [[self toggleButton] setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
    UIImage *disabledImage = [theme buttonBackgroundForState:UIControlStateDisabled];
    if (disabledImage) {
        [[self toggleButton] setBackgroundImage:disabledImage forState:UIControlStateDisabled];
    }
    UIColor *highlightColor = [theme highlightColor];
    if (highlightColor) {
        [[self toggleButton] setTitleColor:highlightColor forState:UIControlStateNormal];
    }
    
    [self updateStatus];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UITabBarItem *item = [[self navigationController] tabBarItem];
    [SSThemeManager customizeTabBarItem:item forTab:SSThemeTabPower];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spaceshipDidChange:) name:SSSpaceshipDidChangeNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)spaceshipDidChange:(NSNotification *)notification
{
    [self setSpaceship:[notification object]];
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLogs"]) {
        UINavigationController *navController = [segue destinationViewController];
        SSLogsViewController *controller = (SSLogsViewController *)[navController topViewController];
        [controller setSpaceship:[self spaceship]];
    }
}

- (IBAction)togglePower:(id)sender
{
    if ([[self spaceship] isPowerActive]) {
        [[self spaceship] setPowerActive:NO];
    } else {
        self.activating = YES;
        self.activationStatus = 0.0;
        [self increasePower];
    }
    [self updateStatus];
}

#pragma mark - Power

- (void)increasePower
{
    self.activationStatus += 0.01;
    if (self.activationStatus < 1.0) {
        [self performSelector:@selector(increasePower) withObject:nil afterDelay:0.01];
    } else {
        self.activating = NO;
        [[self spaceship] setPowerActive:YES];
    }
    [self updateStatus];
}

- (void)updateStatus
{
    BOOL active = [[self spaceship] isPowerActive];
    UIImage *image;
    if (active) {
        image = [UIImage animatedImageNamed:@"powerOn" duration:0.3];
    } else {
        image = [UIImage imageNamed:@"powerOff"];
    }
    [[self powerImageView] setImage:image];
    
    [[self toggleButton] setEnabled:!self.activating];
    NSString *title = (active ? NSLocalizedString(@"Deactivate", @"Deactivate") : NSLocalizedString(@"Activate", @"Activate"));
    [[self toggleButton] setTitle:title forState:UIControlStateNormal];
    [[self progressView] setHidden:!self.activating];
    [[self progressView] setProgress:self.activationStatus];
}

@end
