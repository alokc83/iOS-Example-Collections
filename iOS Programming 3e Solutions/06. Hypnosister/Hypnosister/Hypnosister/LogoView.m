//
//  LogoView.m
//  Hypnosister
//
//  Created by joeconway on 8/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LogoView.h"

@implementation LogoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage *img = [UIImage imageNamed:@"Icon@2x.png"];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    float maxRadius = hypot(bounds.size.width, bounds.size.height) / 3.0;
    
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, center.x, center.y, maxRadius, 0.0, M_PI * 2.0, YES);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 2, [[UIColor blackColor] CGColor]);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    CGContextAddArc(ctx, center.x, center.y, maxRadius, 0.0, M_PI * 2.0, YES);
    CGContextClip(ctx);
    
    [img drawInRect:bounds];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat components[8] = {0.8, 0.8, 1, 1, 0.8, 0.8, 1, 0};
    CGFloat locs[2] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locs, 2);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(bounds.size.width / 2.0, 0), CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0), kCGGradientDrawsBeforeStartLocation);

    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
}


@end
