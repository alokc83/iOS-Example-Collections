//
//  VCAbout.m
//  PicDecor
//
//  Created by Bear Cahill on 1/11/10.
//  Copyright 2010 Brainwash Inc.. All rights reserved.
//

#import "VCAbout.h"

#define BOOKLINK @"http://brainwashinc.wordpress.com/iphone-dev-book/"

@implementation VCAbout

-(IBAction)doDoneBtn:(id)sender;
{
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)doBookBtn:(id)sender;
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:BOOKLINK]];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
