/*
     File: CoreTextView.m 
 Abstract: CoreTextView custom NSView subclass to draw text 
 in frames and illustrate CoreText usage. 
  Version: 1.1 
  
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
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */


#import "CoreTextView.h"

#define COLUMN_COUNT_MIN 1
#define COLUMN_COUNT_MAX 3


@implementation CoreTextView

@synthesize attributedString = _attributedString;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		_columnCount = 1;
		_countIncrement = 1;
    }
    return self;
}

- (void)dealloc
{
    self.attributedString = nil;
    
    if(_framesetter != NULL)
        CFRelease(_framesetter);
    
    [super dealloc];
}

- (CFArrayRef)newColumns
{
	CGRect bounds = CGRectMake(0, 0, NSWidth([self bounds]), NSHeight([self bounds]));
	
	int column;
	CGRect* columnRects = (CGRect*)calloc(_columnCount, sizeof(*columnRects));
	
	// Start by setting the first column to cover the entire view.
	columnRects[0] = bounds;
	
	// Divide the columns equally across the frame's width.
	CGFloat columnWidth = CGRectGetWidth(bounds) / _columnCount;
	for (column = 0; column < _columnCount - 1; column++) {
		CGRectDivide(columnRects[column], &columnRects[column], &columnRects[column + 1], columnWidth, CGRectMinXEdge);
	}
	
	// Inset all columns by a few pixels of margin.
	for (column = 0; column < _columnCount; column++) {
		columnRects[column] = CGRectInset(columnRects[column], 10.0, 10.0);
	}
	
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, _columnCount, &kCFTypeArrayCallBacks);
	for (column = 0; column < _columnCount; column++) {
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, columnRects[column]);
		
		CFArrayInsertValueAtIndex(array, column, path);
		CFRelease(path);
	}
	
	free(columnRects);
    
	return array;
}

- (void)drawRect:(NSRect)rect {
	// Draw a white background.
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:[self bounds]];
	
	// Initialize the text matrix to a known value
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	CTFramesetterRef framesetter = [self framesetter];
	CFArrayRef columnPaths = [self newColumns];
	
	CFIndex pathCount = CFArrayGetCount(columnPaths);
	CFIndex startIndex = 0;
	int column;
	for (column = 0; column < pathCount; column++) {
		CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, column);
		
		// Create a frame for this column and draw it.
		CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
		CTFrameDraw(frame, context);
		
		// Start the next frame at the first character not visible in this frame.
		CFRange frameRange = CTFrameGetVisibleStringRange(frame);
		startIndex += frameRange.length;
		
		CFRelease(frame);
	}
	
	CFRelease(columnPaths);
}

- (void)mouseDown:(NSEvent *)theEvent {
	if (COLUMN_COUNT_MIN == COLUMN_COUNT_MAX) {
		return;
	}
	
	if (_columnCount == COLUMN_COUNT_MIN) {
		_countIncrement = 1;
	}
	else if (_columnCount == COLUMN_COUNT_MAX) {
		_countIncrement = -1;
	}
	
	_columnCount = _columnCount + _countIncrement;
	
	[self setNeedsDisplay:YES];
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
    [_attributedString release];
    _attributedString = [attributedString copy];
    
    if (attributedString)
        // Re-draw the view if the input string changes.
        [self setNeedsDisplay:YES];
}

- (CTFramesetterRef)framesetter {
	if (_framesetter == NULL) {
		_framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
	}
	return _framesetter;
}

@end
