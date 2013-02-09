//
//  MetalArmor.m
//  ChainOfResponsibility
//
//  Created by Carlo Chung on 11/28/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "MetalArmor.h"
#import "SwordAttack.h"

@implementation MetalArmor

- (void) handleAttack:(Attack *)attack
{
  if ([attack isKindOfClass:[SwordAttack class]])
  {
    // no damage beyond this armor
    NSLog(@"%@", @"No damage from a sword attack!");
  }
  else 
  {
    NSLog(@"I don't know this attack: %@", [attack class]);
    [super handleAttack:attack];
  }
}

@end
