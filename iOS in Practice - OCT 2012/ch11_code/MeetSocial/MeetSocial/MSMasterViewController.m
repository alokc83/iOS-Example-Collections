//
//  MSMasterViewController.m
//  MeetSocial
//
//  Created by Bear Cahill on 7/21/12.
//  Copyright (c) 2012 BrainwashInc.com. All rights reserved.
//

#import "MSMasterViewController.h"

#import "MSDetailViewController.h"

@interface MSMasterViewController () {
}
@end

@implementation MSMasterViewController
@synthesize segSearchZipOrKeyword;
@synthesize segSearchGroupsOrEvents;
@synthesize tfSearchText;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)dealloc
{
    [segSearchZipOrKeyword release];
    [segSearchGroupsOrEvents release];
    [tfSearchText release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Search"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tfSearchText becomeFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [self doSearch];
    [textField resignFirstResponder];
    return NO;
}

-(void)writeToResultsFile:(NSString*)stringToStore;
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *path = documentsDirectoryPath;
    
	NSError *error = nil;
	[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error)
        NSLog(@"Dir Error: %@", error);
	
	path = [NSString stringWithFormat:@"%@/%@", path, @"results.json"];
	[stringToStore writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
        NSLog(@"Write Error: %@", error);
}

-(void)doSearch;
{
    NSString *groupsOrEvents =
        segSearchGroupsOrEvents.selectedSegmentIndex == 0 ? @"groups" : @"2/open_events";
    
    NSString *zipOrKeyword =
        segSearchZipOrKeyword.selectedSegmentIndex == 0 ? @"zip" : @"topic";
    
    NSString *apiKey = @"...";
    NSString *query = [NSString stringWithFormat:
                       @"https://api.meetup.com/%@?key=%@&sign=true&%@=%@",
                       groupsOrEvents,
                       apiKey,
                       zipOrKeyword,
                       tfSearchText.text];
    
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:query];
    NSHTTPURLResponse* retResp=nil;
    NSData *respData = [NSURLConnection sendSynchronousRequest:
                        [NSURLRequest requestWithURL:url]
                                             returningResponse:&retResp error:&error];
    
    if (error)
        NSLog(@"ERROR: %@", error);
    else
    {
        NSString *resultsJSON = [[[NSString alloc]
                                  initWithData:respData
                                  encoding:NSASCIIStringEncoding] autorelease];
        [self writeToResultsFile:resultsJSON];
    }
}

#define kSearchGorE @"SearchGorE"
#define kSearchZorK @"SearchZorK"
#define kSearchText @"SearchText"

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    NSLog(@"saving GorE: %d", segSearchGroupsOrEvents.selectedSegmentIndex);
    [coder encodeInt:segSearchGroupsOrEvents.selectedSegmentIndex forKey:kSearchGorE];
    [coder encodeInt:segSearchZipOrKeyword.selectedSegmentIndex forKey:kSearchZorK];
    [coder encodeObject:tfSearchText.text forKey:kSearchText];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    NSLog(@"GorE: %d", [coder decodeIntegerForKey:kSearchGorE]);
    [segSearchGroupsOrEvents setSelectedSegmentIndex:
        [coder decodeIntegerForKey:kSearchGorE]];
    [segSearchZipOrKeyword setSelectedSegmentIndex:
        [coder decodeIntegerForKey:kSearchZorK]];
    [tfSearchText setText:
        [coder decodeObjectForKey:kSearchText]];
}

@end
