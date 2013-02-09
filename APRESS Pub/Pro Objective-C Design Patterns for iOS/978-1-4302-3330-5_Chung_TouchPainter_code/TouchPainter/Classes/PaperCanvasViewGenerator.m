//
//  PaperCanvasViewGenerator.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/16/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "PaperCanvasViewGenerator.h"


@implementation PaperCanvasViewGenerator

- (CanvasView *) canvasViewWithFrame:(CGRect) aFrame
{
	return [[[PaperCanvasView alloc] initWithFrame:aFrame] autorelease];
}


@end
