/*
 
     File: ThreePositionSwitch.m
 Abstract: Custom control that behaves like a three-position switch.
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

#import "ThreePositionSwitch.h"
#import "ThreePositionSwitchCell.h"
#import "ValueIndicatorUIElement.h"

#define THREE_POSITION_SWITCH_HANDLE_WIDTH  (52.0)

// IMPORTANT: This is not a template for developing a custom switch. This sample is
// intended to demonstrate how to add accessibility to UI that may not have been
// ideally designed. For information on how to create custom controls please visit
// http://developer.apple.com

@implementation ThreePositionSwitch

+ (Class)cellClass
{
    return [ThreePositionSwitchCell class];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        mDragTrackingStartLocation = NSMakePoint(-1, -1);
        mBackgroundColor = [NSColor redColor];
        mHandleColor = [NSColor blueColor];
    }
    
    return self;
}

- (ThreePositionSwitchPosition)currentPosition
{
    return mCurrentPosition;
}

- (NSRect)handleRect
{
    NSRect bounds = [self bounds];
    
    // Calculate base rect for current switch state.
    NSRect handleRect = NSMakeRect(0, 0, THREE_POSITION_SWITCH_HANDLE_WIDTH, bounds.size.height);
    switch ( mCurrentPosition )
    {
        case kThreePositionSwitchPositionCenter:
            handleRect.origin.x = (bounds.size.width / 2.0f) - (THREE_POSITION_SWITCH_HANDLE_WIDTH / 2.0f);
            break;
        case kThreePositionSwitchPositionRight:
            handleRect.origin.x = bounds.size.width - THREE_POSITION_SWITCH_HANDLE_WIDTH;
            break;
        default:
            break;
    }

    // Offset by current drag distance.
    handleRect.origin.x -= ( mDragTrackingStartLocation.x - mDragTrackingCurrentLocation.x);

    // Clamp to view bounds.
    CGFloat originX = MAX(0, handleRect.origin.x);
    handleRect.origin.x = MIN(self.bounds.size.width - THREE_POSITION_SWITCH_HANDLE_WIDTH, originX);
    
    return handleRect;
}

- (void)drawFocusRingMask
{
    NSRectFill([self focusRingMaskBounds]);
}

- (NSRect)focusRingMaskBounds
{
    return [self handleRect];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect drawRect = NSZeroRect;
    NSRect background = [self bounds];
    
    [mBackgroundColor setFill];
    drawRect = NSIntersectionRect(dirtyRect, background);
    NSRectFill(drawRect);
    
    NSRect imageRect = NSZeroRect;
    NSImage *aImage = [NSImage imageNamed:@"ThreePositionSwitchWell"];
    imageRect.size = [aImage size];
    NSPoint trackPoint = background.origin;
    trackPoint.y += 1.0;
    [aImage drawAtPoint:trackPoint fromRect:imageRect operation:NSCompositeCopy fraction:1.0f];
    
    aImage = [NSImage imageNamed:@"ThreePositionSwitchOverlayMask"];
    trackPoint.y -= 1.0;
    imageRect.size = aImage.size;
    [aImage drawAtPoint:trackPoint fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0f];
    
    NSRect handleRect = [self handleRect];
    if ( mDragTrackingStartLocation.x < 0 && mDragTrackingStartLocation.y < 0 )
    {
        aImage = [NSImage imageNamed:@"ThreePositionSwitchHandle"];
    }
    else
    {
        aImage = [NSImage imageNamed:@"ThreePositionSwitchHandleDown"];
    }
    
    imageRect.size = aImage.size;
    CGPoint origin = handleRect.origin;
    origin.x -= 3.5f;
    origin.y = (background.size.height - imageRect.size.height) / 2.0f;
    [aImage drawAtPoint:origin fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0f];
}

- (void)snapHandleToClosestPosition
{
    NSRect handleRect = [self handleRect];
    NSRect bounds = [self bounds];
    CGFloat oneThirdWidth = bounds.size.width / 3.0f;
    
    ThreePositionSwitchPosition desiredPosition = kThreePositionSwitchPositionCenter;
    
    // What position should this be in?
    CGFloat xPos = NSMidX(handleRect);
    if ( xPos < (bounds.origin.x + oneThirdWidth) )
    {
        desiredPosition = kThreePositionSwitchPositionLeft;
    }
    else if ( xPos > (bounds.origin.x + (oneThirdWidth * 2.0f)) )
    {
        desiredPosition = kThreePositionSwitchPositionRight;
    }
    
    if ( desiredPosition != mCurrentPosition )
    {
        mCurrentPosition = desiredPosition;
        NSActionCell *cell = [self cell];
        [NSApp sendAction:[cell action] to:[cell target] from:self];
    }
}

- (void)moveHandleToNextPositionRight:(BOOL)rightDirection wrapAround:(BOOL)shouldWrap
{
    ThreePositionSwitchPosition nextPosition;
    
    switch ( mCurrentPosition )
    {
        case kThreePositionSwitchPositionLeft:
            if ( rightDirection )
                nextPosition = kThreePositionSwitchPositionCenter;
            else
                nextPosition = shouldWrap ? kThreePositionSwitchPositionRight : kThreePositionSwitchPositionLeft;
            break;
        case kThreePositionSwitchPositionCenter:
            nextPosition = rightDirection ? kThreePositionSwitchPositionRight : kThreePositionSwitchPositionLeft;
            break;
        case kThreePositionSwitchPositionRight:
            if ( rightDirection )
                nextPosition = shouldWrap ? kThreePositionSwitchPositionLeft : kThreePositionSwitchPositionRight;
            else
                nextPosition = kThreePositionSwitchPositionCenter;
            break;
    }
    
    if ( nextPosition != mCurrentPosition )
    {
        mCurrentPosition = nextPosition;
        NSActionCell *cell = [self cell];
        [NSApp sendAction:[cell action] to:[cell target] from:self];
        [self display];
    }
}

#pragma mark Mouse events

- (void)handleMouseDrag:(NSEvent *)event
{
    NSEvent *currentEvent = event;
    NSWindow *window = [self window];
    NSUInteger eventMask = ( NSLeftMouseDraggedMask | NSLeftMouseUpMask);
    NSDate *untilDate = [NSDate distantFuture];

    do
    {
        NSPoint mousePoint = [self convertPoint: [currentEvent locationInWindow] fromView:nil];
        switch ( [currentEvent type] )
        {
            case NSLeftMouseDown:
            case NSLeftMouseDragged:
                mDragTrackingCurrentLocation = mousePoint;
                currentEvent = [window nextEventMatchingMask:eventMask
                                                   untilDate:untilDate
                                                      inMode:NSEventTrackingRunLoopMode
                                                     dequeue:YES];
                break;
            default:
                currentEvent = nil;
                break;
        }
        [self display];
        
    }
    while ( currentEvent != nil );
    
    [self snapHandleToClosestPosition];
    mDragTrackingCurrentLocation = mDragTrackingStartLocation = NSMakePoint(-1,-1);
    [self display];

}

- (void)mouseDown:(NSEvent *)event
{
    // If we are not enabled or can't become the first responder, don't do anything.
    if ( ![self isEnabled] ||
         ![[self window] makeFirstResponder:self] )
    {
        return;
    }
    
    // Determine the location, in our local coordinate system, where the user clicked.
    NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];

    BOOL pointInKnob = CGRectContainsPoint([self handleRect], location);
    if ( pointInKnob )
    {
        // When we receive a mouse down event, we reset the dragTrackingLocation.
        mDragTrackingStartLocation = location;
        [self handleMouseDrag:event];
    }
    else
    {
        // Treat clicks outside handle bounds as increment/decrement actions.
        BOOL moveRight = location.x > [self handleRect].origin.x;
        [self moveHandleToNextPositionRight:moveRight wrapAround:NO];
    }
}

#pragma mark Keyboard events

- (void)keyDown:(NSEvent *)theEvent
{
    // Step through values on spacebar.
    if ( [[theEvent characters] isEqualToString:@" "] )
    {
        [self moveHandleToNextPositionRight:YES wrapAround:YES];
    }
    
    // Arrow keys are associated with the numeric keypad.
    if ( [theEvent modifierFlags] & NSNumericPadKeyMask )
    {
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    }
    else
    {
        [super keyDown:theEvent];
    }
}

- (IBAction)moveLeft:(id)sender
{
    [self moveHandleToNextPositionRight:NO wrapAround:NO];
}

- (IBAction)moveRight:(id)sender
{
    [self moveHandleToNextPositionRight:YES wrapAround:NO];
}

@end
