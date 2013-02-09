//
//  StrategyViewController.m
//  Strategy
//
//  Created by Carlo Chung on 8/2/10.
//  Copyright Carlo Chung 2010. All rights reserved.
//

#import "StrategyViewController.h"


@implementation StrategyViewController

@synthesize numericTextField, alphaTextField;


/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
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

/*

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  id <InputValidator> numValidator = [[NumericInputValidator alloc] init];
  id <InputValidator> alphaValidator = [[AlphaInputValidator alloc] init];
  
  [numericTextField setInputValidator:numValidator];
  [alphaTextField setInputValidator:alphaValidator];
  
  [numValidator release];
  [alphaValidator release];
}
*/

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
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
  [numericTextField_ release];
  [alphaTextField_ release];
  [super dealloc];
  
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  //if (textField == numericTextField)
  //{
  // validate [textField text] and make sure
  // the value is numeric
  //}
  //else if (textField == alphaTextField)
  //{
  // validate [textField text] and make sure
  // the value contains only letters
  //}
  
  if ([textField isKindOfClass:[CustomTextField class]])
  {
    [(CustomTextField*)textField validate];
  }
}

@end
