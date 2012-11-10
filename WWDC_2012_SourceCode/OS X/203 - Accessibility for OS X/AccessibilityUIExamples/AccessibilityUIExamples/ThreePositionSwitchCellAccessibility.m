/*
 
     File: ThreePositionSwitchCellAccessibility.m
 Abstract: Accessibility support for the three-position switch cell.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 
 */

#import "ThreePositionSwitchCellAccessibility.h"

@implementation ThreePositionSwitchCell (ThreePositionSwitchCellAccessibility)

- (CGFloat)accessibilityValue
{
    CGFloat positionValue;
    ThreePositionSwitchPosition currentPosition = [(ThreePositionSwitch *)[self controlView] currentPosition];
    
    switch ( currentPosition )
    {
        case kThreePositionSwitchPositionCenter:
            positionValue = 0.5;
            break;
        case kThreePositionSwitchPositionRight:
            positionValue = 1.0;
            break;
        default:
            positionValue = 0;
            break;
    }
    
    return positionValue;
}

- (NSString *)accessibilityValueDescription
{
    NSString *valueDescription = nil;
    ThreePositionSwitchPosition currentPosition = [(ThreePositionSwitch *)[self controlView] currentPosition];
    switch ( currentPosition )
    {
        case kThreePositionSwitchPositionCenter:
            valueDescription = NSLocalizedString(@"ON", @"accessibility description for the state of ON for the switch");
            break;
        case kThreePositionSwitchPositionRight:
            valueDescription = NSLocalizedString(@"AUTO", @"accessibility description for the state of AUTO for the switch");
            break;
        default:
            valueDescription = NSLocalizedString(@"OFF", @"accessibility description for the state of OFF for the switch");
            break;
    }
    
    return valueDescription;
}

- (NSArray *)accessibilityAttributeNames
{
    static NSMutableArray *attributes = nil;
    if ( attributes == nil )
    {
        attributes = [[super accessibilityAttributeNames] mutableCopy];
        NSArray *appendAttributes = @[NSAccessibilityDescriptionAttribute,
                                      NSAccessibilityHelpAttribute,
                                      NSAccessibilityValueAttribute,
                                      NSAccessibilityMinValueAttribute,
                                      NSAccessibilityMaxValueAttribute,
                                      NSAccessibilityAllowedValuesAttribute,
                                      NSAccessibilityValueDescriptionAttribute,
                                      NSAccessibilityOrientationAttribute,
                                      NSAccessibilityChildrenAttribute];
        
        for ( NSString *attribute in appendAttributes )
        {
            if ( ![attributes containsObject:attribute] )
            {
                [attributes addObject:attribute];
            }
        }
    }
    return attributes;
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
    id value = nil;

    if ( [attribute isEqualToString:NSAccessibilityRoleAttribute] )
    {
        // An accurate accessibility role lets assistive applications infer the element's contents and behavior. VoiceOver relies on this to describe the control, its actions, and more.
        value = NSAccessibilitySliderRole;
    }
    else if ( [attribute isEqualToString:NSAccessibilityDescriptionAttribute] )
    {
        value = NSLocalizedString(@"SWITCH", @"accessibility description of the three position switch");
    }
    else if ( [attribute isEqualToString:NSAccessibilityHelpAttribute] )
    {
        value = NSLocalizedString(@"SWITCH_HINT", @"accessibility description of the three position switch");
    }
    else if ( [attribute isEqualToString:NSAccessibilityValueAttribute] )
    {
        value = [NSNumber numberWithDouble:[self accessibilityValue]];
    }
    else if ( [attribute isEqualToString:NSAccessibilityMinValueAttribute] )
    {
        value = [NSNumber numberWithFloat:0];
    }
    else if ( [attribute isEqualToString:NSAccessibilityMaxValueAttribute] )
    {
        value = [NSNumber numberWithFloat:1.0];
    }
    else if ( [attribute isEqualToString:NSAccessibilityAllowedValuesAttribute] )
    {
        NSMutableArray *allowedValues = [NSMutableArray arrayWithCapacity:3];
        [allowedValues addObject:[NSNumber numberWithDouble:0]];
        [allowedValues addObject:[NSNumber numberWithDouble:0.5]];
        [allowedValues addObject:[NSNumber numberWithDouble:1]];
        value = allowedValues;
    }
    else if ( [attribute isEqualToString:NSAccessibilityValueDescriptionAttribute] )
    {
        value = [self accessibilityValueDescription];
    }
    else if ( [attribute isEqualToString:NSAccessibilityOrientationAttribute] )
    {
        value = NSAccessibilityHorizontalOrientationValue;
    }
    else if ( [attribute isEqualToString:NSAccessibilityChildrenAttribute] )
    {
        ValueIndicatorUIElement *valueIndicator = [[ValueIndicatorUIElement alloc] initWithParent:self];
        value = [NSArray arrayWithObject:valueIndicator];
    }
    else
    {
        value = [super accessibilityAttributeValue:attribute];
    }

    return value;
}

- (BOOL)accessibilityIsAttributeSettable:(NSString *)attribute 
{
    BOOL settable;

    if ( [attribute isEqualToString:NSAccessibilityDescriptionAttribute] ||
        [attribute isEqualToString:NSAccessibilityHelpAttribute] ||
        [attribute isEqualToString:NSAccessibilityMinValueAttribute] ||
        [attribute isEqualToString:NSAccessibilityMaxValueAttribute] ||
        [attribute isEqualToString:NSAccessibilityAllowedValuesAttribute] ||
        [attribute isEqualToString:NSAccessibilityValueDescriptionAttribute] ||
        [attribute isEqualToString:NSAccessibilityOrientationAttribute] ||
        [attribute isEqualToString:NSAccessibilityChildrenAttribute] )
    {
        settable = NO;
    }
    else if ( [attribute isEqualToString:NSAccessibilityValueAttribute] )
    {
        settable = YES;
    }
    else
    {
        settable = [super accessibilityIsAttributeSettable:attribute];
    }

    return settable;
}

- (void)accessibilitySetValue:(id)value forAttribute:(NSString *)attribute
{
    if ( [attribute isEqualToString:NSAccessibilityValueAttribute] )
    {
        CGFloat newValue = [value doubleValue];
        CGFloat currentValue = [self accessibilityValue];
        ThreePositionSwitch *controlView = (ThreePositionSwitch *)[self controlView];
        
        if ( newValue < currentValue )
        {
            [controlView moveHandleToNextPositionRight:NO wrapAround:NO];
        }
        else if ( newValue > currentValue )
        {
            [controlView moveHandleToNextPositionRight:YES wrapAround:NO];
        }
    }
}

- (NSArray *)accessibilityActionNames
{
    return [NSArray arrayWithObjects:NSAccessibilityIncrementAction, NSAccessibilityDecrementAction, nil];
}

- (NSString *)accessibilityActionDescription:(NSString *)action 
{
    return NSAccessibilityActionDescription(action);
}

- (void)accessibilityPerformAction:(NSString *)action
{
    if ([action isEqualToString:NSAccessibilityIncrementAction])
    {
        [(ThreePositionSwitch *)[self controlView] moveHandleToNextPositionRight:YES wrapAround:NO];
        
    }
    else if ( [action isEqualToString:NSAccessibilityDecrementAction] )
    {
        [(ThreePositionSwitch *)[self controlView] moveHandleToNextPositionRight:NO wrapAround:NO];
    }
}

- (id)accessibilityHitTest:(NSPoint)point
{
    id hitElement = nil;

    id controlView = [self controlView];
    NSRect hitRect = NSMakeRect(point.x, point.y, 1, 1);
    hitRect = [[controlView window] convertRectFromScreen:hitRect];
    NSPoint localPoint = [controlView convertPoint:hitRect.origin fromView:nil];
    NSRect handleRect = [(ThreePositionSwitch *)controlView handleRect];
    
    if ( NSPointInRect(localPoint, handleRect) )
    {
        ValueIndicatorUIElement *valueIndicator = [[ValueIndicatorUIElement alloc] initWithParent:self];
        hitElement = [valueIndicator accessibilityHitTest:point];
    }
    else
    {
        hitElement = NSAccessibilityUnignoredAncestor(self);
    }

    return hitElement;
}

- (id)accessibilityFocusedUIElement 
{
    return NSAccessibilityUnignoredAncestor(self);
}

@end
