//
//  SVCSplitVController.m
//  Rayjobs
//
//  Created by Bear Cahill on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVCSplitVController.h"


@implementation SVCSplitVController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.delegate = self;	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInDetails:) name:@"DisplayDetailsView" object:nil]; 
}

-(void)viewDidAppear:(BOOL)animated;
{
	[super viewDidAppear:animated];
	
	NSLog(@"%d", self.interfaceOrientation);
//	UIInterfaceOrientation or = self.interfaceOrientation;
//	if (tbTop.items && [tbTop.items objectAtIndex:0] && UIInterfaceOrientationIsPortrait(or))
//	{
//		UIViewController *vc = [[[UIViewController alloc] init] autorelease];
//		UIView *v = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 80)] autorelease];
//		UITextView *tv = [[[UITextView alloc] initWithFrame:v.frame] autorelease];
//		[tv setText:@"Use the menu button to begin navigation.\nTap image below to dismiss this message."];
//		[tv setFont:[UIFont boldSystemFontOfSize:22]];
//		[tv setEditable:NO];
//		[v addSubview:tv];
//		[vc setView:v];
//		
//		[popover release];
//		popover = [[UIPopoverController alloc] initWithContentViewController:vc];
//		[popover setPopoverContentSize:v.frame.size animated:YES];
//		[popover presentPopoverFromBarButtonItem:[tbTop.items objectAtIndex:0] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//	}
}

-(void)displayInDetails:(NSNotification*)notif;
{
//	UIView *view = [[notif userInfo] objectForKey:@"view"];
	UIView *view = [notif object];
	for (UIView *v in [detailsView subviews])
		[v removeFromSuperview];
	[detailsView addSubview:view];
	return; 
	
	[displayedView release];
	displayedView = [view retain];
	
	for (UIView *v in [detailsView subviews])
		[v removeFromSuperview];

	UIViewController *vc = [[self viewControllers] objectAtIndex:1];
	CGRect r = vc.view.bounds; 
	[detailsView setFrame:r];
	if (r.origin.y != 44)
		r.origin.y = 44;
	[view setFrame:r];
	
	[detailsView addSubview:view];
//	[self resetSize];
//	[detailsView setNeedsLayout];
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//	UIViewController *vc = [[self viewControllers] objectAtIndex:1];
//	CGRect r = vc.view.bounds; 
//	r.origin.y += 44;
//	r.size.width = 500;
//	[UIView beginAnimations:nil context:nil];
//	[detailsView setFrame:r];
//	[UIView commitAnimations];
//}


-(void)resetSize;
{
	UIViewController *vc = [[self viewControllers] objectAtIndex:1];
	CGRect r = vc.view.bounds; 
//	r.size.width = 200;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	r.origin.y = 44;
	r.size.height -= 44;
	[detailsView setFrame:r];
//	[detailsView setBounds:r];
	[UIView commitAnimations];

	r = [displayedView frame];
	r.origin.y = 0;
	[displayedView setFrame:r];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
	
	[self performSelector:@selector(resetSize) withObject:nil afterDelay:0.5];
    return YES;
}

//- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
//{
//}

- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button
{
	[tbTop setItems:nil animated:NO];
}

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc
{
	//	[pc setPopoverContentSize:CGSizeMake(320, 300)];
	[barButtonItem setTitle:@"Menu"];
	[tbTop setItems:[NSArray arrayWithObject:barButtonItem] animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[popover release];
	[displayedView release];
    [super dealloc];
}


@end

