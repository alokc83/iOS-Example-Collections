//
//  ttmViewController.m
//  timeToMidnight
//
//  Created by Alix Cewall on 11/13/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "ttmViewController.h"

@interface ttmViewController ()

@end

@implementation ttmViewController

- (void)viewDidLoad
{
    [_countdownLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:60.0]];
	_countdownLabel.text = @"I0A0IN6";
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLabel
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    //NSTimeInterval ttm = [[NSdate alloc] initWithTimeInterval:<#(NSTimeInterval)#> sinceDate:<#(NSDate *)#>]
    
   // NSDate *tomorrow = [[NSdate alloc] initWithTimeIntervalSinceNow:ttm];
    NSDate * now = [NSDate date];
    int hours = 23 - now.timeIntervalSinceNow;
   // hours = [now timeIntervalSinceDate:tomorrow];
    int minutes = 59 - now.timeIntervalSinceNow;
    int seconds = 59 - now.timeIntervalSinceNow;
    _countdownLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    //countdownLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min,sec];
}

@end
