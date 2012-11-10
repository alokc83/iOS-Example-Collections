
/*
     File: Page.m
 Abstract: 
 
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

#import "Page.h"

#define STAGE_DIRECTION_COLOR [UIColor grayColor]
#define SPEAKER_COLOR [UIColor colorWithHue:.44 saturation:1.0 brightness:.5 alpha:1.0]
#define TEXT_COLOR [UIColor blackColor]

#define SELECTION_COLOR [UIColor colorWithHue:.6 saturation:.6 brightness:.7 alpha:1.0]
#define SELECTION_TEXT_COLOR [UIColor whiteColor]

@interface Page ()
{
    NSDictionary *_stageDirectionAttributes;
    NSDictionary *_speakerAttributes;
    NSDictionary *_textAttributes;
}
@end

@implementation Page

- (id)initWithTitle:(NSString *)title paragraphs:(NSArray *)paragraphs {
    self = [super init];
    if(self) {
        self.title = title;
        self.paragraphs = paragraphs;
        self.selectedParagraph = NSNotFound;
        self.lineHeight = 25.0;
        
        UIFont *defaultFont = [UIFont fontWithName:@"HoeflerText-Regular" size:24.];
        UIFont *boldFont = [UIFont fontWithName:@"HoeflerText-Black" size:24.];
        
        // Put together predefined style dictionaries:
        
        // stage direction
        NSMutableParagraphStyle *stageStyle = [[NSMutableParagraphStyle alloc] init];
        stageStyle.alignment = NSTextAlignmentCenter;
        stageStyle.lineSpacing = 10.;
        
        UIFont *italicFont = [UIFont fontWithName:@"Helvetica-LightOblique" size:24.];
        
        _stageDirectionAttributes = @{ NSForegroundColorAttributeName : STAGE_DIRECTION_COLOR,
        NSFontAttributeName : italicFont,
        NSParagraphStyleAttributeName : stageStyle};
        
        // speaker name
        _speakerAttributes = @{ NSForegroundColorAttributeName : SPEAKER_COLOR,
        NSFontAttributeName : boldFont};
        
        // regular text
        _textAttributes = @{ NSForegroundColorAttributeName : TEXT_COLOR,
        NSFontAttributeName : defaultFont};
    }
    return self;
}

- (NSString *)speakerForParagraph:(NSDictionary *)paragraph {
    return [NSString stringWithFormat:@"%@. ", [paragraph objectForKey:@"speaker"]];
}

- (NSString *)textForParagraph:(NSDictionary *)paragraph {
    return [paragraph objectForKey:@"text"];
}

- (BOOL)paragraphIsStageDirection:(NSDictionary *)paragraph {
    return [[paragraph objectForKey:@"speaker"] isEqual:@"STAGE DIRECTION"];
}





- (NSAttributedString *)attributedStringForParagraph:(NSDictionary *)paragraph {
    NSMutableAttributedString *returnValue = [[NSMutableAttributedString alloc] init];

    NSString *speaker = [self speakerForParagraph:paragraph];
    NSString *text = [self textForParagraph:paragraph];
    
    // TODO: find stage directions and format them differently
    if([self paragraphIsStageDirection:paragraph]) {
        NSAttributedString *attributedStageDirection = [[NSAttributedString alloc] initWithString:text attributes:_stageDirectionAttributes];

        [returnValue appendAttributedString:attributedStageDirection];
    } else {
        NSAttributedString *attributedSpeaker = [[NSAttributedString alloc] initWithString:speaker attributes:_speakerAttributes];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:_textAttributes];

        [returnValue appendAttributedString:attributedSpeaker];
        [returnValue appendAttributedString:attributedText];
    }
    
    if([_paragraphs indexOfObject:paragraph] == _selectedParagraph) {
        [returnValue addAttribute:NSForegroundColorAttributeName value:SELECTION_TEXT_COLOR range:NSMakeRange(0, returnValue.length)];
        [returnValue addAttribute:NSBackgroundColorAttributeName value:SELECTION_COLOR range:NSMakeRange(0, returnValue.length)];
    }

    [returnValue enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, returnValue.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSMutableParagraphStyle *style = value ? [value mutableCopy] : [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = _lineHeight;
        style.maximumLineHeight = _lineHeight;
        
        [returnValue addAttribute:NSParagraphStyleAttributeName value:style range:range];
    }];

    return returnValue;
}





- (NSString *)stringForParagraph:(NSDictionary *)paragraph {
    NSMutableString *returnValue = [[NSMutableString alloc] init];
    
    NSString *speaker = [self speakerForParagraph:paragraph];
    NSString *text = [self textForParagraph:paragraph];
    
    [returnValue appendString:speaker];
    [returnValue appendString:text];
    
    return returnValue;
}








@end
