//
//  ChasingGame.m
//  Builder
//
//  Created by Carlo Chung on 11/27/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ChasingGame.h"


@implementation ChasingGame

- (Character *) createPlayer:(CharacterBuilder *) builder
{
  [builder buildNewCharacter];
  [builder buildStrength:50.0];
  [builder buildStamina:25.0];
  [builder buildIntelligence:75.0];
  [builder buildAgility:65.0];
  [builder buildAggressiveness:35.0];
  
  // an alternative way to build a character
  [[[[[[builder buildNewCharacter]
       buildStrength:50.0]
      buildStamina:25.0]
     buildIntelligence:75.0]
    buildAgility:65.0]
   buildAggressiveness:35.0];
  
  return [builder character];
}

- (Character *) createEnemy:(CharacterBuilder *) builder
{
  [builder buildNewCharacter];
  [builder buildStrength:80.0];
  [builder buildStamina:65.0];
  [builder buildIntelligence:35.0];
  [builder buildAgility:25.0];
  [builder buildAggressiveness:95.0];
  
  return [builder character];
}

@end
