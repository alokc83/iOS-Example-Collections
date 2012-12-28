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
        [self fetchEntries];
        UIBarButtonItem *bbi = 
            [[UIBarButtonItem alloc] initWithTitle:@"Info" 
                                             style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(showInfo:)];

        [[self navigationItem] setRightBarButtonItem:bbi];

    }

    return self;
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

    [webViewController listViewController:self handleObject:entry];
}

- (void)parser:(NSXMLParser *)parser 
    didStartElement:(NSString *)elementName 
       namespaceURI:(NSString *)namespaceURI 
      qualifiedName:(NSString *)qualifiedName 
         attributes:(NSDictionary *)attributeDict
{
    NSLog(@"%@ found a %@ element", self, elementName);
    if ([elementName isEqual:@"channel"]) {
        
        // If the parser saw a channel, create new instance, store in our ivar
        channel = [[RSSChannel alloc] init]; 
        
        // Give the channel object a pointer back to ourselves for later 
        [channel setParentParserDelegate:self];
        
        // Set the parser's delegate to the channel object - ignore this warning for now
        [parser setDelegate:channel];
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    // Add the incoming chunk of data to the container we are keeping
    // The data always comes in the correct order
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    // Create the parser object with the data received from the web service
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];

    // Give it a delegate
    [parser setDelegate:self];

    // Tell it to start parsing - the document will be parsed and
    // the delegate of NSXMLParser will get all of its delegate messages
    // sent to it before this line finishes execution - it is blocking
    [parser parse];
    
    // Get rid of the XML data as we no longer need it
    xmlData = nil;

    // Get rid of the connection, no longer need it
    connection = nil;

    // Reload the table.. for now, the table will be empty.
    [[self tableView] reloadData];
    
    NSLog(@"%@\n %@\n %@\n", channel, [channel title], [channel infoString]);
}

- (void)connection:(NSURLConnection *)conn 
  didFailWithError:(NSError *)error
{
    // Release the connection object, we're done with it 
    connection = nil;
    
    // Release the xmlData object, we're done with it 
    xmlData = nil;
    
    // Grab the description of the error object passed to us
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@", 
                             [error localizedDescription]];
                             
    // Create and show an alert view with this error displayed
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:errorString
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
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
    
    return cell;
}

- (void)fetchEntries
{
    // Create a new data container for the stuff that comes back from the service
    xmlData = [[NSMutableData alloc] init];

    // Construct a URL that will ask the service for what you want -
    // note we can concatenate literal strings together on multiple 
    // lines in this way - this results in a single NSString instance
    NSURL *url = [NSURL URLWithString:@"http://forums.bignerdranch.com/smartfeed.php?"
                  @"limit=7_DAY&sort_by=standard&feed_type=RSS2.0&feed_style=COMPACT"];


    // For Apple's Hot News feed, replace the line above with
    // NSURL *url = [NSURL URLWithString:@"http://www.apple.com/pr/feeds/pr.rss"];

    // Put that URL into an NSURLRequest
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // Create a connection that will exchange this request for data from the URL
    connection = [[NSURLConnection alloc] initWithRequest:req 
                                                 delegate:self 
                                         startImmediately:YES];
}
@end
