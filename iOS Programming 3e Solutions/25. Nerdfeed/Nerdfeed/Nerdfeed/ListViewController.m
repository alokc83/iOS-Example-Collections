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

@implementation ListViewController
@synthesize webViewController;
- (id)initWithStyle:(UITableViewStyle)style 
{
    self = [super initWithStyle:style];

    if (self) {
        [self fetchEntries];
    }

    return self;
}

- (void)tableView:(UITableView *)tableView
                didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    // Push the web view controller onto the navigation stack - this implicitly 
    // creates the web view controller's view the first time through
    [[self navigationController] pushViewController:webViewController animated:YES];

    // Grab the selected item
    RSSItem *entry = [[channel items] objectAtIndex:[indexPath row]];

    // Construct a URL with the link string of the item
    NSURL *url = [NSURL URLWithString:[entry link]];
    
    // Construct a requst object with that URL
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    // Load the request into the web view 
    [[webViewController webView] loadRequest:req];
    
    // Set the title of the web view controller's navigation item
    [[webViewController navigationItem] setTitle:[entry title]];
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
