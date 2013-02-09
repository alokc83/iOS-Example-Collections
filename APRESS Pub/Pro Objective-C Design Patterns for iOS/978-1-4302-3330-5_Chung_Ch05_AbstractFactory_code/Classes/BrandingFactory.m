//
//  BrandingFactory.m
//  AbstractFactory
//
//  Created by Carlo Chung on 11/1/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "BrandingFactory.h"
#import "AcmeBrandingFactory.h"
#import "SierraBrandingFactory.h"


@implementation BrandingFactory

+ (BrandingFactory *) factory
{
#if defined (USE_ACME)
	return [[[AcmeBrandingFactory alloc] init] autorelease];
#elif defined (USE_SIERRA)
	return [[[SierraBrandingFactory alloc] init] autorelease];
#else
	return nil;
#endif
}

- (UIView *) brandedView
{
	return nil;
}

- (UIButton *) brandedMainButton
{
	return nil;
}

- (UIToolbar *) brandedToolbar
{
	return nil;
}

@end
