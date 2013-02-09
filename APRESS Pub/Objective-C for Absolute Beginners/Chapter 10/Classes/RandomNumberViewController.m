//
//  RandomNumberViewController.m
//  RandomNumber
//
//  Created by Gary Bennett on 7/2/10.
//  Copyright xcelme.com 2010. All rights reserved.
//

#import "RandomNumberViewController.h"

@implementation RandomNumberViewController

@synthesize randNumber;//getter and setter methods (i.e. accessor)


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	randNumber = nil;// set outlets to nil with the view gets unloaded
}
- (IBAction)generate:(id)sender
{
	// Generate a number between 0 and 100 inclusive
	int generated;
	generated = (random() % 101);
	[randNumber setText:[NSString stringWithFormat:@"%i",generated]];
}

- (IBAction)seed:(id)sender
{
	srandom(time(NULL));
	[randNumber setText: @"Generator seeded"];
}

- (void)dealloc {
	[randNumber release];
	[super dealloc];
}


@end

