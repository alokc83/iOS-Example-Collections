//
//  SquareRootOperation.h
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBatchSize       100
#define kUpdateFrequency 0.5

@class SquareRootOperation;

@protocol SquareRootOperationDelegate
- (void)operationProgressChanged:(SquareRootOperation *)operation;
@end

@interface SquareRootOperation : NSOperation

@property (assign, nonatomic) NSInteger max;
@property (assign, nonatomic) NSInteger current;
@property (strong, nonatomic) id<SquareRootOperationDelegate> delegate;

- (id)initWithMaxNumber:(NSInteger)maxNumber delegate:(id<SquareRootOperationDelegate>)aDelegate;
- (float)percentComplete;
- (NSString *)progressString;

@end
