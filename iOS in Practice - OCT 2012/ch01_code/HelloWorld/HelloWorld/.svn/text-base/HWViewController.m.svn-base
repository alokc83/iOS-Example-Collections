//
//  HWViewController.m
//  HelloWorld
//
//  Created by Bear Cahill on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HWViewController.h"

@implementation HWViewController
@synthesize lblHelloWorld;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setLblHelloWorld:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)doBtnHide:(id)sender {
    [lblHelloWorld setHidden:![lblHelloWorld isHidden]];
    [sender setTitle:[lblHelloWorld isHidden] ? @"Show" : @"Hide" forState:UIControlStateNormal];
}
@end
