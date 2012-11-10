//
//  HKCoordinate.m
//  Hikes Lite
//
//  Copyright (c) 2012 Your Organization. All rights reserved.
//

#import "HKCoordinate.h"

@implementation HKCoordinate

+ (HKCoordinate *)coordinateWithString:(NSString *)string {
    return [[self alloc] initWithString:string];
}

- (id)initWithString:(NSString *)string
{
    self = [super init];
    if (self) {
        NSArray *coordinates = [string componentsSeparatedByString:@","];
        assert([coordinates count] == 2);

    }
    return self;
}

@end
