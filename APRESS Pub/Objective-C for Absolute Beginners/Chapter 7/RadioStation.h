//
//  RadioStation.h
//  RadioSimulation
//
//  Created by Mitch Fisher on 6/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RadioStation : NSObject {
    NSString *name;
    double    frequency;
    char      band;
}

+ (double)minAMFrequency;
+ (double)maxAMFrequency;
+ (double)minFMFrequency;
+ (double)maxFMFrequency;

- (id)initWithName:(NSString*)newName
       atFrequency:(double)newFreq;

@end
