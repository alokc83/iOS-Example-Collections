
/*
     File: ZBEZombieMeter.m
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

#import "ZBEZombieMeter.h"

@implementation ZBEZombieMeter
{
    UILabel *label;
}

@synthesize zombieLevel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 8;
        self.zombieLevel = 0;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Zombie Meter";
        label.font = [UIFont fontWithName:@"Helvetica" size:24];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        [label sizeToFit];
        CGRect labelFrame = label.frame;
        labelFrame.size.width = frame.size.width;
        label.frame = labelFrame;
    }
    
    return self;
}

- (void)setZombieLevel:(float)level
{
    zombieLevel = level;
    if ( zombieLevel < 0 )
    {
        zombieLevel = 0;
    }
    
    [self setNeedsDisplay];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return label.accessibilityLabel;
}

- (NSString *)accessibilityValue
{
    return [NSString stringWithFormat:@"%.0f%%", zombieLevel * 100];
}

- (void)drawRect:(CGRect)rect
{
    float pad = 20;
    float numberOfMeters = 10;
    float meterSpacing = 5;
    float yOrigin = CGRectGetMaxY(label.frame) + 10;
    
    UIBezierPath *background = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:8];
    [[UIColor whiteColor] setFill];
    [background fill];
    
    [[UIColor blackColor] setStroke];
    
    CGRect meter = CGRectMake(pad, yOrigin, rect.size.width - pad*2, (rect.size.height - yOrigin - (numberOfMeters * meterSpacing))/numberOfMeters);
    for ( NSInteger k = 0; k < numberOfMeters; k++ )
    {
        meter.origin.y = yOrigin + (meter.size.height + meterSpacing) * (numberOfMeters - 1 - k);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:meter cornerRadius:2];
        path.lineWidth = 1;

        float level = zombieLevel*10;
        if ( level > k )
        {
            if ( k < 3 )
            {
                [[UIColor greenColor] setFill];
            }
            else if ( k < 6 )
            {
                [[UIColor blueColor] setFill];
            }
            else
            {
                [[UIColor redColor] setFill];
            }
            
            float diff = (level - k);
            if ( diff > 0 && diff < 1 )
            {
                CGRect smallerRect = meter;
                smallerRect.origin.y += smallerRect.size.height - (smallerRect.size.height * diff);
                smallerRect.size.height *= diff;
                UIBezierPath *smallerPath = [UIBezierPath bezierPathWithRoundedRect:smallerRect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];
                [smallerPath fill];
            }
            else
            {
                [path fill];
            }
        }
        [path stroke];
    }

}

@end
