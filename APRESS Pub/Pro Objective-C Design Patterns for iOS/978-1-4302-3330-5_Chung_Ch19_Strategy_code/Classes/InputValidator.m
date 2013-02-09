//
//  InputValidator.m
//  Strategy
//
//  Created by Carlo Chung on 2/15/11.
//  Copyright 2011 Carlo Chung. All rights reserved.
//

#import "InputValidator.h"


@implementation InputValidator

// A stub for any actual validation strategy
- (BOOL) validateInput:(UITextField *)input error:(NSError **) error
{
  if (error)
  {
    *error = nil;
  }
  
  return NO;
}

@end
