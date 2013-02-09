//
//  ReubenSandwich.h
//  TemplateMethod
//
//  Created by Carlo Chung on 7/31/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnySandwich.h"

@interface ReubenSandwich : AnySandwich 
{

}

- (void) prepareBread;
- (void) addMeat;
- (void) addCondiments;
- (void) extraStep;

// ReubenSandwich's specific operations
- (void) cutRyeBread;
- (void) addCornBeef;
- (void) addSauerkraut;
- (void) addThousandIslandDressing;
- (void) addSwissCheese;
- (void) grillIt;

@end
