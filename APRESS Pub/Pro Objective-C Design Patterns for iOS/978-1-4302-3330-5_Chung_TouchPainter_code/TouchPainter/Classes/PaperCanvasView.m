//
//  PaperCanvasView.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/16/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "PaperCanvasView.h"


@implementation PaperCanvasView


- (id)initWithFrame:(CGRect)frame 
{
  if ((self = [super initWithFrame:frame])) 
  {
    // Add a paper image view on top
    // as the canvas background
    UIImage *backgroundImage = [UIImage imageNamed:@"paper"];
    UIImageView *backgroundView = [[[UIImageView alloc] 
                                    initWithImage:backgroundImage] 
                                   autorelease];
    [self addSubview:backgroundView];
  }
  
  return self;
}

// implementation for other behaviors

@end
