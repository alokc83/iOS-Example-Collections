/*
 
     File: CoreTextColumnView.m
 Abstract: View that renders columns of text using Core Text.
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

#import "CoreTextColumnView.h"

#define COLUMN_COUNT_MIN 1
#define COLUMN_COUNT_MAX 2

// IMPORTANT: This is not a template for developing a custom text field. This sample is
// intended to demonstrate how to add accessibility to UI that may not have been
// ideally designed. For information on how to create custom controls please visit
// http://developer.apple.com

@implementation CoreTextColumnView

- (void)dealloc
{
    if (mColumnRects)
        free(mColumnRects);

    if (mFrames)
        CFRelease(mFrames);
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        // Initialization code here.
        mColumnCount = 2;
        mCountIncrement = 1;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Apple designs Macs, the best personal computers in the world, along with OS X, iLife, iWork and professional software. Apple leads the digital music revolution with its iPods and iTunes online store. Apple has reinvented the mobile phone with its revolutionary iPhone and App Store, and is defining the future of mobile media and computing devices with iPad."];
        
        [attributedString setAlignment:NSJustifiedTextAlignment range:NSMakeRange(0, [attributedString length])];

        [self setAttributedString:attributedString];
        [self updateFrames];
    }
    return self;
}

- (CFArrayRef)newFrames
{
    if ( mColumnRects )
    {
        free(mColumnRects);
    }
    mColumnRects = [self newColumnRects];

    // Create text frames given string and column rectangles. 
    CTFramesetterRef framesetter = [self framesetter];
    CFIndex startIndex = 0;
    
    CFMutableArrayRef frames = CFArrayCreateMutable(kCFAllocatorDefault, mColumnCount, &kCFTypeArrayCallBacks);
    int column;
    for ( column = 0; column < mColumnCount; column++ )
    {

        // Create frame with rect path.
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, mColumnRects[column]);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);

        CFArrayInsertValueAtIndex(frames, column, frame);
        
        // Start the next frame at the first character not visible in this frame.
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
        
        CFRelease(frame);
        CFRelease(path);
    }
    
    return frames;
}

- (void)updateFrames
{
    if ( mFrames )
    {
        CFRelease(mFrames);
    }
    mFrames = [self newFrames];
}

- (CGRect *)newColumnRects
{
    CGRect bounds = CGRectMake(0, 0, NSWidth([self bounds]), NSHeight([self bounds]));

    int column;
    CGRect* columnRects = (CGRect*)calloc(mColumnCount, sizeof(*columnRects));
    
    // Start by setting the first column to cover the entire view.
    columnRects[0] = bounds;
    
    // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(bounds) / mColumnCount;
    for ( column = 0; column < mColumnCount - 1; column++ )
    {
        CGRectDivide(columnRects[column], &columnRects[column], &columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
    
    // Inset all columns by a few pixels of margin.
    for ( column = 0; column < mColumnCount; column++ )
    {
        columnRects[column] = CGRectInset(columnRects[column], 10.0, 10.0);
    }
    return columnRects;
}

- (CGRect *)columnRects
{
    return mColumnRects;
}

- (CFArrayRef)frames
{
    return mFrames;
}

- (void)drawRect:(NSRect)rect
{
    // Initialize the text matrix to a known value
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CFIndex frameCount = CFArrayGetCount(mFrames);
    int column;
    for ( column = 0; column < frameCount; column++ )
    {
        CTFrameRef frame = (CTFrameRef)CFArrayGetValueAtIndex(mFrames, column);
        CTFrameDraw(frame, context);
    }
}

- (void)changeLayout
{
    if ( COLUMN_COUNT_MIN == COLUMN_COUNT_MAX )
    {
        return;
    }
    
    if ( mColumnCount == COLUMN_COUNT_MIN )
    {
        mCountIncrement = 1;
    }
    else if ( mColumnCount == COLUMN_COUNT_MAX )
    {
        mCountIncrement = -1;
    }
    
    mColumnCount = mColumnCount + mCountIncrement;
    
    [self updateFrames];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self changeLayout];
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
    _attributedString = [attributedString copy];
    
    if ( attributedString )
    {
        // Re-draw the view if the input string changes.
        [self setNeedsDisplay:YES];
    }
}

- (CTFramesetterRef)framesetter
{
    if ( mFramesetter == NULL )
    {
        mFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedString);
    }
    return mFramesetter;
}

- (NSAttributedString *)attributedStringForRange:(NSRange)range
{
    NSAttributedString *value = nil;
    NSAttributedString *attributedString = [self attributedString];
    
    if ( NSMaxRange(range) <= [attributedString length] )
    {
        value = [attributedString attributedSubstringFromRange:range];
    }
    return value;
}

- (NSString *)stringForRange:(NSRange)range
{
    return [[self attributedStringForRange:range] string];
}

- (NSUInteger)lineForIndex:(NSUInteger)index
{
    NSUInteger lineForIndex = NSNotFound;
    NSUInteger absoluteLineNumber = 0; // Current line, across columns.
    
    CFArrayRef frames = [self frames];
    NSUInteger columnCount = CFArrayGetCount(frames);
    
    for ( NSUInteger columnIdx = 0; columnIdx < columnCount; columnIdx++ )
    {
        CTFrameRef currentFrame = CFArrayGetValueAtIndex(frames, columnIdx);
        CFArrayRef lines = CTFrameGetLines(currentFrame);
        NSUInteger lineCount = CFArrayGetCount(lines); // Lines in just this column.
        
        for ( NSUInteger lineIdx = 0; lineIdx < lineCount; lineIdx++ )
        {
            CTLineRef currentLine = CFArrayGetValueAtIndex(lines, lineIdx);
            CFRange lineRange = CTLineGetStringRange(currentLine);
            BOOL characterInLineRange = (CFIndex)index - lineRange.location < lineRange.length;
            if ( characterInLineRange )
            {
                lineForIndex = absoluteLineNumber;
                break;
            }
            
            absoluteLineNumber++;
        }
        
        if ( lineForIndex != NSNotFound )
        {
            break;
        }
    }
    
    return ( lineForIndex != NSNotFound ) ? absoluteLineNumber : NSNotFound;
}


- (NSRange)rangeForLine:(NSUInteger)index
{
    NSRange rangeForLine = NSMakeRange(NSNotFound, 0);
    NSUInteger absoluteLineNumber = 0;
    
    CFArrayRef frames = [self frames];
    NSUInteger columnCount = CFArrayGetCount(frames);
    
    for ( NSUInteger columnIdx = 0; columnIdx < columnCount; columnIdx++ )
    {
        CTFrameRef currentFrame = CFArrayGetValueAtIndex(frames, columnIdx);
        CFArrayRef lines = CTFrameGetLines(currentFrame);
        NSUInteger lineCount = CFArrayGetCount(lines);
        
        // Skip to next frame.
        if ( absoluteLineNumber + lineCount <= index )
        {
            absoluteLineNumber += lineCount;
            continue;
        }
        // Line lives within this frame if the text is long enough.
        else
        {
            NSUInteger relativeIndex = index - absoluteLineNumber;
            if (relativeIndex < lineCount)
            {
                CTLineRef currentLine = CFArrayGetValueAtIndex(lines, relativeIndex);
                CFRange lineRange = CTLineGetStringRange(currentLine);
                rangeForLine = NSMakeRange(lineRange.location, lineRange.length);
            }
            break;
        }
    }
    return rangeForLine;
}


- (NSRect)boundsForRange:(NSRange)range inColumn:(NSUInteger)columnIdx line:(NSUInteger)lineIdx
{    
    CTFrameRef frame = CFArrayGetValueAtIndex([self frames], columnIdx);
    CFArrayRef lines = CTFrameGetLines(frame);
    CTLineRef line = CFArrayGetValueAtIndex(lines, lineIdx);
    
    // Looking for bounds of range that fall within this line.
    CFRange lineRange = CTLineGetStringRange(line);
    NSRange rangeWithinLine = NSIntersectionRange(range, NSMakeRange(lineRange.location, lineRange.length));
    
    // Find origin of line relative to frame.
    CGPoint lineOrigins[1];
    
    CTFrameRef lineFrame = CFArrayGetValueAtIndex([self frames], columnIdx);
    CTFrameGetLineOrigins(lineFrame, CFRangeMake(lineIdx, 1), lineOrigins);
    CGPoint lineOrigin = lineOrigins[0];
    
    // Find horizontal pixel offsets of range within line.
    CGFloat rangeXOffset = CTLineGetOffsetForStringIndex(line, rangeWithinLine.location, NULL);
    
    // Calculate line height.
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat lineHeight = ascent + descent + leading;
    
    // Calculate range width.
    CGFloat leftMargin = CTLineGetOffsetForStringIndex(line, rangeWithinLine.location, NULL);
    CGFloat rightMargin = CTLineGetOffsetForStringIndex(line, NSMaxRange(rangeWithinLine), NULL);
    CGFloat rangeWidth = rightMargin - leftMargin;
    
    // Put it all together.
    CGPoint frameOrigin = mColumnRects[columnIdx].origin;
    CGFloat xPos = frameOrigin.x + lineOrigin.x + rangeXOffset;
    CGFloat yPos = frameOrigin.y + lineOrigin.y;
    NSRect rangeRect = NSMakeRect(xPos, yPos, rangeWidth, lineHeight);
    NSRect windowRect = [self convertRect:rangeRect toView:nil];
    NSRect screenRect = [[self window] convertRectToScreen:windowRect];
    
    return screenRect;
}

- (NSRect)boundsForRange:(NSRange)range
{
    NSRect returnValue = NSZeroRect;

    NSUInteger characterIndexSought = range.location;
    
    // Find lines at start and end of range.
    NSUInteger startLineColumnIdx = NSNotFound;
    NSUInteger endLineColumnIdx = NSNotFound;
    NSUInteger startLineIdx = NSNotFound;
    NSUInteger endLineIdx = NSNotFound;
    
    CFArrayRef frames = [self frames];
    NSUInteger columnCount = CFArrayGetCount(frames);
    
    NSUInteger columnIdx;
    for ( columnIdx = 0; columnIdx < columnCount; columnIdx++ )
    {
        CTFrameRef currentFrame = CFArrayGetValueAtIndex(frames, columnIdx);
        CFArrayRef lines = CTFrameGetLines(currentFrame);
        NSUInteger lineCount = CFArrayGetCount(lines);
        
        NSUInteger lineIdx;
        for ( lineIdx = 0; lineIdx < lineCount; lineIdx++ )
        {
            CTLineRef currentLine = CFArrayGetValueAtIndex(lines, lineIdx);
            CFRange lineRange = CTLineGetStringRange(currentLine);
            BOOL characterInLineRange = (CFIndex)characterIndexSought - lineRange.location < lineRange.length;
            if ( characterInLineRange )
            {
                if ( startLineIdx == NSNotFound )
                {
                    // Found the first line.
                    startLineColumnIdx = columnIdx;
                    startLineIdx = lineIdx;
                    
                    NSUInteger lastCharInLine = lineRange.location + lineRange.length;
                    if ( lastCharInLine >= NSMaxRange(range) )
                    {
                        // The entire range is contained in this line. We're done.
                        endLineColumnIdx = columnIdx;
                        endLineIdx = lineIdx;
                        break;
                    }
                    else
                    {
                        // Continue search for end line since range extends beyond this one.
                        characterIndexSought = NSMaxRange(range);
                    }
                }
                else
                {
                    endLineColumnIdx = columnIdx;
                    endLineIdx = lineIdx;
                    break;
                }
            }
        }
        
        if ( startLineIdx != NSNotFound && endLineIdx != NSNotFound )
        {
            break;
        }
    }
    
    // Sanity check.
    if ( startLineIdx != NSNotFound )
    {
        
        // Combine bounds rects for each line.
        NSUInteger currentColumn;
        NSUInteger currentLine;
        
        for ( currentColumn = startLineColumnIdx; currentColumn <= endLineColumnIdx; currentColumn++ )
        {
            NSUInteger startLine = currentColumn == startLineColumnIdx ? startLineIdx : 0;
            
            NSUInteger endLine;
            if ( currentColumn == endLineColumnIdx )
            {
                endLine = endLineIdx;
            }
            else
            {
                CTFrameRef frame = CFArrayGetValueAtIndex(frames, currentColumn);
                CFArrayRef lines = CTFrameGetLines(frame);
                NSUInteger lineCount = CFArrayGetCount(lines);
                endLine = lineCount - 1;
            }
            
            for ( currentLine = startLine; currentLine <= endLine; currentLine++ )
            {
                NSRect lineBoundsForRange = [self boundsForRange:range inColumn:currentColumn line:currentLine];
                returnValue = NSUnionRect(returnValue, lineBoundsForRange);
            }
        }
    }
    return returnValue;
}
    
    
@end
