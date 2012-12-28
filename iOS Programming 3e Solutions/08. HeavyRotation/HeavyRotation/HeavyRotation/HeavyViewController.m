//
//  HeavyViewController.m
//  HeavyRotation
//
//  Created by joeconway on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HeavyViewController.h"

@implementation HeavyViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)x 
{
    // Return YES if incoming orientation is Portrait
    // or either of the Landscapes, otherwise, return NO
    return (x == UIInterfaceOrientationPortrait)
        ||  UIInterfaceOrientationIsLandscape(x);
}

@end
