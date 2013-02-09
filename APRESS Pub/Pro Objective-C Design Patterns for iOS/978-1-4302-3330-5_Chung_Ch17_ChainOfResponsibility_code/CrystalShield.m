//
//  CrystalShield.m
//  ChainOfResponsibility
//
//  Created by Carlo Chung on 11/28/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "CrystalShield.h"
#import "MagicFireAttack.h"

@implementation CrystalShield

- (void) handleAttack:(Attack *)attack
{
  if ([attack isKindOfClass:[MagicFireAttack class]])
  {
    // no damage beyond this shield
    NSLog(@"%@", @"No damage from a magic fire attack!");
  }
  else 
  {
    NSLog(@"I don't know this attack: %@", [attack class]);
    [super handleAttack:attack];
  }
}

@end
