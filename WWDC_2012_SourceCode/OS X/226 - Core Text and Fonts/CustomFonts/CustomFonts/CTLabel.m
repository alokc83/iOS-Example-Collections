
/*
     File: CTLabel.m
 Abstract: Class to draw a CTLine in a view.
 
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

#import "CTLabel.h"
#import "FontLoader.h"

@implementation CTLabel


static CTFontDescriptorRef sCascadeDescriptor = nil;

+ (void)initialize {
	[super initialize];
	
	@synchronized(self) {
		if (sCascadeDescriptor == nil) {
			NSMutableArray* theCascadeList = [NSMutableArray arrayWithCapacity:2];
			CTFontRef testFallbackFont = [[FontLoader sharedFontLoader] hiddenFontWithName:@"FallbackTestFont" size:kDefaultLabelFontSize];
			if (testFallbackFont) {
				[theCascadeList addObject:[(id)CTFontCopyFontDescriptor(testFallbackFont) autorelease]];
				CFRelease(testFallbackFont);
			}
			[theCascadeList addObject:[(id)CTFontDescriptorCreateWithNameAndSize(CFSTR("LastResort"), kDefaultLabelFontSize) autorelease]];
			sCascadeDescriptor = (CTFontDescriptorRef)CTFontDescriptorCreateWithAttributes((CFDictionaryRef)[NSDictionary dictionaryWithObject:theCascadeList forKey:(id)kCTFontCascadeListAttribute]);
		}
	}
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		_string = @"";
		_ctFontRef = nil;
		_fontSize = kDefaultLabelFontSize;
    }
    return self;
}

- (void)dealloc {
	[_ctFontRef release];
	[_string release];
	[super dealloc];
}


- (void)drawRect:(CGRect)rect {	
    CGRect bounds = [self bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextTranslateCTM( context, 0, bounds.size.height );
	CGContextScaleCTM(context, 1.0, -1.0);
	
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	
	CTFontRef baseFont = (CTFontRef)_ctFontRef;
	CTFontRef aFont = CTFontCreateCopyWithAttributes(baseFont, CTFontGetSize(baseFont), NULL, sCascadeDescriptor);
	NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)aFont, kCTFontAttributeName, nil];
	CFRelease(aFont);
	NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:_string attributes:attributes];
	CTLineRef ctLineRef = CTLineCreateWithAttributedString((CFAttributedStringRef)attributedString);
	if (ctLineRef) {
		CGRect lineBounds = CTLineGetBoundsWithOptions(ctLineRef, 0);
		CGContextSetTextPosition(context, bounds.size.width/2 - lineBounds.size.width/2, (bounds.size.height/2 - lineBounds.size.height/2) + CTFontGetDescent((CTFontRef)_ctFontRef));
		CTLineDraw(ctLineRef, context);
		CFRelease(ctLineRef);
	}
}

@end
