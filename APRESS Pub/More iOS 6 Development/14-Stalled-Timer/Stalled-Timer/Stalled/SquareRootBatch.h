//
//  SquareRootBatch.h
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SquareRootBatch : NSObject

@property (assign, nonatomic) NSInteger max;
@property (assign, nonatomic) NSInteger current;

- (id)initWithMaxNumber:(NSInteger)maxNumber;
- (BOOL)hasNext;
- (double)next;
- (float)percentCompleted;
- (NSString *)percentCompletedText;

@end
