//
//  DeleteScribbleCommand.m
//  TouchPainter
//
//  Created by Carlo Chung on 11/8/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "DeleteScribbleCommand.h"
#import "CoordinatingController.h"
#import "CanvasViewController.h"

@implementation DeleteScribbleCommand

- (void) execute
{
  // get a hold of the current
  // CanvasViewController from
  // the CoordinatingController
  CoordinatingController *coordinatingController = [CoordinatingController sharedInstance];
  CanvasViewController *canvasViewController = [coordinatingController canvasViewController];
  
  // create a new scribble for
  // canvasViewController
  Scribble *newScribble = [[[Scribble alloc] init] autorelease];
  [canvasViewController setScribble:newScribble];
}


@end
