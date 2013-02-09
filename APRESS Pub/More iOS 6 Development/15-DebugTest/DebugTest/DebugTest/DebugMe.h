//
//  DebugMe.h
//  DebugTest
//
//  Created by Kevin Y. Kim on 9/25/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DebugMe : NSObject

@property (nonatomic, strong) NSString *string;

- (BOOL)isTrue;
- (BOOL)isFalse;
- (NSString *)helloWorld;

@end
