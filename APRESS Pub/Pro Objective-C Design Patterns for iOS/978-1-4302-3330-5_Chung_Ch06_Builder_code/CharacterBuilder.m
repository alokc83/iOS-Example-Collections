//
//  CharacterBuilder.m
//  Builder
//
//  Created by Carlo Chung on 11/27/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "CharacterBuilder.h"


@implementation CharacterBuilder

@synthesize character=character_;


- (CharacterBuilder *) buildNewCharacter
{
  // autorelease the previous character
  // before creating a new one
  [character_ autorelease];
  character_ = [[Character alloc] init];
  
  return self;
}

- (CharacterBuilder *) buildStrength:(float) value
{
  character_.strength = value;
  return self;
}

- (CharacterBuilder *) buildStamina:(float) value
{
  character_.stamina = value;
  return self;
}

- (CharacterBuilder *) buildIntelligence:(float) value
{
  character_.intelligence = value;
  return self;
}

- (CharacterBuilder *) buildAgility:(float) value
{
  character_.agility = value;
  return self;
}

- (CharacterBuilder *) buildAggressiveness:(float) value
{
  character_.aggressiveness = value;
  return self;
}

- (void) dealloc
{
  [character_ autorelease];
  [super dealloc];
}

@end
