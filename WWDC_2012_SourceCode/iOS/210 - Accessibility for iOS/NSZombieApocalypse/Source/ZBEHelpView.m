
/*
     File: ZBEHelpView.m
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

#import "ZBEHelpView.h"
#import "ZBESymbolMarkView.h"

@implementation ZBEHelpView
{
    UITextView *textView;
    ZBESymbolMarkView *nextButton;
}

- (id)initWithFrame:(CGRect)frame
{
    frame.origin.y = -frame.size.height;
    
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 8;
    
    CGRect closeFrame = CGRectMake(20, frame.size.height - 140, 80, 80);
    ZBESymbolMarkView *closeView = [[ZBESymbolMarkView alloc] initWithFrame:closeFrame];
    [closeView addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeView];
    closeView.symbol = @"X";
    closeView.accessibilityLabel = @"Close";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 40)];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:82];
    label.text = @"NSZombieApocalypse";
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    CGRect labelFrame = label.frame;
    labelFrame.origin.x = (frame.size.width - labelFrame.size.width)/2;
    label.frame = labelFrame;
    [self addSubview:label];
    label.accessibilityTraits = UIAccessibilityTraitHeader;
    
    CGRect nextFrame = CGRectMake(frame.size.width - 100, frame.size.height - 140, 80, 80);
    nextButton = [[ZBESymbolMarkView alloc] initWithFrame:nextFrame];
    [nextButton addTarget:self action:@selector(nextSlide) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    nextButton.symbol = @"⇥";
    nextButton.accessibilityLabel = @"Next";

    float width = frame.size.width * .6;
    CGRect textViewFrame = CGRectMake(200 + ((frame.size.width - 200) - width)/2, CGRectGetMaxY(label.frame) + 30, width, frame.size.height * .6);
    textView = [[UITextView alloc] initWithFrame:CGRectIntegral(textViewFrame)];
    [self addSubview:textView];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"HelveticaNeue" size:36];
    textView.text = NSLocalizedStringFromTable(@"helpText1", @"Strings", nil);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smaller-zombie1.png"]];
    CGRect imageFrame = imageView.frame;
    imageFrame.origin.x = label.frame.origin.x - 20;
    imageFrame.origin.y = textViewFrame.origin.y;
    imageView.frame = imageFrame;
    [self addSubview:imageView];
    
    imageView.isAccessibilityElement = YES;
    imageView.accessibilityLabel = @"Poorly drawn, yet oddly menancing, zombie";
    
    return self;
}

- (void)previousSlide
{
    textView.text = NSLocalizedStringFromTable(@"helpText1", @"Strings", nil);
    [nextButton addTarget:self action:@selector(nextSlide) forControlEvents:UIControlEventTouchUpInside];
    nextButton.symbol = @"⇥";
    nextButton.accessibilityLabel = @"Next";
}

- (void)nextSlide
{
    textView.text = NSLocalizedStringFromTable(@"helpText2", @"Strings", nil);
    nextButton.symbol = @"⇤";
    [nextButton addTarget:self action:@selector(previousSlide) forControlEvents:UIControlEventTouchUpInside];
    nextButton.accessibilityLabel = @"Previous";
}

- (void)hide
{
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
 
    [UIView animateWithDuration:.35 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self.delegate helpDidClose:self];
    }];

}

- (void)drawRect:(CGRect)rect
{
    rect.size.height -= 40;
    
    [[UIColor whiteColor] setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomRight | UIRectCornerBottomLeft
                                                     cornerRadii:CGSizeMake(8, 8)];
    [path fill];
}

- (void)show
{
    CGRect frame = self.frame;
    frame.origin.y = 0;

    [UIView animateWithDuration:.35 animations:^{
        self.frame = frame;
    }];
}

@end
