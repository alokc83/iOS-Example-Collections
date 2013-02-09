//
//  AcmeMainButton.m
//  AbstractFactory
//
//  Created by Carlo Chung on 11/1/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "AcmeMainButton.h"


@implementation AcmeMainButton

- (id) init
{
	if (self = [super init])
	{
		[self setTitle:@"Acme" forState:UIControlStateNormal];
	}
	
	return self;
}

- (void) awakeFromNib
{
	[self init];
	
	return;
}

@end
