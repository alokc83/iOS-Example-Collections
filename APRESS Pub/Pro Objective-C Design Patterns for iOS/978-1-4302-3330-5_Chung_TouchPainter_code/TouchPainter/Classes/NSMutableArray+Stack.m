//
//  NSMutableArray+Private.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/11/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "NSMutableArray+Stack.h"


@implementation NSMutableArray (Stack)

- (void) push:(id)object
{
  if (object != nil)
    [self addObject:object];
}

- (id) pop
{
  if ([self count] == 0) return nil;
  
  id object = [[[self lastObject] retain] autorelease];
  [self removeLastObject];
  
  return object;
}

- (void) dropBottom
{
  if ([self count] == 0) return;
  
  [self removeObjectAtIndex:0];
}

@end
