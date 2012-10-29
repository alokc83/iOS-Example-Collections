//
//  ControlsViewController.m
//  1_Controls
//
//  Created by Alix Cewall on 10/28/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "ControlsViewController.h"

@interface ControlsViewController ()

@end

@implementation ControlsViewController
@synthesize colorChooser, sampleText;

- (IBAction)colorChanged {
    
    if (colorChooser.selectedSegmentIndex == 0) sampleText.textColor = [UIColor blackColor];
    if (colorChooser.selectedSegmentIndex == 1) sampleText.textColor = [UIColor blueColor];
    if (colorChooser.selectedSegmentIndex == 2) sampleText.textColor = [UIColor redColor];
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
