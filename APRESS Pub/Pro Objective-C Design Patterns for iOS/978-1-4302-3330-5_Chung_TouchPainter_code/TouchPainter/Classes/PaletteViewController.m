//
//  PaletteViewController.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/18/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "PaletteViewController.h"

@implementation PaletteViewController

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
  {
    // Custom initialization
    
  }
  return self;
}
 */

- (void) viewDidDisappear:(BOOL)animated
{
  // save the values of the sliders
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setFloat:[redSlider_ value] forKey:@"red"];
  [userDefaults setFloat:[greenSlider_ value] forKey:@"green"];
  [userDefaults setFloat:[blueSlider_ value] forKey:@"blue"];
  [userDefaults setFloat:[sizeSlider_ value] forKey:@"size"];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  // initialize the RGB sliders with
  // a StrokeColorCommand
  SetStrokeColorCommand *colorCommand = (SetStrokeColorCommand *)[redSlider_ command];
  
  // set each color component provider
  // to the color command
  [colorCommand setRGBValuesProvider: ^(CGFloat *red, CGFloat *green, CGFloat *blue)
   {
     *red = [redSlider_ value];
     *green = [greenSlider_ value];
     *blue = [blueSlider_ value];
   }];
  
  // set a post-update provider to the command
  // for any callback after a new color is set
  [colorCommand setPostColorUpdateProvider: ^(UIColor *color) 
   {
     [paletteView_ setBackgroundColor:color];
   }];
  
  
  // restore the original values of the sliders
  // and the color of the small palette view
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  CGFloat redValue = [userDefaults floatForKey:@"red"];
  CGFloat greenValue = [userDefaults floatForKey:@"green"];
  CGFloat blueValue = [userDefaults floatForKey:@"blue"];
  CGFloat sizeValue = [userDefaults floatForKey:@"size"];
  
  [redSlider_ setValue:redValue];
  [greenSlider_ setValue:greenValue];
  [blueSlider_ setValue:blueValue];
  [sizeSlider_ setValue:sizeValue];
  
  UIColor *color = [UIColor colorWithRed:redValue
                                   green:greenValue
                                    blue:blueValue
                                   alpha:1.0];
  
  [paletteView_ setBackgroundColor:color];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning 
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)dealloc 
{
  [redSlider_ release];
  [greenSlider_ release];
  [blueSlider_ release];
  [sizeSlider_ release];
  [super dealloc];
}

#pragma mark -
#pragma mark SetStrokeColorCommandDelegate methods

- (void) command:(SetStrokeColorCommand *) command 
                didRequestColorComponentsForRed:(CGFloat *) red
                                          green:(CGFloat *) green 
                                           blue:(CGFloat *) blue
{
  *red = [redSlider_ value];
  *green = [greenSlider_ value];
  *blue = [blueSlider_ value];
}

- (void) command:(SetStrokeColorCommand *) command
                didFinishColorUpdateWithColor:(UIColor *) color
{
  [paletteView_ setBackgroundColor:color];
}

#pragma mark SetStrokeSizeCommandDelegate method

- (void) command:(SetStrokeSizeCommand *)command 
                didRequestForStrokeSize:(CGFloat *)size
{
  *size = [sizeSlider_ value];
}

#pragma mark -
#pragma mark Slider event handler

- (IBAction) onCommandSliderValueChanged:(CommandSlider *)slider
{
  [[slider command] execute];
}


@end
