//
//  Command.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/19/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "Command.h"


@implementation Command
@synthesize userInfo=userInfo_;

- (void) execute
{
  // should throw an exception.
}

- (void) undo
{
  // do nothing
  // subclasses need to override this
  // method to perform actual undo.
}

- (void) dealloc
{
  [userInfo_ release];
  [super dealloc];
}

@end
