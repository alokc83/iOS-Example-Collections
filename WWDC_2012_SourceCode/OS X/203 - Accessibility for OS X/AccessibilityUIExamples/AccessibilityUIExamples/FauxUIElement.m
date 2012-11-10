/*
 
     File: FauxUIElement.m
 Abstract: Object used to represent interface elements that are not otherwise accessible.
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

#import "FauxUIElement.h"

#import <AppKit/NSAccessibility.h>

@implementation FauxUIElement

@synthesize role = _role;
@synthesize subrole = _subrole;
@synthesize parent = _parent;
@synthesize tag = _tag;

- (id)initWithRole:(NSString *)aRole subrole:(NSString *)subrole parent:(id)aParent
{
    if ( self = [super init] )
    {
        _subrole = subrole;
        _role = aRole;
        _parent = aParent;
    }
    return self;
}

+ (FauxUIElement *)elementWithRole:(NSString *)aRole parent:(id)aParent
{
    return [[self alloc] initWithRole:aRole subrole:nil parent:aParent];
}

+ (FauxUIElement *)elementWithRole:(NSString *)aRole subrole:(NSString *)subrole parent:(id)aParent
{
    return [[self alloc] initWithRole:aRole subrole:subrole parent:aParent];
}

// Make sure to implement -hash and -isEqual if you subclass FauxUIElement.

- (BOOL)isEqual:(id)object
{
    if ( [object isKindOfClass:[FauxUIElement self]] )
    {
        FauxUIElement *other = object;
        BOOL subrolesMatchOrNil = self.subrole || other.subrole ? [self.subrole isEqualToString:other.subrole] : YES;
        return [self.role isEqualToString:other.role] && subrolesMatchOrNil && self.tag == other.tag && [(id)self.parent isEqual:other.parent];
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)hash
{
    // Equal objects must hash the same.
    return [self.role hash] + [self.subrole hash] + labs(self.tag) + [(id)self.parent hash];
}

#pragma mark -
#pragma mark Accessibility protocol


// Attributes.

- (NSArray *)accessibilityAttributeNames
{
    static NSArray *attributes = nil;
    if ( attributes == nil )
    {
        attributes = [[NSArray alloc] initWithObjects:
                      NSAccessibilityRoleAttribute,
                      NSAccessibilitySubroleAttribute,
                      NSAccessibilityRoleDescriptionAttribute,
                      NSAccessibilityDescriptionAttribute,
                      NSAccessibilityHelpAttribute,
                      NSAccessibilityValueAttribute,
                      NSAccessibilityFocusedAttribute,
                      NSAccessibilityParentAttribute,
                      NSAccessibilityWindowAttribute,
                      NSAccessibilityTopLevelUIElementAttribute,
                      NSAccessibilityPositionAttribute,
                      NSAccessibilitySizeAttribute,
                      nil];
    }
    return attributes;
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
    id value = nil;
    id parent = self.parent;
    if ( [attribute isEqualToString:NSAccessibilityRoleAttribute] )
    {
        value = self.role;
    }
    else if ( [attribute isEqualToString:NSAccessibilitySubroleAttribute] )
    {
        // Use given subrole if set.
        value = self.subrole ? self.subrole : [super accessibilityAttributeValue:attribute];
    }
    else if ( [attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute] )
    {
        value = NSAccessibilityRoleDescription(self.role, nil);
    }
    else if ( [attribute isEqualToString:NSAccessibilityDescriptionAttribute] )
    {
        if ( [parent respondsToSelector:@selector(fauxUIElementDescription:)] )
        {
            value = [parent fauxUIElementDescription:self];
        }
    }
    else if ( [attribute isEqualToString:NSAccessibilityHelpAttribute] )
    {
        if ( [parent respondsToSelector:@selector(fauxUIElementHelp:)] )
        {
            value = [parent fauxUIElementHelp:self];
        }
    }
    else if ( [attribute isEqualToString:NSAccessibilityValueAttribute] )
    {
        if ( [parent respondsToSelector:@selector(fauxUIElementValue:)] )
        {
            value = [parent fauxUIElementValue:self];
        }
    }
    else if ( [attribute isEqualToString:NSAccessibilityFocusedAttribute] )
    {
        // Just check if the app thinks we're focused.
        id focusedElement = [NSApp accessibilityAttributeValue:NSAccessibilityFocusedUIElementAttribute];
        value = [NSNumber numberWithBool:[focusedElement isEqual:self]];
    }
    else if ( [attribute isEqualToString:NSAccessibilityParentAttribute] )
    {
        value = NSAccessibilityUnignoredAncestor(parent);
    }
    else if ( [attribute isEqualToString:NSAccessibilityWindowAttribute] )
    {
        // We're in the same window as our parent.
        value = [(id)parent accessibilityAttributeValue:NSAccessibilityWindowAttribute];
    }
    else if ( [attribute isEqualToString:NSAccessibilityTopLevelUIElementAttribute] )
    {
        // We're in the same top level element as our parent.
        value = [(id)parent accessibilityAttributeValue:NSAccessibilityTopLevelUIElementAttribute];
    }
    else if ( [attribute isEqualToString:NSAccessibilityPositionAttribute] )
    {
        if ( [parent respondsToSelector:@selector(fauxUIElementPosition:)] )
        {
            value = [NSValue valueWithPoint:[parent fauxUIElementPosition:self]];
        }
    }
    else if ( [attribute isEqualToString:NSAccessibilitySizeAttribute] )
    {
        if ( [parent respondsToSelector:@selector(fauxUIElementPosition:)] )
        {
            value = [NSValue valueWithSize:[parent fauxUIElementSize:self]];
        }
    }
    
    return value;
}

- (BOOL)accessibilityIsAttributeSettable:(NSString *)attribute
{
    if ( [attribute isEqualToString:NSAccessibilityFocusedAttribute] )
    {
        return [self.parent isFauxUIElementFocusable:self];
    }
    else
    {
        return NO;
    }
}

- (void)accessibilitySetValue:(id)value forAttribute:(NSString *)attribute
{
    if ([attribute isEqualToString:NSAccessibilityFocusedAttribute])
    {
        id parent = self.parent;
        if ( [parent respondsToSelector:@selector(fauxUIElement:setFocus:)] )
        {
            [parent fauxUIElement:self setFocus:value];
        }
    }
}


// Actions.

- (NSArray *)accessibilityActionNames
{
    id parent = self.parent;
    if ( [parent respondsToSelector:@selector(fauxUIElementActionNames:)] )
    {
        return [parent fauxUIElementActionNames:self];
    }
    return [NSArray array];
}

- (NSString *)accessibilityActionDescription:(NSString *)action
{
    return NSAccessibilityActionDescription(action);
}

- (void)accessibilityPerformAction:(NSString *)action
{
    id parent = self.parent;
    if ( [parent respondsToSelector:@selector(fauxUIElement:performAction:)] )
    {
        [parent fauxUIElement:self performAction:action];
    }
}


// Miscellaneous.

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

- (id)accessibilityHitTest:(NSPoint)point
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor(self);
}

@end
