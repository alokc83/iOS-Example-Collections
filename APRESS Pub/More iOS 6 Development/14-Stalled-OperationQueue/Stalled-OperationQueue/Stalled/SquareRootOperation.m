//
//  SquareRootOperation.m
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import "SquareRootOperation.h"

@implementation SquareRootOperation

- (id)initWithMaxNumber:(NSInteger)maxNumber delegate:(id<SquareRootOperationDelegate>)aDelegate
{
    if (self = [super init]) {
        self.max = maxNumber;
        self.current = 0;
        self.delegate = aDelegate;
    }
    return self;
}

- (float)percentComplete
{
    return (float)self.current / (float)self.max;
}

- (NSString *)progressString
{
    if ([self isCancelled])
        return @"Cancelled...";
    if (![self isExecuting])
        return @"Waiting...";
    
    return [NSString stringWithFormat:@"Completed %d of %d", self.current, self.max];
}

- (void)main
{
    @try {
        @autoreleasepool {
            NSTimeInterval lastUIUpdate = [NSDate timeIntervalSinceReferenceDate];
            while (!self.isCancelled && self.current < self.max) {
                self.current++;
                double squareRoot = sqrt((double)self.current);
                NSLog(@"Operation %@ reports the square root of %d is %.6f", self, self.current, squareRoot);
                if (self.current % kBatchSize == 0) {
                    if ([NSDate timeIntervalSinceReferenceDate] > lastUIUpdate + kUpdateFrequency) {
                        if ([(NSObject *)self.delegate respondsToSelector:@selector(operationProgressChanged:)]) {
                            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(operationProgressChanged:) withObject:self waitUntilDone:NO];
                        }
                        [NSThread sleepForTimeInterval:0.05];
                        lastUIUpdate = [NSDate timeIntervalSinceReferenceDate];
                    }
                }
            }
        }
    }
    @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }
}

@end
