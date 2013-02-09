//
//  PrototypeController.m
//  TouchPainter
//
//  Created by Carlo Chung on 11/20/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "PrototypeController.h"
#import "Mark.h"
#import "CanvasView.h"

@implementation PrototypeController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  // The following code snippets are
  // for illustration purposes in 
  // the book only and not part of the
  // app
  id <Mark> selectedMark;
  NSMutableArray *templateArray = [[NSMutableArray alloc] initWithCapacity:1];
  id <Mark> patternTemplate = [selectedMark copy];
  
  // save the patternTemplate in
  // a data structure so it can be
  // used later
  [templateArray addObject:patternTemplate];
  
  CanvasView *canvasView;
  id <Mark> currentMark;
  int patternIndex;
  
  id <Mark> patternClone = [templateArray objectAtIndex:patternIndex];
  [currentMark addMark:patternClone];
  [canvasView setMark:currentMark];
  [canvasView setNeedsDisplay];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [super dealloc];
}


@end
