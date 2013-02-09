//
//  NumberInputValidator.h
//  Strategy
//
//  Created by Carlo Chung on 8/2/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InputValidator.h"

@interface NumericInputValidator : InputValidator
{

}

// A validation method that makes sure the input only contains
// numbers i.e. 0-9
- (BOOL) validateInput:(UITextField *)input error:(NSError **) error;

@end
