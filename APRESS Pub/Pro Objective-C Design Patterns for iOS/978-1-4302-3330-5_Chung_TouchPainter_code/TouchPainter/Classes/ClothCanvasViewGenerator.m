//
//  ClothCanvasViewGenerator.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/16/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ClothCanvasViewGenerator.h"


@implementation ClothCanvasViewGenerator

- (CanvasView *) canvasViewWithFrame:(CGRect) aFrame
{
	return [[[ClothCanvasView alloc] initWithFrame:aFrame] autorelease];
}


@end
