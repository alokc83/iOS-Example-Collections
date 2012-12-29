//
//  MovableImage.m
//
//  Created by Bear Cahill on 12/20/09.
//  Copyright 2009 Brainwash Inc. All rights reserved.
//

#import "MovableImageView.h"

@implementation MovableImageView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
}


-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[super touchesMoved:touches withEvent:event];
	
	float deltaX = [[touches anyObject] locationInView:self].x - [[touches anyObject] previousLocationInView:self].x;
	float deltaY = [[touches anyObject] locationInView:self].y - [[touches anyObject] previousLocationInView:self].y;
	self.transform = CGAffineTransformTranslate(self.transform, deltaX, deltaY);
}

@end
