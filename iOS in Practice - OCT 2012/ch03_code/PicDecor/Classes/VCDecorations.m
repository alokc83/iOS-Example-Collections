//
//  VCDecorations.m
//  PicDecor
//
//  Created by Bear Cahill on 12/20/09.
//  Copyright 2009 Brainwash Inc.. All rights reserved.
//

#import "VCDecorations.h"

@implementation VCDecorations

@synthesize selectedImage;

-(IBAction)doImageBtn:(id)sender;
{
	[selectedImage release];
	selectedImage = [[sender backgroundImageForState:UIControlStateNormal] retain];
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)doCancelBtn:(id)sender;
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
	[selectedImage release];
}


@end
