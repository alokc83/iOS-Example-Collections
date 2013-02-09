//
//  SquareRootBatch.m
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import "SquareRootBatch.h"

#define kExceededMaxException @"Exceeded Max"

@implementation SquareRootBatch

- (id)initWithMaxNumber:(NSInteger)maxNumber
{
    self = [super init];
    if (self) {
        self.current = 0;
        self.max = maxNumber;
    }
    return self;
}

- (BOOL)hasNext
{
    return self.current <= self.max;
}

- (double)next
{
    if (self.current > self.max)
        [NSException raise:kExceededMaxException format:@"Requested a calculation from completed batch"];
    
    return sqrt((double)++self.current);
}

- (float)percentCompleted
{
    return (float)self.current / (float)self.max;
}

- (NSString *)percentCompletedText
{
    return [NSString stringWithFormat:@"Square Root of %d is %.6f", self.current, sqrt((double)self.current)];
}

@end
