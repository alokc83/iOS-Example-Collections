
/*
     File: ZBEButtonCollectionView.m
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

#import "ZBEButtonCollectionView.h"
#import "ZBEButtonView.h"

@implementation ZBEButtonCollectionView
{
    UIImageView *trackingImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 8;
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.75];
    
    for ( NSInteger k = 0; k < kButtonTypeCount; k++ )
    {
        ZBEButtonView *button = [[ZBEButtonView alloc] initWithFrame:CGRectZero];
        [self addSubview:button];
        button.delegate = self;
        [button setTag:k];
        button.label = [self buttonLabelForType:k];
    }

    return self;
}

- (NSString *)buttonLabelForType:(ZBEButtonType)type
{
    switch ( type )
    {
        case kButtonTypeFree:
            return @"free()";
        case kButtonTypeRelease:
            return @"[self release]";
        case kButtonTypeAutorelease:
            return @"[self autorelease]";
        case kButtonTypeDealloc:
            return @"[self dealloc]";
        case kButtonTypeGC:
            return @"Garbage Collection";
        case kButtonTypeARC:
            return @"ARC!";
        default:
            break;
    }
    
    return nil;
}

- (void)trackingStarted:(ZBEButtonView *)button
{
    UIGraphicsBeginImageContext(button.bounds.size);
    [button.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if ( trackingImageView == nil )
    {
        trackingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [[self superview] addSubview:trackingImageView];
        trackingImageView.alpha = .5;
    }
    trackingImageView.image = image;
    [trackingImageView sizeToFit];
    CGRect frame = trackingImageView.frame;
    frame.origin = [[self superview] convertPoint:button.frame.origin fromView:self];
    trackingImageView.frame = frame;
    
    [self.delegate buttonSelected:button];
}

- (void)trackingContinued:(ZBEButtonView *)button location:(UITouch *)location
{
    CGPoint point = [location locationInView:[self superview]];
    CGRect frame = trackingImageView.frame;
    point.x -= button.frame.size.width/2;
    point.y -= button.frame.size.height/2;
    frame.origin = point;
    trackingImageView.frame = frame;
    
    [self.delegate buttonDragged:button location:location];
}

- (void)trackingEnded:(ZBEButtonView *)button location:(UITouch *)location
{
    [self.delegate buttonFinished:button trackingView:trackingImageView location:location];
    trackingImageView = nil;
}

- (void)layoutSubviews
{
    NSArray *subviews = [self subviews];
    NSInteger count = 0;
    
    CGRect bounds = self.bounds;
    CGSize buttonSize = [ZBEButtonView buttonSize];
    CGFloat xPad = (bounds.size.width - (buttonSize.width * 3)) / 4;
    CGFloat yPad = (bounds.size.height - (buttonSize.height * 2)) / 3;
    
    CGFloat x = xPad, y = 5;
    for ( UIView *subview in subviews )
    {
        if ( count > 0 && count % 3 == 0 )
        {
            x = xPad;
            y += buttonSize.height + yPad;
        }
        count++;
        
        CGRect frame = CGRectMake(x, y, buttonSize.width, buttonSize.height);
        subview.frame = CGRectIntegral(frame);
        
        x += buttonSize.width + xPad;
    }
}

@end
