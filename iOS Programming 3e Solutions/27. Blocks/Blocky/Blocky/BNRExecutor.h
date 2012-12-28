//
//  BNRExecutor.h
//  Blocky
//
//  Created by joeconway on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRExecutor : NSObject
{
    int (^equation)(int, int);
}

//@property (nonatomic, copy) int (^equation)(int, int);
- (void)setEquation:(int (^)(int, int))eq;
- (int)computeWithValue:(int)value1 andValue:(int)value2;

@end
