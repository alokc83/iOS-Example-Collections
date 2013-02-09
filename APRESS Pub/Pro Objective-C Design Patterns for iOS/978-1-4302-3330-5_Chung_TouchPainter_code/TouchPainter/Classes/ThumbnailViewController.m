//
//  ScribblesViewController.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/18/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ThumbnailViewController.h"


@implementation ThumbnailViewController


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  // set the table view's background
  // with a dark cloth texture image
  UIColor *backgroundColor = [UIColor colorWithPatternImage:
                              [UIImage imageNamed:@"background_texture"]];
  [[self view] setBackgroundColor:backgroundColor];
  
  // initialize the scribble manager
  scribbleManager_ = [[ScribbleManager alloc] init];
  
  // show number of scribbles available
  NSInteger numberOfScribbles = [scribbleManager_ numberOfScribbles];
  [navItem_ setTitle:[NSString stringWithFormat:
                      numberOfScribbles > 1 ? @"%d items" : @"%d item", 
                      numberOfScribbles]];
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
  [navItem_ release];
  [scribbleManager_ release];
  [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  // Return the number of sections.
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  // Return the number of rows in the section.
  CGFloat numberOfPlaceholders = [ScribbleThumbnailCell numberOfPlaceHolders];
  NSInteger numberOfScribbles = [scribbleManager_ numberOfScribbles];
  NSInteger numberOfRows = ceil(numberOfScribbles / numberOfPlaceholders);
  return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  
  static NSString *CellIdentifier = @"Cell";
  
  ScribbleThumbnailCell *cell = (ScribbleThumbnailCell *)[tableView 
                                                          dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[[ScribbleThumbnailCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:CellIdentifier] autorelease];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  }
  
  // Configure the cell...
  
  // populate  thumbnails in each cell
  
  // get max number of thumbnail a thumbnail
  // cell can support
  NSInteger numberOfSupportedThumbnails = [ScribbleThumbnailCell numberOfPlaceHolders];
  
  // we can only add max numberOfSupportedThumbnails
  // at a time in each cell
  // e.g. numberOfSupportedThumbnails = 3
  // thumbnail index in the scribble manager is (row index *3) +0, +1, +2
  NSUInteger rowIndex = [indexPath row];
  NSInteger thumbnailIndex = rowIndex *numberOfSupportedThumbnails;
  NSInteger numberOfScribbles = [scribbleManager_ numberOfScribbles];
  for (NSInteger i = 0; i < numberOfSupportedThumbnails && 
       (thumbnailIndex + i) < numberOfScribbles; ++i)
  {
    UIView *scribbleThumbnail = [scribbleManager_ scribbleThumbnailViewAtIndex:
                                            thumbnailIndex + i];
    [cell addThumbnailView:scribbleThumbnail atIndex:i];
  }
  
  return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 150;
}

@end
