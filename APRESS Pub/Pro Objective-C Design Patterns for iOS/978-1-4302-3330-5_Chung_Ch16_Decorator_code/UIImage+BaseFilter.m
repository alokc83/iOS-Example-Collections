//
//  UIImage+BaseFilter.m
//  Decorator
//
//  Created by Carlo Chung on 11/15/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "UIImage+BaseFilter.h"


@implementation UIImage (BaseFilter)

- (CGContextRef) beginContext
{
  // Create a graphics context with the target size
  // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions 
  // to take the scale into consideration
  // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
  CGSize size = [self size];
  if (NULL != UIGraphicsBeginImageContextWithOptions)
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  else
    UIGraphicsBeginImageContext(size);
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  return context;
}

- (UIImage *) getImageFromCurrentImageContext
{
  [self drawAtPoint:CGPointZero];
  
  // Retrieve the UIImage from the current context
  UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
  
  return imageOut;
}

- (void) endContext
{
  UIGraphicsEndImageContext();
}

@end
