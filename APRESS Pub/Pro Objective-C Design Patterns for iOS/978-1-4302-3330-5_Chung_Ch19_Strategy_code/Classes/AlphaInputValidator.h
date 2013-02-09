//
//  AlphaInputValidator.h
//  Strategy
//
//  Created by Carlo Chung on 8/2/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InputValidator.h"


@interface AlphaInputValidator : InputValidator
{

}

// A validation method that makes sure the input only 
// contains letters only i.e. a-z A-Z
- (BOOL) validateInput:(UITextField *)input error:(NSError **) error;

@end
