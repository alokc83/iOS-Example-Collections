//
//  StrokeColorCommand.m
//  TouchPainter
//
//  Created by Carlo Chung on 11/9/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "SetStrokeColorCommand.h"
#import "CoordinatingController.h"
#import "CanvasViewController.h"

@implementation SetStrokeColorCommand

@synthesize delegate=delegate_;
@synthesize postColorUpdateProvider=postColorUpdateProvider_;
@synthesize RGBValuesProvider=RGBValuesProvider_;


- (void) execute
{
  CGFloat redValue = 0.0;
  CGFloat greenValue = 0.0;
  CGFloat blueValue = 0.0;
  
  // Retrieve RGB values from a delegate or a block 
  
  // Delegation (object adapter) approach:
  [delegate_ command:self didRequestColorComponentsForRed:&redValue
                                                    green:&greenValue
                                                     blue:&blueValue];
  
  // Block approach:
  if (RGBValuesProvider_ != nil)
  {
    RGBValuesProvider_(&redValue, &greenValue, &blueValue);
  }
  
  // Create a color object based on the RGB values
  UIColor *color = [UIColor colorWithRed:redValue
                                   green:greenValue
                                    blue:blueValue
                                   alpha:1.0];
  
  // Assign it to the current canvasViewController
  CoordinatingController *coordinator = [CoordinatingController sharedInstance];
  CanvasViewController *controller = [coordinator canvasViewController];
  [controller setStrokeColor:color];
  
  // Forward a post update message
  
  // Delegation approach:
  [delegate_ command:self didFinishColorUpdateWithColor:color];
  
  // Block approach:
  if (postColorUpdateProvider_ != nil)
  {
    postColorUpdateProvider_(color);
  }
}

- (void) dealloc
{
  [RGBValuesProvider_ release];
  [postColorUpdateProvider_ release];
  [super dealloc];
}

@end
