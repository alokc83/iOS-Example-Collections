//
//  SSTintedTheme.m
//  Spaceship
//
//  Created by Jacob Xiao on 5/30/12.
//  Copyright (c) 2012 Apple, Inc. All rights reserved.
//

#import "SSTintedTheme.h"

@implementation SSTintedTheme

- (UIColor *)baseTintColor
{
    return [UIColor colorWithHue:(1.0 / 3.0) saturation:0.75 brightness:0.5 alpha:1.0];
}

- (UIColor *)accentTintColor
{
    return [UIColor colorWithHue:(1.0 / 6.0) saturation:1.0 brightness:0.85 alpha:1.0];
}

- (UIColor *)mainColor
{
    return [self accentTintColor];
}

- (UIColor *)backgroundColor
{
    return [UIColor colorWithHue:(1.0 / 6.0) saturation:0.15 brightness:1.0 alpha:1.0];
}

- (UIColor *)switchOnColor
{
    return [self baseTintColor];
}

- (UIColor *)switchTintColor
{
    return [self accentTintColor];
}

@end
