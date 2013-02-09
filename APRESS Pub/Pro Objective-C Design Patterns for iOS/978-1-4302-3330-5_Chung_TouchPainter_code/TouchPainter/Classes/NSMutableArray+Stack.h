//
//  NSMutableArray+Private.h
//  TouchPainter
//
//  Created by Carlo Chung on 10/11/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (Stack)

- (void) push:(id)object;
- (id) pop;
- (void) dropBottom;

@end
