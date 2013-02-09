//
//  Avatar.m
//  ChainOfResponsibility
//
//  Created by Carlo Chung on 11/28/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "Avatar.h"


@implementation Avatar

- (void) handleAttack:(Attack *)attack
{
  // when an attack reaches this point,
  // I'm hit.
  // actual points taken off depends on
  // the type of attack.
  NSLog(@"Oh! I'm hit with a %@!", [attack class]);
}


@end
