//
//  CustomBarButton.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/19/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "CommandBarButton.h"

@implementation CommandBarButton

@synthesize command=command_;


- (void) dealloc
{
  [command_ release];
  [super dealloc];
}

@end

