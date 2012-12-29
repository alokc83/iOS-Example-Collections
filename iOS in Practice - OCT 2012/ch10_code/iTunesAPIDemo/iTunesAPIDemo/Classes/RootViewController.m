//
//  RootViewController.m
//  iTunesAPIDemo
//
//  Created by Bear Cahill on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "JSON.h"

@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(void)hideAdBanner:(bool)hideIt;
{
	if ((hideIt && hidingAdBanner) || (!hideIt && !hidingAdBanner))
		return;
	
	hidingAdBanner = hideIt;
	NSLog(@"hiding banner: %d", hideIt);
	
	[UIView beginAnimations:nil context:nil];
	
	int adHeight = adBanner.frame.size.height;
	CGRect r = adBanner.frame;
	r.origin.y -= adHeight;
	adBanner.frame = r;
	
	r = webView.frame;
	r.origin.y -= adHeight;
	r.size.height += adHeight;
	webView.frame = r;
	
	[UIView commitAnimations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"MusicSearch";

	UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] 
				 initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
				 target:self 
				 action:@selector(doBtnSearch:)] 
				autorelease];
	[self.navigationItem setRightBarButtonItem:bbi];
	
	[self hideAdBanner:YES];	
}

-(void)doBtnSearch:(id)sender;
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		[self presentModalViewController:vcSearch animated:YES];
	else 
	{
		for (UIView *v in vcSearch.view.subviews)
			if ([v isKindOfClass:[UITextField class]]) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayDetailsView" object:v];
			}
	}
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	[self hideAdBanner:YES];
	NSLog(@"failed to load ad: %@", error);
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	NSLog(@"ad action did finish");
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	NSLog(@"banner action should begin");
	return YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	[self hideAdBanner:NO];
	NSLog(@"did load ad");
}

-(IBAction)doBtnCancel:(id)sender;
{
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self dismissModalViewControllerAnimated:YES];
	[textField resignFirstResponder];
	
	NSString *searchText = textField.text;
	searchText = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSString *url = [NSString stringWithFormat:@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/wa/wsSearch?term=%@&entity=musicTrack", searchText];
	NSLog(@"query url: %@", url);
	
	NSError *error;
	NSString *search = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
	
	search = [search stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
	NSDictionary *dict = [search JSONValue];
	[results release];
	results = [[dict objectForKey:@"results"] retain];
	
	[self.tableView reloadData];
	return NO;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell.
	NSDictionary *trackDict = [results objectAtIndex:indexPath.row];
	cell.textLabel.text = [trackDict objectForKey:@"trackName"];
	cell.detailTextLabel.text = [trackDict objectForKey:@"artistName"];
	NSString *imageURL = [trackDict objectForKey:@"artworkUrl60"];
	cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];

    return cell;
}

-(void)playSound:(NSString*)aFilePath
{
//	NSString *aFilePath = [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"mp4"];
	if (nil != aAudioPlayer)
	{
		[aAudioPlayer stop];
		[aAudioPlayer release];
	}
	aAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:aFilePath] error:NULL];
	[aAudioPlayer stop];
	[aAudioPlayer play];
}

-(void)doBtnImage:(id)sender;
{
	[sender removeFromSuperview];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"finished");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"%@", error);
}

-(NSString*)getFilePath;
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	NSString *exeName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSString *path = [documentsDirectoryPath stringByAppendingPathComponent:exeName];
	
	NSError *error;
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];	
	return path;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSDictionary *dict = [results objectAtIndex:selectedRow];
	if (buttonIndex == 0)
	{
		NSString *url = [dict objectForKey:@"trackViewUrl"];
		url = [url stringByReplacingOccurrencesOfString:@"http" withString:@"itms"];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//		[self zoomArtwork];
	}
	else if (buttonIndex == 1)
	{
		NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"previewUrl"]]];
		NSString *path = [NSString stringWithFormat:@"%@/soundTrack.mp4", [self getFilePath]];
		[fileData writeToFile:path atomically:YES];
		[self playSound:path];
//		[self zoomArtwork];
	}
	else if (buttonIndex == 2)
	{
//		NSString *artistViewUrl = [dict objectForKey:@"artistViewUrl"];
		NSString *artistViewUrl = [dict objectForKey:@"artworkUrl100"];
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:artistViewUrl]]];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
			[self presentModalViewController:vcWebView animated:YES];
		else 
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayDetailsView" object:webView];
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSDictionary *dict = [results objectAtIndex:indexPath.row];

	// 1st - launch the url (external)
//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dict objectForKey:@"previewUrl"]]];
	
	// 2nd - load it w/in the app (no done/back button)
//	UIViewController *vc = [[[UIViewController alloc] init] autorelease];
//	UIWebView *wv = [[[UIWebView alloc] init] autorelease];
//	[vc setView:wv];
//	[self presentModalViewController:vc animated:YES];

	// 3rd - download, store and play
//	NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[dict objectForKey:@"previewUrl"]]];
//	NSString *path = [NSString stringWithFormat:@"%@/soundTrack.mp4", [[NSBundle mainBundle] bundlePath]];
//	[fileData writeToFile:path atomically:YES];
//	[self playSound:path];
	
	// 4th - prompt to buy or listen
	selectedRow = indexPath.row;	
	UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:@"Buy or Listen" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Buy from iTunes", @"Listen to Preview", @"View Details", nil] autorelease];
	[as showInView:self.view];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[results release];
    [super dealloc];
}


@end

