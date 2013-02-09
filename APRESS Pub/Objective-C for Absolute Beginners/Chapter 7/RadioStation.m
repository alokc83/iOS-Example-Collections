//
//  RadioStation.m
//  RadioSimulation
//
//  Created by Mitch Fisher on 6/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RadioStation.h"


@implementation RadioStation

+ (double)minAMFrequency {
	return 520.0;
}

+ (double)maxAMFrequency {
	return 1610.0;
}

+ (double)minFMFrequency {
	return 88.3;
}

+ (double)maxFMFrequency {
	return 107.9;
}

- (id)initWithName:(NSString *)newName atFrequency:(double)newFreq {
    self = [super init];
    if (self != nil) {
        name = [newName retain];
        frequency = newFreq;
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Frequency: %.1f", name, frequency];
}

- (void)dealloc {
    [name release];
    [super dealloc];
}

@end
