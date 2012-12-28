//
//  ListViewController.m
//  Nerdfeed
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "RSSChannel.h"
#import "RSSItem.h"
#import "WebViewController.h"
#import "ChannelViewController.h"
#import "BNRFeedStore.h"

@interface ListViewController ()
- (void)transferBarButtonToViewController:(UIViewController *)vc;
@end

@implementation ListViewController
@synthesize webViewController;
- (void)transferBarButtonToViewController:(UIViewController *)vc
{
    // Get the navigation controller in the detail spot of the split view controller 
    UINavigationController *nvc = [[[self splitViewController] viewControllers] 
                                                                    objectAtIndex:1];

    // Get the root view controller out of that nav controller
    UIViewController *currentVC = [[nvc viewControllers] objectAtIndex:0];
    
    // If it's the same view controller, let's not do anything
    if (vc == currentVC)
        return;
    
    // Get that view controller's navigation item 
    UINavigationItem *currentVCItem = [currentVC navigationItem];
    
    // Tell new view controller to use left bar button item of current nav item 
    [[vc navigationItem] setLeftBarButtonItem:[currentVCItem leftBarButtonItem]];
    
    // Remove the bar button item from the current view controller's nav item
    [currentVCItem setLeftBarButtonItem:nil];
}
- (id)initWithStyle:(UITableViewStyle)style 
{
    self = [super initWithStyle:style];

    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeUpdated:)
                                                     name:BNRFeedStoreUpdateNotification 
                                                   object:nil];

        UIBarButtonItem *bbi = 
            [[UIBarButtonItem alloc] initWithTitle:@"Info" 
                                             style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(showInfo:)];

        [[self navigationItem] setRightBarButtonItem:bbi];

        UISegmentedControl *rssTypeControl = 
        [[UISegmentedControl alloc] initWithItems:
         [NSArray arrayWithObjects:@"BNR", @"Apple", nil]];
        [rssTypeControl setSelectedSegmentIndex:0];
        [rssTypeControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [rssTypeControl addTarget:self 
                           action:@selector(changeType:) 
                 forControlEvents:UIControlEventValueChanged];
        [[self navigationItem] setTitleView:rssTypeControl];

        [self fetchEntries];        
    }

    return self;
}

- (void)storeUpdated:(NSNotification *)note 
{
    NSLog(@"OK! %@", [NSThread currentThread]);
    [[self tableView] reloadData];
    NSLog(@"DONE");
}

- (void)changeType:(id)sender
{
    rssType = [sender selectedSegmentIndex];
    [self fetchEntries];
}
- (void)showInfo:(id)sender
{
    // Create the channel view controller
    ChannelViewController *channelViewController = [[ChannelViewController alloc] 
                                initWithStyle:UITableViewStyleGrouped];

    if ([self splitViewController]) {
        [self transferBarButtonToViewController:channelViewController];
            
        UINavigationController *nvc = [[UINavigationController alloc] 
                     initWithRootViewController:channelViewController];
        
        // Create an array with our nav controller and this new VC's nav controller
        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController], 
                                                 nvc, 
                                                 nil];

        // Grab a pointer to the split view controller
        // and reset its view controllers array.
        [[self splitViewController] setViewControllers:vcs];

        // Make detail view controller the delegate of the split view controller 
        [[self splitViewController] setDelegate:channelViewController];

        // If a row has been selected, deselect it so that a row 
        // is not selected when viewing the info
        NSIndexPath *selectedRow = [[self tableView] indexPathForSelectedRow];
        if (selectedRow)
            [[self tableView] deselectRowAtIndexPath:selectedRow animated:YES];
    } else {
        [[self navigationController] pushViewController:channelViewController
                                               animated:YES];
    }
    
    // Give the VC the channel object through the protocol message
    [channelViewController listViewController:self handleObject:channel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return io == UIInterfaceOrientationPortrait;
}
- (void)tableView:(UITableView *)tableView
                didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    // Push the web view controller onto the navigation stack - this implicitly 
    // creates the web view controller's view the first time through
    if (![self splitViewController])
        [[self navigationController] pushViewController:webViewController animated:YES];
    else {
        [self transferBarButtonToViewController:webViewController];
        // We have to create a new navigation controller, as the old one 
        // was only retained by the split view controller and is now gone
        UINavigationController *nav = 
        [[UINavigationController alloc] initWithRootViewController:webViewController];

        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController],
                                                 nav,
                                                 nil];

        [[self splitViewController] setViewControllers:vcs];

        // Make the detail view controller the delegate of the split view controller 
        [[self splitViewController] setDelegate:webViewController];
    }
    // Grab the selected item
    RSSItem *entry = [[channel items] objectAtIndex:[indexPath row]];
    //new
    [[BNRFeedStore sharedStore] markItemAsRead:entry];
    [[[self tableView] cellForRowAtIndexPath:indexPath] 
     setAccessoryType:UITableViewCellAccessoryCheckmark];

    [webViewController listViewController:self handleObject:entry];
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    return [[channel items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView 
                            dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:@"UITableViewCell"];
    }
    RSSItem *item = [[channel items] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item title]];
    // new
    if([[BNRFeedStore sharedStore] hasItemBeenRead:item]) {
        NSLog(@"READ: %@ %@", [item title], [NSThread currentThread]);
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }

    
    return cell;
}

- (void)fetchEntries
{
    UIView *currentTitleView = [[self navigationItem] titleView];
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] 
                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [[self navigationItem] setTitleView:aiView];
    [aiView startAnimating];

    
    void (^completionBlock)(RSSChannel *obj, NSError *err) = ^(RSSChannel *obj, NSError *err) {
        NSLog(@"Completion block called!");
        // When the request completes, this block will be called.
        [[self navigationItem] setTitleView:currentTitleView];
        
        if(!err) {
            // If everything went ok, grab the channel object and
            // reload the table.
            channel = obj;
            [[self tableView] reloadData];
        } else {
            
            // If things went bad, show an alert view
            NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@", 
                                     [err localizedDescription]];
            
            // Create and show an alert view with this error displayed
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];            
        }
    };
    
    // Initiate the request...
    if(rssType == ListViewControllerRSSTypeBNR) {
        channel = [[BNRFeedStore sharedStore] fetchRSSFeedWithCompletion:
        ^(RSSChannel *obj, NSError *err) {
        
            // Replace the activity indicator.
            [[self navigationItem] setTitleView:currentTitleView];
            
            if(!err) {
                // How many items are there currently?
                int currentItemCount = [[channel items] count];
                
                // Set our channel to the merged one
                channel = obj;
                
                // How many items are there now?
                int newItemCount = [[channel items] count];
                
                // For each new item, insert a new row. The data source 
                // will take care of the rest.
                int itemDelta = newItemCount - currentItemCount;
                if(itemDelta > 0) {
                    NSMutableArray *rows = [NSMutableArray array];
                    for(int i = 0; i < itemDelta; i++)
                        [rows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    
                    [[self tableView] insertRowsAtIndexPaths:rows 
                                            withRowAnimation:UITableViewRowAnimationTop];
                }
            }
        }];
        [[self tableView] reloadData];
    } else 
        [[BNRFeedStore sharedStore] fetchTopSongs:10 withCompletion:completionBlock];
        
    NSLog(@"Executing code at the end of fetchEntries");
}
@end
