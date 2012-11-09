//
//  whayDayViewController.m
//  2_whatDay
//
//  Created by Alix Cewall on 11/8/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "whayDayViewController.h"

@interface whayDayViewController ()

@end

@implementation whayDayViewController

@synthesize dp;

- (IBAction) displayDay {
    
    NSDate *chosen = dp.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    
    NSString *weekday = [formatter stringFromDate:chosen];
    NSString *msg = [[NSString alloc] initWithFormat:@"That's a %@", weekday];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"What day is that?"
                          message:msg delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles:nil];
    
    [alert show];
    
    [alert release];
    [msg release];
    [formatter release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
