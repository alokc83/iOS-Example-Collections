//
//  AbstractSandwich.h
//  TemplateMethod
//
//  Created by Carlo Chung on 7/31/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnySandwich : NSObject 
{

}

- (void) make;

// Steps to make a sandwich
- (void) prepareBread;
- (void) putBreadOnPlate;
- (void) addMeat;
- (void) addCondiments;
- (void) extraStep;
- (void) serve;

@end
