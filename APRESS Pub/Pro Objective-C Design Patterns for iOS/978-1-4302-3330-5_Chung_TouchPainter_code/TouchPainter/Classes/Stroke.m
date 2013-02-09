//
//  Stroke.m
//  Composite
//
//  Created by Carlo Chung on 9/9/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "Stroke.h"
#import "MarkEnumerator+Internal.h"

@implementation Stroke

@synthesize color=color_, size=size_;
@dynamic location;

- (id) init
{
  if (self = [super init])
  {
    children_ = [[NSMutableArray alloc] initWithCapacity:5];
  }
  
  return self;
}

- (void) setLocation:(CGPoint)aPoint
{
  // it doesn't set any arbitrary location
}

- (CGPoint) location
{
  // return the location of the first child
  if ([children_ count] > 0)
  {
    return [[children_ objectAtIndex:0] location];
  }
  
  // otherwise returns the origin
  return CGPointZero;
}

- (void) addMark:(id <Mark>) mark
{
  [children_ addObject:mark];
}

- (void) removeMark:(id <Mark>) mark
{
  // if mark is at this level then
  // remove it and return
  // otherwise, let every child
  // search for it
  if ([children_ containsObject:mark])
  {
    [children_ removeObject:mark];
  }
  else 
  {
    [children_ makeObjectsPerformSelector:@selector(removeMark:)
                               withObject:mark];
  }
}


- (id <Mark>) childMarkAtIndex:(NSUInteger) index
{
  if (index >= [children_ count]) return nil;
  
  return [children_ objectAtIndex:index];
}


// a convenience method to return the last child
- (id <Mark>) lastChild
{
  return [children_ lastObject];
}

// returns number of children
- (NSUInteger) count
{
  return [children_ count];
}


- (void) acceptMarkVisitor:(id <MarkVisitor>)visitor
{
  for (id <Mark> dot in children_)
  {
    [dot acceptMarkVisitor:visitor];
  }
  
  [visitor visitStroke:self];
}

- (void) dealloc
{
  [color_ release];
  [children_ release];
  [super dealloc];
}

#pragma mark -
#pragma mark NSCopying method


- (id)copyWithZone:(NSZone *)zone
{
  Stroke *strokeCopy = [[[self class] allocWithZone:zone] init];
  
  // copy the color
  [strokeCopy setColor:[UIColor colorWithCGColor:[color_ CGColor]]];
  
  // copy the size
  [strokeCopy setSize:size_];
  
  // copy the children
  for (id <Mark> child in children_)
  {
    id <Mark> childCopy = [child copy];
    [strokeCopy addMark:child];
    [childCopy release];
  }
  
  return strokeCopy;
}

#pragma mark -
#pragma mark NSCoder methods

- (id)initWithCoder:(NSCoder *)coder
{
  if (self = [super init])
  {
    color_ = [[coder decodeObjectForKey:@"StrokeColor"] retain];
    size_ = [coder decodeFloatForKey:@"StrokeSize"];
    children_ = [[coder decodeObjectForKey:@"StrokeChildren"] retain];
  }
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
  [coder encodeObject:color_ forKey:@"StrokeColor"];
  [coder encodeFloat:size_ forKey:@"StrokeSize"];
  [coder encodeObject:children_ forKey:@"StrokeChildren"];
}

#pragma mark -
#pragma mark enumerator methods

- (NSEnumerator *) enumerator
{
  return [[[MarkEnumerator alloc] initWithMark:self] autorelease];
}

- (void) enumerateMarksUsingBlock:(void (^)(id <Mark> item, BOOL *stop)) block
{
  BOOL stop = NO;
  
  NSEnumerator *enumerator = [self enumerator];
  
  for (id <Mark> mark in enumerator)
  {
    block (mark, &stop);
    if (stop)
      break;
  }
}

#pragma mark -
#pragma mark An Extended Direct-draw Example

// for a direct draw example
- (void) drawWithContext:(CGContextRef)context
{
  CGContextMoveToPoint(context, self.location.x, self.location.y);
  
  for (id <Mark> mark in children_)
  {
    [mark drawWithContext:context];
  }
  
  CGContextSetLineWidth(context, self.size);
  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetStrokeColorWithColor(context,[self.color CGColor]);
  CGContextStrokePath(context);
}

@end
