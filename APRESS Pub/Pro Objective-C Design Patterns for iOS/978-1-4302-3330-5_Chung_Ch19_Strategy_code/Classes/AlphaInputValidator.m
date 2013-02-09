//
//  AlphaInputValidator.m
//  Strategy
//
//  Created by Carlo Chung on 8/2/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "AlphaInputValidator.h"

@implementation AlphaInputValidator



- (BOOL) validateInput:(UITextField *)input error:(NSError **) error
{
  NSRegularExpression *regex = [NSRegularExpression 
                                 regularExpressionWithPattern:@"^[a-zA-Z]*$"
                                 options:NSRegularExpressionAnchorsMatchLines 
                                 error:nil];
  
  NSUInteger numberOfMatches = [regex 
                                numberOfMatchesInString:[input text]
                                options:NSMatchingAnchored
                                range:NSMakeRange(0, [[input text] length])];
  
  // If there is not a single match
  // then return an error and NO
  if (numberOfMatches == 0)
  {
    if (error != nil) 
    {
      NSString *description = NSLocalizedString(@"Input Validation Failed", @"");
      NSString *reason = NSLocalizedString(@"The input can only contain letters", @"");
      
      NSArray *objArray = [NSArray arrayWithObjects:description, reason, nil];
      NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,
                           NSLocalizedFailureReasonErrorKey, nil];
      
      NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray
                                                           forKeys:keyArray];
      *error = [NSError errorWithDomain:InputValidationErrorDomain
                                   code:1002
                               userInfo:userInfo];
    }

    return NO;
  }
  
  return YES;
}

@end
