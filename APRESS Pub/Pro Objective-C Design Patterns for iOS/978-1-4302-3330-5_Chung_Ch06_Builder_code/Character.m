//
//  Character.m
//  Builder
//
//  Created by Carlo Chung on 11/27/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "Character.h"


@implementation Character

@synthesize protection=protection_;
@synthesize power=power_;
@synthesize strength=strength_;
@synthesize stamina=stamina_;
@synthesize intelligence=intelligence_;
@synthesize agility=agility_;
@synthesize aggressiveness=aggressiveness_;

- (id) init
{
  if (self = [super init])
  {
    protection_ = 1.0;
    power_ = 1.0;
    strength_ = 1.0;
    stamina_ = 1.0;
    intelligence_ = 1.0;
    agility_ = 1.0;
    aggressiveness_ = 1.0;
  }
  
  return self;
}

@end
