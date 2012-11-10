/*
 
     File: CoreTextColumnViewAccessibility.m
 Abstract: Accessibility support for the Core Text column view.
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

#import "CoreTextColumnViewAccessibility.h"
#import "CoreTextColumnView.h"

@implementation CoreTextColumnView (CoreTextColumnViewAccessibility)


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
        NSArray *appendAttributes = @[NSAccessibilityRoleAttribute,
                                      NSAccessibilityValueAttribute,
                                      NSAccessibilityNumberOfCharactersAttribute,
                                      NSAccessibilityVisibleCharacterRangeAttribute,];
        
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

- (NSArray *)accessibilityParameterizedAttributeNames
{
    static NSMutableArray *parameterizedAttributes = nil;
    if ( parameterizedAttributes == nil )
    {
        parameterizedAttributes = [[super accessibilityParameterizedAttributeNames] mutableCopy];
        
        NSArray *appendAttributes = @[NSAccessibilityLineForIndexParameterizedAttribute,
        NSAccessibilityRangeForLineParameterizedAttribute,
        NSAccessibilityStringForRangeParameterizedAttribute,
        NSAccessibilityAttributedStringForRangeParameterizedAttribute,
        NSAccessibilityBoundsForRangeParameterizedAttribute];
        
        for ( NSString *attribute in appendAttributes )
        {
            if ( ![parameterizedAttributes containsObject:attribute] )
            {
                [parameterizedAttributes addObject:attribute];
            }
        }
    }
    return parameterizedAttributes;
}

- (id)accessibilityAttributeValue:(NSString *)attribute forParameter:(id)parameter
{
    if ( ![parameter isKindOfClass:[NSValue class]] )
    {
        return nil;
    }

    id value = nil;

    if ( [attribute isEqualToString:NSAccessibilityStringForRangeParameterizedAttribute] )
    {
        NSRange range = [(NSValue *)parameter rangeValue];
        value = [self stringForRange:range];
    }
    else if ( [attribute isEqualToString:NSAccessibilityAttributedStringForRangeParameterizedAttribute] )
    {
        NSRange range = [(NSValue *)parameter rangeValue];
        value = [self attributedStringForRange:range];
    }
    else if ( [attribute isEqualToString:NSAccessibilityLineForIndexParameterizedAttribute] )
    {
        NSUInteger index = [parameter unsignedIntegerValue];
        NSUInteger line = [self lineForIndex:index];        
        if ( line != NSNotFound )
        {
            value = [NSNumber numberWithUnsignedInteger:line];
        }
    }
    else if ( [attribute isEqualToString:NSAccessibilityRangeForLineParameterizedAttribute] )
    {
        NSUInteger index = [parameter unsignedIntegerValue];
        NSRange range = [self rangeForLine:index];
        value = [NSValue valueWithRange:range];
    }
    else if ( [attribute isEqualToString:NSAccessibilityBoundsForRangeParameterizedAttribute] )
    {
        NSRange range = [parameter rangeValue];
        NSRect bounds = [self boundsForRange:range];               
        value = [NSValue valueWithRect:bounds];
    }
    else
    {
        value = [super accessibilityAttributeValue:attribute forParameter:parameter];
    }
    
    return value;
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
    id value = nil;
    if ( [attribute isEqualToString:NSAccessibilityRoleAttribute] )
    {
        value = NSAccessibilityTextAreaRole;
    }
    else if ( [attribute isEqualToString:NSAccessibilityValueAttribute] )
    {
        value = [self attributedString];
    }
    else if ( [attribute isEqualToString:NSAccessibilityNumberOfCharactersAttribute] )
    {
        NSUInteger length = [[self attributedString] length];
        value = [NSNumber numberWithUnsignedInteger:length];
    }
    else if ( [attribute isEqualToString:NSAccessibilityVisibleCharacterRangeAttribute] )
    {
        CFArrayRef frames = [self frames];
        NSUInteger columnCount = CFArrayGetCount(frames);
        NSRange visibleRange = NSMakeRange(0, 0); // Range known to begin at zero. Cannot union with NSNotFound.
        for (NSUInteger columnIdx = 0; columnIdx < columnCount; columnIdx++)
        {
            CTFrameRef frame = CFArrayGetValueAtIndex(frames, columnIdx);
            CFRange frameRange = CTFrameGetVisibleStringRange(frame);
            visibleRange = NSUnionRange(visibleRange, NSMakeRange(frameRange.location, frameRange.length));
        }

        value = [NSValue valueWithRange:visibleRange];
    }
    else
    {
        value = [super accessibilityAttributeValue:attribute];
    }

    return value;
}

- (NSArray *)accessibilityActionNames
{
    return [NSArray arrayWithObjects:NSAccessibilityPressAction, nil];
}

- (NSString *)accessibilityActionDescription:(NSString *)action 
{
    return NSAccessibilityActionDescription(action);
}

- (void)accessibilityPerformAction:(NSString *)action
{
    if ([action isEqualToString:NSAccessibilityPressAction])
    {
        [self changeLayout];
    }
}

@end
