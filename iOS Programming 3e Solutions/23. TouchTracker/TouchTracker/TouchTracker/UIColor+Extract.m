//
//  UIColor+Extract.m
//  TouchTracker
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIColor+Extract.h"
@implementation UIColor (Extract)

- (void)extract_getRed:(float *)r green:(float *)g blue:(float *)b
{
    // Get the Core Graphics representation
    CGColorRef cgClr = [self CGColor];
    // Get each component of the color ("color channels")
    const CGFloat *components = CGColorGetComponents(cgClr);
    // Get the number of components
    size_t componentCount = CGColorGetNumberOfComponents(cgClr);
    if (componentCount == 2) {
        // A grayscale color will only have two components,
        // the grayscale value and the alpha channel
        // Assign the values pointed to by r, g, b to
        // the grayscale value
        *r = components[0];
        *g = components[0];
        *b = components[0];
    } else if (componentCount == 4) {
        // A RGB color has 4 components, r, g, b
        // and an alpha channel
        *r = components[0];
        *g = components[1];
        *b = components[2];
    } else {
        NSLog(@"Unsupported colorspace.");
        *r = *g = *b = 0;
    }
}
- (UIColor *)extract_invertedColor
{
    // Use method you just defined to get components of color
    float r = 0, g = 0, b = 0;
    [self extract_getRed:&r green:&g blue:&b];
    // Return a new UIColor instance with inverted components
    return [UIColor colorWithRed:1.0 - r
    green:1.0 - g
 blue:1.0 - b
alpha:1.0];
}
@end
