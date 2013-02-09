//
//  Scribble.m
//  TouchPainter
//
//  Created by Carlo Chung on 9/20/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//


#import "ScribbleMemento+Friend.h"
#import "Scribble.h"
#import "Stroke.h"

// A private category for Scribble
// that contains a mark property available
// only to its objects
@interface Scribble ()

@property (nonatomic, retain) id <Mark> mark;

@end


@implementation Scribble

@synthesize mark=parentMark_;

- (id) init
{
  if (self = [super init])
  {
    // the parent should be a composite
    // object (i.e. Stroke)
    parentMark_ = [[Stroke alloc] init];
  }
  
  return self;
}

#pragma mark -
#pragma mark Methods for Mark management

- (void) addMark:(id <Mark>)aMark shouldAddToPreviousMark:(BOOL)shouldAddToPreviousMark
{
  // manual KVO invocation
  [self willChangeValueForKey:@"mark"];
  
  // if the flag is set to YES
  // then add this aMark to the 
  // *PREVIOUS*Mark as part of an
  // aggregate.
  // Based on our design, it's supposed
  // to be the last child of the main
  // parent
  if (shouldAddToPreviousMark)
  {
    [[parentMark_ lastChild] addMark:aMark];
  }
  // otherwise attach it to the parent
  else 
  {
    [parentMark_ addMark:aMark];
    incrementalMark_ = aMark;
  }
  
  // manual KVO invocation
  [self didChangeValueForKey:@"mark"];
}

- (void) removeMark:(id <Mark>)aMark
{  
  // do nothing if aMark is the parent
  if (aMark == parentMark_) return;
  
  // manual KVO invocation
  [self willChangeValueForKey:@"mark"];
  
  [parentMark_ removeMark:aMark];
  
  // we don't need to keep the 
  // incrementalMark_ reference
  // as it's just removed in the parent
  if (aMark == incrementalMark_)
  {
    incrementalMark_ = nil;
  }
  
  // manual KVO invocation
  [self didChangeValueForKey:@"mark"];
}


#pragma mark -
#pragma mark Methods for memento

- (id) initWithMemento:(ScribbleMemento*)aMemento
{
  if (self = [super init])
  {
    if ([aMemento hasCompleteSnapshot])
    {
      [self setMark:[aMemento mark]];
    }
    else 
    {
      // if the memento contains only
      // incremental mark, then we need to
      // create a parent Stroke object to 
      // hold it
      parentMark_ = [[Stroke alloc] init];
      [self attachStateFromMemento:aMemento];
    }
  }
  
  return self;
}


- (void) attachStateFromMemento:(ScribbleMemento *)memento
{
  // attach any mark from a memento object
  // to the main parent 
  [self addMark:[memento mark] shouldAddToPreviousMark:NO];
}


- (ScribbleMemento *) scribbleMementoWithCompleteSnapshot:(BOOL)hasCompleteSnapshot
{
  id <Mark> mementoMark = incrementalMark_;
  
  // if the resulting memento asks
  // for a complete snapshot, then 
  // set it with parentMark_
  if (hasCompleteSnapshot)
  {
    mementoMark = parentMark_;
  }
  // but if incrementalMark_
  // is nil then we can't do anything
  // but bail out
  else if (mementoMark == nil)
  {
    return nil;
  }
  
  ScribbleMemento *memento = [[[ScribbleMemento alloc] 
                               initWithMark:mementoMark] autorelease];
  [memento setHasCompleteSnapshot:hasCompleteSnapshot];
  
  return memento;
}


- (ScribbleMemento *) scribbleMemento
{
  return [self scribbleMementoWithCompleteSnapshot:YES];
}


+ (Scribble *) scribbleWithMemento:(ScribbleMemento *)aMemento
{
  Scribble *scribble = [[[Scribble alloc] initWithMemento:aMemento] autorelease];
  return scribble;
}


- (void) dealloc
{
  [parentMark_ release];
  [super dealloc];
}

@end
