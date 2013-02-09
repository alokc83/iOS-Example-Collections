//
//  ReubenSandwich.m
//  TemplateMethod
//
//  Created by Carlo Chung on 7/31/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ReubenSandwich.h"


@implementation ReubenSandwich

- (void) prepareBread
{
  [self cutRyeBread];
}

- (void) addMeat
{
  [self addCornBeef];
}

- (void) addCondiments
{
  [self addSauerkraut];
  [self addThousandIslandDressing];
  [self addSwissCheese];
}

- (void) extraStep
{
  [self grillIt];
}

#pragma mark -
#pragma mark ReubenSandwich Specific Methods

- (void) cutRyeBread
{
  // A Reuben sandwich requires two slices of rye bread
}

- (void) addCornBeef
{
  // ... add tons of corn beef
}

- (void) addSauerkraut
{
  // ... and sauerkraut.
}

- (void) addThousandIslandDressing
{
  // ... don't forget to put Thousand Island dressing
}

- (void) addSwissCheese
{
  // ... as well as some good Swiss cheese.
}

- (void) grillIt
{
  // finally it needs to be toasted.
}

@end
