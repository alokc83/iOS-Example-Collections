//
//  AcmeBrandingFactory.m
//  AbstractFactory
//
//  Created by Carlo Chung on 11/1/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "AcmeBrandingFactory.h"
#import "AcmeView.h"
#import "AcmeMainButton.h"
#import "AcmeToolbar.h"


@implementation AcmeBrandingFactory

- (UIView *) brandedView
{
	// returns a custom view for Acme
	return [[[AcmeView alloc] init] autorelease];
}

- (UIButton *) brandedMainButton
{
	// returns a custom main button for Acme
	return [[[AcmeMainButton alloc] init] autorelease];
}

- (UIToolbar *) brandedToolbar
{
	// returns a custom toolbar for Acme
	return [[[AcmeToolbar alloc] init] autorelease];
}

@end
