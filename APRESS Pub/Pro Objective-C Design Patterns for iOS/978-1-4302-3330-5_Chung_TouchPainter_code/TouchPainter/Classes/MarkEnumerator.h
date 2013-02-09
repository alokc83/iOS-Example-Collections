//
//  MarkEnumerator.h
//  TouchPainter
//
//  Created by Carlo Chung on 1/6/11.
//  Copyright 2011 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+Stack.h"
#import "Mark.h"

@interface MarkEnumerator : NSEnumerator
{
  @private
  NSMutableArray *stack_;
}

- (NSArray *)allObjects;
- (id)nextObject;

@end
