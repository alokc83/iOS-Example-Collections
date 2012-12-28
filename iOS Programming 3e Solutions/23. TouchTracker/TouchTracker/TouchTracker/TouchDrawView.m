//
//  TouchDrawView.m
//  TouchTracker
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchDrawView.h"
#import "Line.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Extract.h"

@interface TouchDrawView ()
- (void)transformLineColorsWithBlock:(UIColor * (^)(Line *))t;
- (void)colorize;
@end

@implementation TouchDrawView

- (void)transformLineColorsWithBlock:(UIColor * (^)(Line *))colorForLine
{
    [completeLines enumerateObjectsUsingBlock:^(id line, NSUInteger idx, BOOL *stop) {
            [(Line *)line setColor:colorForLine(line)];
    }];
    [self setNeedsDisplay];
}

- (void)colorize
{
    // Vertical means more red, horizontal means more green, 
    // longer means more blue
    
    // A block variable named colorScheme is created here:
    UIColor * (^colorScheme)(Line *) = ^(Line *l) {
        // Compute delta between begin and end points
        // for each component
        float dx = [l end].x - [l begin].x;
        float dy = [l end].y - [l begin].y;

        // If dx is near zero, red = 1, otherwise, use slope
        float r = (fabs(dx) < 0.001 ? 1.0 : fabs(dy / dx));
        
        // If dy is near zero, green = 1, otherwise, use inv. slope
        float g = (fabs(dy) > 0.001 ? 1.0 : fabs(dx / dy));
        
        // blue = length over 300
        float b = hypot(dx, dy) / 300.0;

        return [UIColor colorWithRed:r green:g blue:b alpha:1];
    };
    
    // Pass this colorScheme block to the method
    // that will iterate over every line and assign
    // the computed color to that line
    [self transformLineColorsWithBlock:colorScheme];
}
- (BOOL)canBecomeFirstResponder
{
    return YES; 
}
- (void)didMoveToWindow
{
    [self becomeFirstResponder];
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self colorize];
}
- (id)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];
    
    if (self) {
        linesInProcess = [[NSMutableDictionary alloc] init];
        
        // Don't let the autocomplete fool you on the next line,
        // make sure you are instantiating an NSMutableArray
        // and not an NSMutableDictionary!
        completeLines = [[NSMutableArray alloc] init];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self setMultipleTouchEnabled:YES];

[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [[NSNotificationCenter defaultCenter] 
            addObserverForName:UIDeviceOrientationDidChangeNotification 
                        object:nil 
                         queue:nil 
                    usingBlock: ^(NSNotification * note) {
                        [self transformLineColorsWithBlock:^(Line *l) {
                            // Note that extract_invertedColor doesn't
                            // exist yet, you will implement this soon.
                            return [[l color] extract_invertedColor];
                        }];
                    }];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {

        // Is this a double tap?
        if ([t tapCount] > 1) {
            [self clearAll];
            return;
        }

        // Use the touch object (packed in an NSValue) as the key
        NSValue *key = [NSValue valueWithNonretainedObject:t];

        // Create a line for the value
        CGPoint loc = [t locationInView:self];
        Line *newLine = [[Line alloc] init];
        [newLine setBegin:loc];
        [newLine setEnd:loc];

        // Put pair in dictionary
        [linesInProcess setObject:newLine forKey:key];
    }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    // Update linesInProcess with moved touches
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];

        // Find the line for this touch
        Line *line = [linesInProcess objectForKey:key];

        // Update the line
        CGPoint loc = [t locationInView:self];
        [line setEnd:loc];
    }
    // Redraw
    [self setNeedsDisplay];
}

- (void)endTouches:(NSSet *)touches
{
    // Remove ending touches from dictionary
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = [linesInProcess objectForKey:key];
        // If this is a double tap, 'line' will be nil,
        // so make sure not to add it to the array
        if (line) {
            [completeLines addObject:line];
            [linesInProcess removeObjectForKey:key];
        }
    }
    // Redraw
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}
- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)clearAll
{
// Create a new layer that obscures the whole view
    CALayer *fadeLayer = [CALayer layer];
    [fadeLayer setBounds:[self bounds]];
    [fadeLayer setPosition:
        CGPointMake([self bounds].size.width / 2.0,
                    [self bounds].size.height / 2.0)];
    [fadeLayer setBackgroundColor:[[self backgroundColor] CGColor]];
    // Add this layer to the layer hierarchy on top of
    // the view's layer
    [[self layer] addSublayer:fadeLayer];
    // Create an animation that fades this layer in over 1 sec.
    CABasicAnimation *animation = [CABasicAnimation
                            animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:0]];
    [animation setToValue:[NSNumber numberWithFloat:1]];
    [animation setDuration:1];
    [CATransaction begin];
        // Set the completion block of this transaction
        // this method requires a block that returns no
        // value and accepts no argument: (void (^)(void))
        [CATransaction setCompletionBlock:^(void)
        {
            // When the animation completes, remove
            // the fadeLayer from the layer hierarchy
            [fadeLayer removeFromSuperlayer];
            // Also remove any completed or in process
            // lines
            [linesInProcess removeAllObjects];
            [completeLines removeAllObjects];
            // Redisplay the view after lines are removed
            [self setNeedsDisplay];
        }];
        [fadeLayer addAnimation:animation forKey:@"Fade"];
    [CATransaction commit];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    // Draw complete lines in black


    for (Line *line in completeLines) {
        [[line color] set];
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    }
    // Draw lines in process in red (don't copy and paste the previous for loop, it's
    // way different)
    [[UIColor redColor] set];
    for (NSValue *v in linesInProcess) {
        Line *line = [linesInProcess objectForKey:v];
        CGContextMoveToPoint(context, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(context, [line end].x, [line end].y);
        CGContextStrokePath(context);
    } 
}
@end
