//
//  Singleton.m
//  Singleton
//
//  Created by Carlo Chung on 6/10/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "Singleton.h"


@implementation Singleton


static Singleton *sharedSingleton_ = nil;

- (void) operation
{
  // do something
  NSLog(@"Singleton");
}

+ (Singleton *) sharedInstance
{
  if (sharedSingleton_ == nil)
  {
    sharedSingleton_ = [NSAllocateObject([self class], 0, NULL) init];
  }
  
  return sharedSingleton_;
}


+ (id) allocWithZone:(NSZone *)zone
{
  return [[self sharedInstance] retain];
}


- (id) copyWithZone:(NSZone*)zone
{
  return self;
}

- (id) retain
{
  return self;
}

- (NSUInteger) retainCount
{
  return NSUIntegerMax; // denotes an object that cannot be released
}

- (void) release
{
  // do nothing
}

- (id) autorelease
{
  return self;
}

@end
