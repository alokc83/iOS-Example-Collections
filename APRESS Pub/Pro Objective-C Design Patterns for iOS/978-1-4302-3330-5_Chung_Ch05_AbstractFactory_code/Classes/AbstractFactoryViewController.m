//
//  AbstractFactoryViewController.m
//  AbstractFactory
//
//  Created by Carlo Chung on 11/1/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "AbstractFactoryViewController.h"
#import "BrandingFactory.h"

@implementation AbstractFactoryViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	NSNumber * boolNumber = [NSNumber numberWithBool:YES];
	NSNumber * charNumber = [NSNumber numberWithChar:'a'];
	NSNumber * intNumber = [NSNumber numberWithInt:1];
	NSNumber * floatNumber = [NSNumber numberWithFloat:1.0];
	NSNumber * doubleNumber = [NSNumber numberWithDouble:1.0];

	NSLog(@"%@", [[boolNumber class] description]);
	NSLog(@"%@", [[charNumber class] description]);
	NSLog(@"%@", [[intNumber class] description]);
	NSLog(@"%@", [[floatNumber class] description]);
	NSLog(@"%@", [[doubleNumber class] description]);
	
	NSLog(@"%d", [boolNumber intValue]);
	NSLog(@"%@", [charNumber boolValue] ? @"YES" : @"NO");
	
	// construct the view from
	// branded UI elements obtained
	// from a BrandingFactory
	BrandingFactory * factory = [BrandingFactory factory];
	
	//...
	UIView * view = [factory brandedView];
	//... put the view on a proper location in view

	//...
	UIButton * button = [factory brandedMainButton];
	//... put the button on a proper location in view
	
	//...
	UIToolbar * toolbar = [factory brandedToolbar];
	//... put the toolbar on a proper location in view
}



/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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


- (void)dealloc {
    [super dealloc];
}

@end
