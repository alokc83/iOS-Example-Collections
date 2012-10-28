//
//  AlertMeViewController.m
//  3_AlertMe
//
//  Created by Alix Cewall on 10/28/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "AlertMeViewController.h"

@interface AlertMeViewController ()

@end

@implementation AlertMeViewController

- (void)viewDidLoad
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Here is the alert Title"
                                                    message:@"Here is the alert Message"
                                                   delegate:nil //defineing delegate here
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil]; //if other button is needed
    [alert show];
    [alert release];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
