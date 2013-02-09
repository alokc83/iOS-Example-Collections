//
//  CanvasView.m
//  TouchPainter
//
//  Created by Carlo Chung on 9/14/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "CanvasView.h"
#import "MarkRenderer.h"

@implementation CanvasView

@synthesize mark=mark_;


- (id)initWithFrame:(CGRect)frame 
{
  if ((self = [super initWithFrame:frame])) 
  {
    // Initialization code
    [self setBackgroundColor:[UIColor whiteColor]];
  }
  return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
  
  // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // create a renderer visitor
  MarkRenderer *markRenderer = [[[MarkRenderer alloc] initWithCGContext:context] autorelease];
  
  // pass this renderer along the mark composite structure
  [mark_ acceptMarkVisitor:markRenderer];
  
}


- (void)dealloc 
{
  [mark_ release];
  [super dealloc];
}

@end
