//
//  InputValidator.h
//  Strategy
//
//  Created by Carlo Chung on 2/15/11.
//  Copyright 2011 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const InputValidationErrorDomain = @"InputValidationErrorDomain";

@interface InputValidator : NSObject 
{

}

// A stub for any actual validation strategy
- (BOOL) validateInput:(UITextField *)input error:(NSError **) error;

@end
