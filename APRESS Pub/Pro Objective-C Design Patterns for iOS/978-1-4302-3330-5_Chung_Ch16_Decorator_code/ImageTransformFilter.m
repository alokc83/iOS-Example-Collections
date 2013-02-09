//
//  ImageTransformFilter.m
//  Decorator
//
//  Created by Carlo Chung on 11/30/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ImageTransformFilter.h"

@implementation ImageTransformFilter

@synthesize transform=transform_;


- (id) initWithImageComponent:(id <ImageComponent>)component 
                    transform:(CGAffineTransform)transform
{
  if (self = [super initWithImageComponent:component])
  {
    [self setTransform:transform];
  }
  
  return self;
}

- (void) apply
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // setup transformation
  CGContextConcatCTM(context, transform_);
}

@end
