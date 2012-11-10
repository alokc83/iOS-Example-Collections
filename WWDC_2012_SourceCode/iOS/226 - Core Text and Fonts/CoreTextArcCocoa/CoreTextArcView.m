/*
     File: CoreTextArcView.m 
 Abstract: Defines the MyDocument custom NSDocument subclass to control
 document window and interact with Font panel. 
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

#import "CoreTextArcView.h"
#import <AssertMacros.h>

#define ARCVIEW_DEFAULT_FONT_NAME	@"Didot"
#define ARCVIEW_DEFAULT_FONT_SIZE	64.0
#define ARCVIEW_DEFAULT_RADIUS		150.0

@implementation CoreTextArcView

@synthesize font = _font;
@synthesize string = _string;
@synthesize radius = _radius;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.font = [NSFont fontWithName:ARCVIEW_DEFAULT_FONT_NAME size:ARCVIEW_DEFAULT_FONT_SIZE];
		self.string = @"Curvaceous Type";
		self.radius = ARCVIEW_DEFAULT_RADIUS;
		self.showsGlyphBounds = NO;
		self.showsLineMetrics = NO;
		self.dimsSubstitutedGlyphs = NO;
    }
    return self;
}

- (void)dealloc
{
    [_font release];
    [_string release];
    [super dealloc];
}

typedef struct GlyphArcInfo {
	CGFloat			width;
	CGFloat			angle;	// in radians
} GlyphArcInfo;

static void PrepareGlyphArcInfo(CTLineRef line, CFIndex glyphCount, GlyphArcInfo *glyphArcInfo)
{
	NSArray *runArray = (NSArray *)CTLineGetGlyphRuns(line);
	
	// Examine each run in the line, updating glyphOffset to track how far along the run is in terms of glyphCount.
	CFIndex glyphOffset = 0;
	for (id run in runArray) {
		CFIndex runGlyphCount = CTRunGetGlyphCount((CTRunRef)run);
		
		// Ask for the width of each glyph in turn.
		CFIndex runGlyphIndex = 0;
		for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
			glyphArcInfo[runGlyphIndex + glyphOffset].width = CTRunGetTypographicBounds((CTRunRef)run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
		}
		
		glyphOffset += runGlyphCount;
	}
	
	double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	
	CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
	glyphArcInfo[0].angle = (prevHalfWidth / lineLength) * M_PI;
	
	// Divide the arc into slices such that each one covers the distance from one glyph's center to the next.
	CFIndex lineGlyphIndex = 1;
	for (; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
		CGFloat halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
		CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;
		
		glyphArcInfo[lineGlyphIndex].angle = (prevCenterToCenter / lineLength) * M_PI;
		
		prevHalfWidth = halfWidth;
	}
}

- (void)drawRect:(NSRect)rect {
	// Don't draw if we don't have a font or string
	if (self.font == NULL || self.string == NULL) 
		return;

	// Initialize the text matrix to a known value
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	// Draw a white background
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	
	CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)self.attributedString);
	assert(line != NULL);
	
	CFIndex glyphCount = CTLineGetGlyphCount(line);
	if (glyphCount == 0) {
		CFRelease(line);
		return;
	}
	
	GlyphArcInfo *	glyphArcInfo = (GlyphArcInfo*)calloc(glyphCount, sizeof(GlyphArcInfo));
	PrepareGlyphArcInfo(line, glyphCount, glyphArcInfo);
	
	// Move the origin from the lower left of the view nearer to its center.
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, CGRectGetMidX(NSRectToCGRect(rect)), CGRectGetMidY(NSRectToCGRect(rect)) - self.radius / 2.0);
	
	// Stroke the arc in red for verification.
	CGContextBeginPath(context);
	CGContextAddArc(context, 0.0, 0.0, self.radius, M_PI, 0.0, 1);
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	CGContextStrokePath(context);
	
	// Rotate the context 90 degrees counterclockwise.
	CGContextRotateCTM(context, M_PI_2);
	
	// Now for the actual drawing. The angle offset for each glyph relative to the previous glyph has already been calculated; with that information in hand, draw those glyphs overstruck and centered over one another, making sure to rotate the context after each glyph so the glyphs are spread along a semicircular path.
	CGPoint textPosition = CGPointMake(0.0, self.radius);
	CGContextSetTextPosition(context, textPosition.x, textPosition.y);
	
	CFArrayRef runArray = CTLineGetGlyphRuns(line);
	CFIndex runCount = CFArrayGetCount(runArray);
	
	CFIndex glyphOffset = 0;
	CFIndex runIndex = 0;
	for (; runIndex < runCount; runIndex++) {
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		CFIndex runGlyphCount = CTRunGetGlyphCount(run);
		Boolean	drawSubstitutedGlyphsManually = false;
		CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
		
		// Determine if we need to draw substituted glyphs manually. Do so if the runFont is not the same as the overall font.
		if (self.dimsSubstitutedGlyphs && ![self.font isEqual:(NSFont *)runFont]) {
			drawSubstitutedGlyphsManually = true;
		}
		
		CFIndex runGlyphIndex = 0;
		for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
			CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
			CGContextRotateCTM(context, -(glyphArcInfo[runGlyphIndex + glyphOffset].angle));
			
			// Center this glyph by moving left by half its width.
			CGFloat glyphWidth = glyphArcInfo[runGlyphIndex + glyphOffset].width;
			CGFloat halfGlyphWidth = glyphWidth / 2.0;
			CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y);
			
			// Glyphs are positioned relative to the text position for the line, so offset text position leftwards by this glyph's width in preparation for the next glyph.
			textPosition.x -= glyphWidth;
			
			CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
			textMatrix.tx = positionForThisGlyph.x;
			textMatrix.ty = positionForThisGlyph.y;
			CGContextSetTextMatrix(context, textMatrix);
			
			if (!drawSubstitutedGlyphsManually) {
				CTRunDraw(run, context, glyphRange);
			} 
			else {
				// We need to draw the glyphs manually in this case because we are effectively applying a graphics operation by setting the context fill color. Normally we would use kCTForegroundColorAttributeName, but this does not apply as we don't know the ranges for the colors in advance, and we wanted demonstrate how to manually draw.
				CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
				CGGlyph glyph;
				CGPoint position;
				
				CTRunGetGlyphs(run, glyphRange, &glyph);
				CTRunGetPositions(run, glyphRange, &position);
				
				CGContextSetFont(context, cgFont);
				CGContextSetFontSize(context, CTFontGetSize(runFont));
				CGContextSetRGBFillColor(context, 0.25, 0.25, 0.25, 0.5);
				CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
				
				CFRelease(cgFont);
			}
			
			// Draw the glyph bounds 
			if ((self.showsGlyphBounds) != 0) {
				CGRect glyphBounds = CTRunGetImageBounds(run, context, glyphRange);
				
				CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
				CGContextStrokeRect(context, glyphBounds);
			}
			// Draw the bounding boxes defined by the line metrics
			if ((self.showsLineMetrics) != 0) {
				CGRect lineMetrics;
				CGFloat ascent, descent;
				
				CTRunGetTypographicBounds(run, glyphRange, &ascent, &descent, NULL);
				
				// The glyph is centered around the y-axis
				lineMetrics.origin.x = -halfGlyphWidth;
				lineMetrics.origin.y = positionForThisGlyph.y - descent;
				lineMetrics.size.width = glyphWidth; 
				lineMetrics.size.height = ascent + descent;
				
				CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
				CGContextStrokeRect(context, lineMetrics);
			}
		}
		
		glyphOffset += runGlyphCount;
	}
	
	CGContextRestoreGState(context);
	
	free(glyphArcInfo);
	CFRelease(line);	
}

@dynamic attributedString;
- (NSAttributedString *)attributedString {
	// Create an attributed string with the current font and string.
	assert(self.font != nil);
	assert(self.string != nil);
	
	// Create our attributes
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName, [NSNumber numberWithInteger:0], NSLigatureAttributeName, nil];
	assert(attributes != nil);
	
	// Create the attributed string
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.string attributes:attributes];
	return [attrString autorelease];
}

@dynamic showsGlyphBounds;
- (BOOL)showsGlyphBounds {
	return _flags.showsGlyphBounds;
}

- (void)setShowsGlyphBounds:(BOOL)show {
	_flags.showsGlyphBounds = show ? 1 : 0;
}

@dynamic showsLineMetrics;
- (BOOL)showsLineMetrics {
	return _flags.showsLineMetrics;
}

- (void)setShowsLineMetrics:(BOOL)show {
	_flags.showsLineMetrics = show ? 1 : 0;
}

@dynamic dimsSubstitutedGlyphs;
- (BOOL)dimsSubstitutedGlyphs {
	return _flags.dimsSubstitutedGlyphs;
}

- (void)setDimsSubstitutedGlyphs:(BOOL)dim {
	_flags.dimsSubstitutedGlyphs = dim ? 1 : 0;
}

@end
