/*
 
     File: CustomStepperAccessibility.m
 Abstract: Accessibility support for the custom stepper.
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

#import "CustomStepperAccessibility.h"
#import "FauxUIElement.h"

typedef enum
{
    kCustomStepperUpButtonTag = 0,
    kCustomStepperDownButtonTag = 1,
} CustomStepperButtonTag;

@implementation CustomStepper (CustomStepperAccessibility)

// NSStepper supports the AXIncrement/AXDecrement actions itself, but also through AXPress on its child arrow
// on its child buttons. We emulate the same accessibility hierarchy, here, using a combination of the accessibility
// protocol and the FauxUIElement class.

- (BOOL)accessibilityIsIgnored
{
    // NSObject returns YES. Must override and return NO for the view to be reachable.
    return NO;
}

- (NSArray *)accessibilityAttributeNames
{
    static NSMutableArray *attributes = nil;
    if ( attributes == nil )
    {
        attributes = [[super accessibilityAttributeNames] mutableCopy];
        NSArray *appendAttributes = @[NSAccessibilityChildrenAttribute,
                                      NSAccessibilityRoleAttribute,
                                      NSAccessibilityIncrementButtonAttribute,
                                      NSAccessibilityDecrementButtonAttribute,
                                      NSAccessibilityDescriptionAttribute,
                                      NSAccessibilityEnabledAttribute];
        
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

- (NSArray *)accessibilityChildren
{
    // Return faux UI elements representing each stepper button.
    static NSArray *children = nil;
    if  (children == nil)
    {
        FauxUIElement *upButton = [FauxUIElement elementWithRole:NSAccessibilityButtonRole subrole:NSAccessibilityIncrementArrowSubrole parent:(id <FauxUIElementChildSupport>)self];
        upButton.tag = kCustomStepperUpButtonTag;
        
        FauxUIElement *downButton = [FauxUIElement elementWithRole:NSAccessibilityButtonRole subrole:NSAccessibilityDecrementArrowSubrole parent:(id <FauxUIElementChildSupport>)self];
        downButton.tag = kCustomStepperDownButtonTag;
        
        children = [[NSArray alloc] initWithObjects:upButton, downButton, nil];
    }
    return children;
}

- (FauxUIElement *)accessibilityChildWithTag:(NSInteger)tag
{
    FauxUIElement *accessibilityChild = nil;
    for ( FauxUIElement *child in [self accessibilityChildren] )
    {
        if ( child.tag == tag )
        {
            accessibilityChild = child;
            break;
        }
    }
    
    return accessibilityChild;
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
    id value = nil;
    if ( [attribute isEqualToString:NSAccessibilityRoleAttribute] )
    {
        value = NSAccessibilityIncrementorRole;
    }
    else if ( [attribute isEqualToString:NSAccessibilityEnabledAttribute] )
    {
        value = [NSNumber numberWithBool:YES];
    }
    else if ( [attribute isEqualToString:NSAccessibilityChildrenAttribute] )
    {
        return [self accessibilityChildren];
    }
    else if ( [attribute isEqualToString:NSAccessibilityIncrementButtonAttribute] )
    {
        return [[self accessibilityAttributeValue:NSAccessibilityChildrenAttribute] objectAtIndex:kCustomStepperUpButtonTag];
    }
    else if ( [attribute isEqualToString:NSAccessibilityDecrementButtonAttribute] )
    {
        return [[self accessibilityAttributeValue:NSAccessibilityChildrenAttribute] objectAtIndex:kCustomStepperDownButtonTag];
    }
    else if ( [attribute isEqualToString:NSAccessibilityDescriptionAttribute] )
    {
        return NSLocalizedString(@"VOLUME", @"Accessibility description for custom volume stepper.");
    }
    else if ( [attribute isEqualToString:NSAccessibilityHelpAttribute] )
    {
        return NSLocalizedString(@"VOLUME_STEPPER_HINT", @"Accessibility hint description for custom volume stepper.");
    }
    else
    {
        return [super accessibilityAttributeValue:attribute];
    }

    return value;
}

- (NSArray *)accessibilityActionNames
{
    return [NSArray arrayWithObjects:NSAccessibilityIncrementAction, NSAccessibilityDecrementAction, nil];
}

- (void)accessibilityPerformAction:(NSString *)action
{
    if ( [action isEqualToString:NSAccessibilityIncrementAction] )
    {
        [self performIncrementButtonPress];
    }
    else
    {
        [self performDecrementButtonPress];
    }
}

- (id)accessibilityHitTest:(NSPoint)point
{
    id hitElement = self;
    NSPoint localPoint = [[self window] convertRectFromScreen:NSMakeRect(point.x, point.y, 0, 0)].origin;
    localPoint = [self convertPoint:localPoint fromView:nil];
    
    if ( NSPointInRect(localPoint, [self upButtonRect]) )
    {
        hitElement = [self accessibilityChildWithTag:kCustomStepperUpButtonTag];
    }
    else if ( NSPointInRect(localPoint, [self downButtonRect]) )
    {
        hitElement = [self accessibilityChildWithTag:kCustomStepperDownButtonTag];
    }
    
    return NSAccessibilityUnignoredAncestor(hitElement);
}

#pragma mark - FauxUIElement protocol

- (NSPoint)fauxUIElementPosition:(FauxUIElement *)fauxElement
{
    NSPoint position = NSZeroPoint;
    
    if ( fauxElement.tag == kCustomStepperDownButtonTag )
    {
        position = [self upButtonRect].origin;
    }
    else if (fauxElement)
    {
        position = [self downButtonRect].origin;
    }
    
    position = [self convertPoint:position toView:nil];
    position = [[self window] convertRectToScreen:NSMakeRect(position.x, position.y, 0, 0)].origin;
    
    return position;
}

- (NSSize)fauxUIElementSize:(FauxUIElement *)fauxElement
{
    NSSize size = NSZeroSize;
    
    if ( fauxElement.tag == kCustomStepperDownButtonTag )
    {
        size = [self upButtonRect].size;
    }
    else if (fauxElement)
    {
        size = [self downButtonRect].size;
    }
    
    return size;
}

- (BOOL)isFauxUIElementFocusable:(FauxUIElement *)fauxElement
{
    return YES;
}

- (NSArray *)fauxUIElementActionNames:(FauxUIElement *)fauxElement
{
    return [NSArray arrayWithObject:NSAccessibilityPressAction];
}

- (void)fauxUIElement:(FauxUIElement *)fauxElement performAction:(NSString *)action
{
    if ( [action isEqualToString: NSAccessibilityPressAction] )
    {
        switch ( fauxElement.tag )
        {
            case kCustomStepperUpButtonTag:
                [self performIncrementButtonPress];
                break;
            case kCustomStepperDownButtonTag:
                [self performDecrementButtonPress];
                break;
        }
    }
}

@end