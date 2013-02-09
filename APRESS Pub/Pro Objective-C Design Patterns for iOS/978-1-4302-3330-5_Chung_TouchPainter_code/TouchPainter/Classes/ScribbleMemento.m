//
//  ScirbbleMemento.m
//  TouchPainter
//
//  Created by Carlo Chung on 9/27/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ScribbleMemento.h"
#import "ScribbleMemento+Friend.h"

@implementation ScribbleMemento

@synthesize mark=mark_;
@synthesize hasCompleteSnapshot=hasCompleteSnapshot_;

- (NSData *) data
{
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mark_];
  return data;
}

+ (ScribbleMemento *) mementoWithData:(NSData *)data
{
  // It raises an NSInvalidArchiveOperationException if data is not a valid archive
  id <Mark> retoredMark = (id <Mark>)[NSKeyedUnarchiver unarchiveObjectWithData:data];
  ScribbleMemento *memento = [[[ScribbleMemento alloc] 
                               initWithMark:retoredMark] autorelease];
  
  return memento;
}

- (void) dealloc
{
  [mark_ release];
  [super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (id) initWithMark:(id <Mark>)aMark
{
  if (self = [super init])
  {
    [self setMark:aMark];
  }
  
  return self;
}

@end
