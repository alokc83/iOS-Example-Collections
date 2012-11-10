
/*
     File: ZBEViewController.m
 Abstract: 
 
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

#import "ZBEViewController.h"
#import "ZBEStatusView.h"
#import "ZBEButtonCollectionView.h"
#import "ZBEMiniPadView.h"
#import "ZBEZombieMeter.h"
#import "ZBESymbolMarkView.h"
#import "ZBEHelpView.h"

typedef enum {
    kTimerEventAlmostInfiniteLoop,
    kTimerEventLogicBomb,
    kTimerEventLeak,
    kTimerEventBadProgramming,
    kTimerEventOverRetain,
    kTimerEventStagnantReleasePool,
    
} ZBETimerEvent;

@interface ZBEViewController ()

@end

@implementation ZBEViewController
{
    BOOL buttonDraggedToPad;

    // View structure
    ZBECodeScrollerView *codeScrollerView;
    ZBEZombieMeter *meterView;
    ZBEMiniPadView *miniPadView;
    ZBEStatusView *statusView;
    ZBEButtonCollectionView *buttonsView;
    ZBEHelpView *helpView;
    
    BOOL paused;
    BOOL isVoiceOverSpeaking;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    CGRect frame = self.view.frame;
    float tmp = frame.size.width;
    frame.size.width = frame.size.height;
    frame.size.height = tmp;
    frame.size.width += 20;
    self.view.frame = frame;
    
    frame = self.view.frame;
    
    //self.view.layer.borderColor = [[UIColor greenColor] CGColor];
    //self.view.layer.borderWidth = 2;
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    background.alpha = .34;
    [self.view addSubview:background];
    
    CGRect miniPadFrame = CGRectMake(350, 50, 0, 0);
    miniPadView = [[ZBEMiniPadView alloc] initWithFrame:miniPadFrame];
    [self.view addSubview:miniPadView];

    float meterWidth = 200;
    CGRect meterFrame = CGRectMake(CGRectGetMaxX(miniPadView.frame), miniPadFrame.origin.y, meterWidth, miniPadView.frame.size.height);
    meterView = [[ZBEZombieMeter alloc] initWithFrame:meterFrame];
    [self.view addSubview:meterView];
    
    CGRect statusFrame = CGRectMake(100, frame.size.height - 350, frame.size.width - 100, 100);
    statusView = [[ZBEStatusView alloc] initWithFrame:statusFrame];
    [self.view addSubview:statusView];
    statusView.status = @"Loading";
    
    CGRect buttonsFrame = CGRectMake(100, CGRectGetMaxY(statusFrame) + 20, frame.size.width - 100, 230);
    buttonsView = [[ZBEButtonCollectionView alloc] initWithFrame:buttonsFrame];
    buttonsView.delegate = self;
    [self.view addSubview:buttonsView];
    buttonsView.shouldGroupAccessibilityChildren = YES;
    
    
    CGRect questionFrame = CGRectMake(10, CGRectGetMaxY(statusFrame) + 110, 80, 80);
    ZBESymbolMarkView *questionView = [[ZBESymbolMarkView alloc] initWithFrame:questionFrame];
    [questionView addTarget:self action:@selector(questionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:questionView];
    questionView.symbol = @"?";
    questionView.accessibilityLabel = @"Help";
    
    meterView.zombieLevel = .00;
    [self goForthZombies];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voiceOverFinished:) name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
}

- (void)_voiceOverFinished:(id)notification
{
    isVoiceOverSpeaking = NO;
}

- (void)pause
{
    paused = YES;
    [miniPadView pauseZombies];
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Apocalypse on pause");
}

- (void)unpause
{
    paused = NO;
    [self zombiesOnATimer];
    [miniPadView unpauseZombies];

    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Apocalypse resumed");
}

- (void)helpDidClose:(ZBEHelpView *)view
{
    [helpView removeFromSuperview];
    helpView = nil;
    [self unpause];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, statusView);
}

- (void)togglePause
{
    if ( paused )
    {
        [self unpause];
    }
    else
    {
        [self pause];
    }
}

- (void)questionPressed:(id)sender
{
    [self pause];
    helpView = [[ZBEHelpView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:helpView];
    helpView.delegate = self;
    [helpView show];
 
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    
}

- (ZBETimerEvent)nextZombieEvent
{
    int random = rand();
    float point = (float)random/(float)RAND_MAX;
    if ( point < .03 )
    {
        return kTimerEventAlmostInfiniteLoop;
    }
    else if ( point < .10 )
    {
        return kTimerEventLogicBomb;
    }
    else if ( point < .50 )
    {
        return kTimerEventLeak;
    }
    else if ( point < .65 )
    {
        return kTimerEventBadProgramming;
    }
    else if ( point < .80 )
    {
        return kTimerEventOverRetain;
    }
    else
    {
        return kTimerEventStagnantReleasePool;
    }
}

- (NSString *)stringForZombieEvent:(ZBETimerEvent)event
{
    switch ( event )
    {
        case kTimerEventBadProgramming:
            return @"Bad programming! Too much memory used! (8MB)";
        case kTimerEventAlmostInfiniteLoop:
            return @"An infinite loop broke out! (15MB)";
        case kTimerEventLeak:
            return @"Memory leak! (3MB)";
        case kTimerEventLogicBomb:
            return @"A logic bomb went off in your code! (4MB)";
        case kTimerEventOverRetain:
            return @"An object was retained too many times (6MB)";
        case kTimerEventStagnantReleasePool:
            return @"Your release pools stopped draining! (23MB)";
    }
}

- (float)zombieFactorForEvent:(ZBETimerEvent)event
{
    switch ( event )
    {
        case kTimerEventBadProgramming:
            return .08;
        case kTimerEventAlmostInfiniteLoop:
            return .15;
        case kTimerEventLeak:
            return .03;
        case kTimerEventLogicBomb:
            return .04;
        case kTimerEventOverRetain:
            return .06;
        case kTimerEventStagnantReleasePool:
            return .23;
    }
}

- (void)monitorZombiePressure
{
    if ( meterView.zombieLevel > .99 )
    {
        exit(0);
    }
    else if ( meterView.zombieLevel > .95 )
    {
        [statusView setStatus:@"Your program is using 95% of available memory! Seek a new profession!"];
    }
    else if ( meterView.zombieLevel > .90 )
    {
        [statusView setStatus:@"Your program is using 90% of available memory! You're a goner!"];
    }
    else if ( meterView.zombieLevel > .75 )
    {
        [statusView setStatus:@"Your program is using 75% of available memory! Fix your bugs faster!"];
    }
    else if ( meterView.zombieLevel == 0 )
    {
        [statusView setStatus:@"Just like the real zombie apocalypse, this game never ends. Keep it up, the best you can home for is that you'll never stop playing!"];        
    }
}

- (void)zombiesOnATimer
{
    if ( paused )
    {
        return;
    }
    
    ZBETimerEvent eventType = [self nextZombieEvent];
    [statusView setStatus:[self stringForZombieEvent:eventType]];
    meterView.zombieLevel = meterView.zombieLevel + [self zombieFactorForEvent:eventType];

    [self monitorZombiePressure];
    [self manageVisibleZombies];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [self zombiesOnATimer];
    });
}

- (void)manageVisibleZombies
{
    float level = meterView.zombieLevel;
    NSInteger zombieCount = floor(level * 10);
    if ( zombieCount < miniPadView.zombieCount )
    {
        while ( zombieCount < miniPadView.zombieCount )
        {
            [miniPadView removeZombie];
        }
    }
    
    if ( zombieCount > miniPadView.zombieCount )
    {
        while ( zombieCount > miniPadView.zombieCount )
        {
            [miniPadView addZombie];
        }
    }
}

- (void)goForthZombies
{
    [self manageVisibleZombies];
    [statusView setStatus:@"Your program has started. The zombies are massing."];
    
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self zombiesOnATimer];        
    });
}

- (void)updateScoreForDroppedButton:(ZBEButtonView *)button
{
    ZBEButtonType buttonType = button.tag;
    float change = 0;
    switch ( buttonType )
    {
        case kButtonTypeFree:
            change = -.02;
            break;
        case kButtonTypeDealloc:
            change = -.03;
            break;
        case kButtonTypeRelease:
            change = -.1;
            break;
        case kButtonTypeAutorelease:
            change = -.05;
            break;
        case kButtonTypeGC:
            change = .1;
            break;
        case kButtonTypeARC:
            change = -.1;
            break;
        default:
            break;
    }
    
    meterView.zombieLevel = meterView.zombieLevel + change;

    
    [self monitorZombiePressure];
    [self manageVisibleZombies];
}

- (void)buttonSelected:(ZBEButtonView *)button
{
    if ( !isVoiceOverSpeaking )
    {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Memory selected, drag to zombies to deploy");
    }
}

- (void)buttonDragged:(ZBEButtonView *)button location:(UITouch *)location
{
    CGPoint point = [location locationInView:miniPadView];
    if ( [miniPadView pointInside:point withEvent:nil] )
    {
        if ( !buttonDraggedToPad )
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:1];
            miniPadView.layer.borderColor = [[UIColor yellowColor] CGColor];
            miniPadView.layer.borderWidth = 2;
            [CATransaction commit];
            
            buttonDraggedToPad = YES;
            
            if ( !isVoiceOverSpeaking )
            {
                isVoiceOverSpeaking = YES;
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Memory object near the zombies. Lift to deploy.");
            }
        }
    }
    else
    {
        if ( buttonDraggedToPad )
        {
            if ( !isVoiceOverSpeaking )
            {
                isVoiceOverSpeaking = YES;
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Memory object outside iPad. Lift to cancel.");
            }
        }
        buttonDraggedToPad = NO;
        miniPadView.layer.borderWidth = 0;
    }
    
}

- (void)buttonFinished:(ZBEButtonView *)button trackingView:(UIView *)trackingView location:(UITouch *)location
{
    double delayInSeconds = 0;

    buttonDraggedToPad = NO;
    miniPadView.layer.borderWidth = 0;
    
    CGPoint point = [location locationInView:miniPadView];
    if ( [miniPadView pointInside:point withEvent:nil] )
    {
        [self updateScoreForDroppedButton:button];
        
        [UIView animateWithDuration:.1 animations:^{
            [trackingView setTransform:CGAffineTransformMakeRotation(10 * M_PI/180)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 animations:^{
                [trackingView setTransform:CGAffineTransformMakeRotation(-10 * M_PI/180)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.1 animations:^{
                    [trackingView setTransform:CGAffineTransformMakeRotation(10 * M_PI/180)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:.1 animations:^{
                        [trackingView setTransform:CGAffineTransformMakeRotation(-10 * M_PI/180)];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:.1 animations:^{
                            [trackingView setTransform:CGAffineTransformMakeRotation(0)];
                        }];
                    }];
                }];
            }];
        }];
        delayInSeconds = .5;
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.35 animations:^{
            CGRect bounds = trackingView.bounds;
            bounds.size = CGSizeMake(10, 10);
            [trackingView setBounds:bounds];
        } completion:^(BOOL finished) {
            [trackingView removeFromSuperview];
        }];
    });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ( interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight )
    {
        return YES;
    }
    return NO;
}

@end
