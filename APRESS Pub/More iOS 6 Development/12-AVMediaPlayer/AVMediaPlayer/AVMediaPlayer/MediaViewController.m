//
//  MediaViewController.m
//  AVMediaPlayer
//
//  Created by Kevin Y. Kim on 9/20/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "MediaViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AssetItem.h"
#import "PlayerViewController.h"

@interface MediaViewController ()
- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
- (void)updateCellWithAssetItem:(AssetItem *)assetItem;
@end

@implementation MediaViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PlayerViewController *pvc = segue.destinationViewController;
    UITableViewCell *cell = sender;
    pvc.assetItem = [self.assets objectAtIndex:cell.tag];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.assets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MediaCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Instance Methods

- (void)loadAssetsForMediaType:(MPMediaType)mediaType
{
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    NSNumber *mediaTypeNumber= [NSNumber numberWithInt:mediaType];
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber forProperty:MPMediaItemPropertyMediaType];
    [query addFilterPredicate:predicate];
    
    NSMutableArray *mediaAssets = [[NSMutableArray alloc] initWithCapacity:[[query items] count]];
    for (MPMediaItem *item in [query items]) {
        [mediaAssets addObject:[[AssetItem alloc] initWithURL:[item valueForProperty:MPMediaItemPropertyAssetURL]]];
    }
    self.assets = mediaAssets;
}

#pragma mark - (Private) Instance Methods

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    AssetItem *assetItem = [self.assets objectAtIndex:row];
    if (!assetItem.metadataLoaded) {
        [assetItem loadAssetMetadataWithCompletionHandler:^(AssetItem *assetItem){
            [self updateCellWithAssetItem:assetItem];
        }];
    }
    
    cell.textLabel.text = [assetItem title];
    cell.detailTextLabel.text = [assetItem artist];
    cell.tag = row;
}


- (void)updateCellWithAssetItem:(AssetItem *)assetItem
{
	NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
        AssetItem *visibleItem = [self.assets objectAtIndex:[indexPath row]];
		if ([assetItem isEqual:visibleItem]) {
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			[self configureCell:cell forIndexPath:indexPath];
			[cell setNeedsLayout];
			break;
		}
	}
}

@end
