//
//  CommandSlider.m
//  TouchPainter
//
//  Created by Carlo Chung on 11/9/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "CommandSlider.h"


@implementation CommandSlider

@synthesize command=command_;

- (void) dealloc
{
  [command_ release];
  [super dealloc];
}

@end
