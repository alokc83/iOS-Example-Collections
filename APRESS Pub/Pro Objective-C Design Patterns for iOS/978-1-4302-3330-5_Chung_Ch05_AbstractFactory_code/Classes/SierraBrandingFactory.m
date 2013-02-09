//
//  SierraBrandingFactory.m
//  AbstractFactory
//
//  Created by Carlo Chung on 11/16/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "SierraBrandingFactory.h"
#import "SierraView.h"
#import "SierraMainButton.h"
#import "SierraToolbar.h"

@implementation SierraBrandingFactory

- (UIView*) brandedView
{
	// returns a custom view for Sierra
	return [[[SierraView alloc] init] autorelease];
}

- (UIButton*) brandedMainButton
{
	// returns a custom main button for Sierra
	return [[[SierraMainButton alloc] init] autorelease];
}

- (UIToolbar*) brandedToolbar
{
	// returns a custom toolbar for Sierra
	return [[[SierraToolbar alloc] init] autorelease];
}

@end