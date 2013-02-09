//
//  CustomAnnotation.m
//  Polyline Example
//
//  Created by Giacomo Andreucci on 22/11/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

@synthesize coordinate, title, subtitle;

//Implement the initialization method

- (id)initWithLocation:(CLLocationCoordinate2D)coords title:(NSString *)aTitle andSubtitle:(NSString*)aSubtitle

{
	self = [super init];
    coordinate = coords;
	title = aTitle;
    subtitle = aSubtitle;
	return self;
}

@end