//
//  ImageShadowFilter.m
//  Decorator
//
//  Created by Carlo Chung on 11/30/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ImageShadowFilter.h"


@implementation ImageShadowFilter

- (void) apply
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // set up shadow
  CGSize offset = CGSizeMake (-25,  15);
  CGContextSetShadow(context, offset, 20.0);
}

@end
