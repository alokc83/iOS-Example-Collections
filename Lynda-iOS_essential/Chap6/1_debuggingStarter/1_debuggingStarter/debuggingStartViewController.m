//
//  debuggingStartViewController.m
//  1_debuggingStarter
//
//  Created by Alix Cewall on 10/28/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "debuggingStartViewController.h"

@interface debuggingStartViewController ()

@end

@implementation debuggingStartViewController

@synthesize myLabel;

- (IBAction) setLabel
{
    NSLog(@"I m here");
    [myLabel setText:@"Some new value"];
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
