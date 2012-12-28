//
//  BNRExecutor.m
//  Blocky
//
//  Created by joeconway on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BNRExecutor.h"

@implementation BNRExecutor
//@synthesize equation;

- (void)setEquation:(int (^)(int, int))eq
{
    equation = eq;
}

- (int)computeWithValue:(int)value1 andValue:(int)value2
{
    if(!equation)
        return 0;
        
    return equation(value1, value2);
}

- (void)dealloc
{
    NSLog(@"Executor is being destroyed.");
}

@end
