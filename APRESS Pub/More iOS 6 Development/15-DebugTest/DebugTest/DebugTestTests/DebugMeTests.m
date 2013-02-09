//
//  DebugMeTests.m
//  DebugTest
//
//  Created by Kevin Y. Kim on 9/25/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#import "DebugMeTests.h"

@implementation DebugMeTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.debugMe = [[DebugMe alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    self.debugMe = nil;
    
    [super tearDown];
}

- (void)testDebugMeHasStringProperty
{
    STAssertTrue([self.debugMe respondsToSelector:@selector(string)], @"expected DebugMe to have 'string' selector");
}

- (void)testDebugMeIsTrue
{
    BOOL result = [self.debugMe isTrue];
    STAssertTrue(result, @"expected DebugMe isTrue to be true, got %@", result);
}

- (void)testDebugMeIsFalse
{
    BOOL result = [self.debugMe isFalse];
    STAssertFalse(result, @"expected DebugMe isFalse to be false, got %@", result);
}

- (void)testDebugMeHelloWorld
{
    NSString *result = [self.debugMe helloWorld];
//    STAssertEqualObjects(result, @"Hello, World!", @"expected DebugMe helloWorld to be 'Hello, World!', got '%@'", result);
    STAssertEquals(result, @"Hello, World!", @"expected DebugMe helloWorld to be 'Hello, World!', got '%@'", result);
}

@end
