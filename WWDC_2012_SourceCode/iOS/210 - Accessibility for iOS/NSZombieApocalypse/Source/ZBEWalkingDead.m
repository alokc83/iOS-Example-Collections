
/*
     File: ZBEWalkingDead.m
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

#import "ZBEWalkingDead.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ZBEBodyPart : UIView
@property(nonatomic) BOOL movingRight;
@end

@interface ZBEWalkingDeadHead : ZBEBodyPart
@end

@interface ZBEWalkingDeadBody : ZBEBodyPart
@end

@interface ZBEWalkingDeadRightLeg : ZBEBodyPart
@end

@interface ZBEWalkingDeadLeftLeg : ZBEBodyPart
@end

@interface ZBEWalkingDeadRightArm : ZBEBodyPart
@end

@interface ZBEWalkingDeadLeftArm : ZBEBodyPart
@end

@interface ZBEWalkingDead ()
@property (nonatomic, retain) ZBEWalkingDeadHead *head;
@property (nonatomic, retain) ZBEWalkingDeadBody *body;
@property (nonatomic, retain) ZBEWalkingDeadRightLeg *rightLeg;
@property (nonatomic, retain) ZBEWalkingDeadLeftLeg *leftLeg;
@property (nonatomic, retain) ZBEWalkingDeadRightArm *rightArm;
@property (nonatomic, retain) ZBEWalkingDeadLeftArm *leftArm;
@end

@implementation ZBEBodyPart


@synthesize movingRight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    //self.layer.borderColor = [[UIColor yellowColor] CGColor];
    //self.layer.borderWidth = 1;
    return self;
}

- (void)setMovingRight:(BOOL)move
{
    movingRight = move;
    [self setNeedsDisplay];
}

@end

@implementation ZBEWalkingDeadHead

- (void)drawRect:(CGRect)rect
{
    rect = CGRectInset(rect, 4, 4);
    
    rect = CGRectMake((rect.size.width - rect.size.height)/2 + 4, 8, rect.size.height, rect.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    [path setLineWidth:2];
    [path fill];
    [path stroke];

    UIBezierPath *rightEye, *leftEye, *mouth = [UIBezierPath bezierPath];
    if ( self.movingRight )
    {
        rightEye = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect) - 5, rect.origin.y + 15) radius:4 startAngle:0 endAngle:180 clockwise:YES];
        
        leftEye = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect) + 10, rect.origin.y + 15) radius:4 startAngle:0 endAngle:180 clockwise:YES];

        [mouth moveToPoint:CGPointMake(CGRectGetMidX(rect) , rect.origin.y + 30)];
        [mouth addLineToPoint:CGPointMake(CGRectGetMidX(rect) + 13, rect.origin.y + 30)];
    }
    else
    {
        rightEye = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect) - 10, rect.origin.y + 15) radius:4 startAngle:0 endAngle:180 clockwise:YES];
        
        leftEye = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect) + 5, rect.origin.y + 15) radius:4 startAngle:0 endAngle:180 clockwise:YES];
        
        [mouth moveToPoint:CGPointMake(CGRectGetMidX(rect) , rect.origin.y + 30)];
        [mouth addLineToPoint:CGPointMake(CGRectGetMidX(rect) - 13, rect.origin.y + 30)];
        
    }
    
    [rightEye setLineWidth:2];
    [rightEye stroke];

    [leftEye setLineWidth:2];
    [leftEye stroke];

    [mouth setLineWidth:2];
    [mouth stroke];

}

@end

@implementation ZBEWalkingDeadBody

- (void)drawRect:(CGRect)rect
{
    rect = CGRectInset(rect, 2, 2);
    float bodyWidth = rect.size.width / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((rect.size.width - bodyWidth)/2, 0, bodyWidth, rect.size.height)
                                               byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    [path fill];
    [path setLineWidth:2];
    [path stroke];
}

@end

@implementation ZBEWalkingDeadRightLeg

- (void)drawRect:(CGRect)rect
{
    UIView *body = [(ZBEWalkingDead *)[self superview] body];
    CGRect bodyFrame = body.frame;
    CGFloat legWidth = (rect.size.width/3);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(20, CGRectGetMaxY(bodyFrame) - 5, legWidth, rect.size.height*.25) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight  cornerRadii:CGSizeMake(3, 3)];
    [path setLineWidth:2];

    [[UIColor blackColor] setStroke];
    [[UIColor whiteColor] setFill];
    
    [path fill];
    [path stroke];
}

@end

@implementation ZBEWalkingDeadLeftLeg

- (void)drawRect:(CGRect)rect
{
    UIView *body = [(ZBEWalkingDead *)[self superview] body];
    CGRect bodyFrame = body.frame;
    CGFloat legWidth = (rect.size.width/3);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(30, CGRectGetMaxY(bodyFrame) - 5, legWidth, rect.size.height*.25) byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
    [[UIColor blackColor] setStroke];
    [path setLineWidth:2];
    [[UIColor whiteColor] setFill];

    [path fill];
    [path stroke];
}

@end

@implementation ZBEWalkingDeadRightArm

- (void)drawRect:(CGRect)rect
{
    UIView *head = [(ZBEWalkingDead *)[self superview] head];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    CGRect headFrame = head.frame;
    
    if ( !self.movingRight )
    {
        [path moveToPoint:CGPointMake(CGRectGetMidX(rect) - 10, CGRectGetMaxY(headFrame) + 10)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(rect) - 10 + rect.size.width/4, CGRectGetMaxY(headFrame) + 10)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(rect) - 10 + rect.size.width/2, CGRectGetMaxY(headFrame) + 10 + rect.size.height/10)];
    }
    else
    {
        [path moveToPoint:CGPointMake(CGRectGetMidX(rect) + 10, CGRectGetMaxY(headFrame) + 10)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(rect) + 10 - rect.size.width/4, CGRectGetMaxY(headFrame) + 10)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(rect) + 10 - rect.size.width/2, CGRectGetMaxY(headFrame) + 10 + rect.size.height/10)];
    }
    
    [[UIColor blackColor] setStroke];
    [path setLineWidth:12];
    [path stroke];

    
    [[UIColor whiteColor] setStroke];
    [path setLineWidth:8];
    [path stroke];
}

@end

@implementation ZBEWalkingDeadLeftArm

- (void)drawRect:(CGRect)rect
{
    UIView *head = [(ZBEWalkingDead *)[self superview] head];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    CGRect headFrame = head.frame;

    if ( !self.movingRight )
    {
        rect.origin.x -= 20;
        [path moveToPoint:CGPointMake(CGRectGetMidX(rect) + 20, CGRectGetMaxY(headFrame) + 10)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(rect) + 20 + rect.size.width/6, CGRectGetMaxY(headFrame) + 10)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(rect) + 20 + rect.size.width/6 + 10, CGRectGetMaxY(headFrame) + 10 + 20)];
    }
    else
    {
        [path moveToPoint:CGPointMake(CGRectGetMidX(rect) - 20, CGRectGetMaxY(headFrame) + 10)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(rect) - 20 - rect.size.width/6, CGRectGetMaxY(headFrame) + 10)];
        [path addLineToPoint:CGPointMake(CGRectGetMidX(rect) - 20 - rect.size.width/6 - 10, CGRectGetMaxY(headFrame) + 10 + 20)];
        
    }
    
    [[UIColor blackColor] setStroke];
    [path setLineWidth:12];
    [path stroke];

    [[UIColor whiteColor] setStroke];
    [path setLineWidth:8];
    [path stroke];
}

@end

@implementation ZBEWalkingDead
{
    ZBEWalkingDeadHead *head;
    ZBEWalkingDeadBody *body;
    ZBEWalkingDeadRightArm *rightArm;
    ZBEWalkingDeadLeftArm *leftArm;
    ZBEWalkingDeadRightLeg *rightLeg;
    ZBEWalkingDeadLeftLeg *leftLeg;
    
    CFAbsoluteTime startedWalking;
    float startedWalkingX;

    BOOL animated;
    BOOL walkingForward;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        self.head = [[ZBEWalkingDeadHead alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height*.25)];
        [self addSubview:self.head];
        
        self.body = [[ZBEWalkingDeadBody alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.head.frame), frame.size.width, frame.size.height*.375)];
        [self addSubview:self.body];

        self.leftArm = [[ZBEWalkingDeadLeftArm alloc] initWithFrame:CGRectMake(0, 0, frame.size.width + 20, frame.size.height)];
        [self addSubview:self.leftArm];
        
        self.rightArm = [[ZBEWalkingDeadRightArm alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.rightArm];

        self.rightLeg = [[ZBEWalkingDeadRightLeg alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.rightLeg];

        self.leftLeg = [[ZBEWalkingDeadLeftLeg alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.leftLeg];
    
        [self turnaround];
        
    }
    return self;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return @"Zombie";
}

- (void)turnaround
{
    walkingForward = !walkingForward;
    self.head.movingRight = !self.head.movingRight;
    self.body.movingRight = !self.head.movingRight;
    self.leftArm.movingRight = !self.head.movingRight;
    self.rightArm.movingRight = !self.head.movingRight;
    self.rightLeg.movingRight = !self.head.movingRight;
    self.leftLeg.movingRight = !self.head.movingRight;
}

- (void)walk
{
    if ( !animated )
    {
        return;
    }
    
    CGRect superviewFrame = [[self superview] frame];
    startedWalking = CFAbsoluteTimeGetCurrent();
    startedWalkingX = self.frame.origin.x;
    [UIView animateWithDuration:10 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{

        if ( !animated )
        {
            return;
        }
        
        if ( !walkingForward )
        {
            [self turnaround];
        }
        
        CGRect frame = self.frame;
        frame.origin.x = superviewFrame.size.width - frame.size.width - 50;
        self.frame = frame;
        
    } completion:^(BOOL finished) {
        
        if ( !animated )
        {
            return;
        }

        [self turnaround];

        startedWalking = CFAbsoluteTimeGetCurrent();
        startedWalkingX = self.frame.origin.x;
        CGRect frame = self.frame;
        frame.origin.x = 50;

        [UIView animateWithDuration:10 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            [self walk];
        }];

    }];
}

- (void)disassemble
{
    animated = NO;
    
    [UIView animateWithDuration:.75 animations:^{

        CGRect frame = self.head.frame;
        frame.origin.y = -100;
        self.head.frame = frame;
        
        frame = self.leftArm.frame;
        frame.origin.x = -100;
        self.leftArm.frame = frame;
        
        frame = self.rightArm.frame;
        frame.origin.x = [[self superview] frame].size.width + 100;
        self.rightArm.frame = frame;
        
        frame = self.leftLeg.frame;
        frame.origin.y = [[self superview] frame].size.height;
        frame.origin.x -= 50;
        self.leftLeg.frame = frame;
        
        frame = self.rightLeg.frame;
        frame.origin.y = [[self superview] frame].size.height;
        frame.origin.x += 50;
        self.rightLeg.frame = frame;
        
        frame = self.body.frame;
        frame.origin.y = [[self superview] frame].size.height;
        self.body.frame = frame;
        

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.5 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];

}

- (void)moveArms
{
    if ( !animated )
    {
        return;
    }
    
    float armRotation = 10 * M_PI/180;
    
    [UIView animateWithDuration:1.75 animations:^{
        
        self.rightArm.transform = CGAffineTransformMakeRotation(armRotation);
        self.leftArm.transform = CGAffineTransformMakeRotation(-armRotation);

        
    } completion:^(BOOL finished) {
        
        if ( !animated )
        {
            return;
        }
        

        [UIView animateWithDuration:1.75 animations:^{
            
            self.rightArm.transform = CGAffineTransformIdentity;
            self.leftArm.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {

            [self moveArms];
            
        }];
        
    }];
    
}

- (void)moveLegs
{
    if ( !animated )
    {
        return;
    }
    
    float legRotation = M_PI_4 * .35;
    [UIView animateWithDuration:2.5 animations:^{
        
        self.rightLeg.transform = CGAffineTransformMakeRotation(legRotation);
        self.leftLeg.transform = CGAffineTransformMakeRotation(-legRotation);
    
    } completion:^(BOOL finished) {

        if ( !animated )
        {
            return;
        }
        

        [UIView animateWithDuration:2.5 animations:^{

            self.rightLeg.transform = CGAffineTransformMakeRotation(-legRotation);
            self.leftLeg.transform = CGAffineTransformMakeRotation(legRotation);

        } completion:^(BOOL finished) {
           
            [self moveLegs];
        }];
        
    }];
}

- (void)animate
{
    animated = YES;
    
    [self moveArms];
    [self moveLegs];
    [self walk];
}

- (void)deanimate
{
    animated = NO;
    [self.layer removeAllAnimations];
    [self.rightArm.layer removeAllAnimations];
    [self.leftArm.layer removeAllAnimations];
    [self.rightLeg.layer removeAllAnimations];
    [self.leftLeg.layer removeAllAnimations];
    
    float percentage = (CFAbsoluteTimeGetCurrent() - startedWalking)/10;
    float xNow = fabsf(self.frame.origin.x - startedWalkingX) * percentage;
    CGRect frame = self.frame;
    frame.origin.x = xNow += self.frame.size.width/2;
    self.frame = frame;
}

@end
