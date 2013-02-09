//
//  Hotdog.h
//  TemplateMethod
//
//  Created by Carlo Chung on 7/31/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnySandwich.h"

@interface Hotdog : AnySandwich 
{
  
}

- (void) prepareBread;
- (void) addMeat;
- (void) addCondiments;
//- (void) extraStep;

// Hotdog specific methods
- (void) getHotdogBun;
- (void) addWiener;
- (void) addKetchup;
- (void) addMustard;
- (void) addOnion;

@end
