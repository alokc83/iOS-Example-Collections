//
//  Line.m
//  TouchTracker
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Line.h"

@implementation Line
@synthesize begin, end, color;
- (id)init 
{
    self = [super init];
    if(self) {
        [self setColor:[UIColor blackColor]];
    }
    return self;
}
@end
