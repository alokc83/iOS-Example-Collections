//
//  Min2MidnightViewController.m
//  MinutesToMidnight
//
//  Created by Katie on 2/18/13.
//  Copyright (c) 2013 AC. All rights reserved.
//

#import "Min2MidnightViewController.h"

@interface Min2MidnightViewController ()

@end



@implementation Min2MidnightViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLabel
{
    
    //NSTimeInterval secondsPerDay = 24 * 60 * 60;
   
    //[_countdownLabel setText:@"Timer is here"];
    
}



@end
