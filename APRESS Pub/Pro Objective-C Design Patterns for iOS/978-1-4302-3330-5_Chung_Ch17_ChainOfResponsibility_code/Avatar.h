//
//  Avatar.h
//  ChainOfResponsibility
//
//  Created by Carlo Chung on 11/28/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttackHandler.h"

@interface Avatar : AttackHandler
{

}

// overridden method
- (void) handleAttack:(Attack *)attack;

@end
