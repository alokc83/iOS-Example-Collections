//
//  ImageFilter.m
//  Decorator
//
//  Created by Carlo Chung on 11/30/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ImageFilter.h"


@implementation ImageFilter

@synthesize component=component_;


- (id) initWithImageComponent:(id <ImageComponent>) component
{
  if (self = [super init])
  {
    // save an ImageComponent
    [self setComponent:component];
  }
  
  return self;
}

- (void) apply
{
  // should be overridden by subclasses
  // to apply real filters
}

- (id) forwardingTargetForSelector:(SEL)aSelector
{
  NSString *selectorName = NSStringFromSelector(aSelector);
  if ([selectorName hasPrefix:@"draw"])
  {
    [self apply];
  }
  
  return component_;
}

/*
- (void) drawAsPatternInRect:(CGRect)rect
{
  [self apply];
  [component_ drawAsPatternInRect:rect];
}

- (void) drawAtPoint:(CGPoint)point
{
  [self apply];
  [component_ drawAtPoint:point];
}

- (void) drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
  [self apply];
  [component_ drawAtPoint:point
                blendMode:blendMode
                    alpha:alpha];
}

- (void) drawInRect:(CGRect)rect
{
  [self apply];
  [component_ drawInRect:rect];
}

- (void) drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
  [self apply];
  [component_ drawInRect:rect
               blendMode:blendMode
                   alpha:alpha];
}
*/



@end
