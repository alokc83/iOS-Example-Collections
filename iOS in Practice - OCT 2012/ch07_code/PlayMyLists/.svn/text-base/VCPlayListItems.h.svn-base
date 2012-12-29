//
//  VCPlayListItems.h
//  PlayMyLists
//
//  Created by Bear Cahill on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppPlayList.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VCPlayListItems : UITableViewController <NSFetchedResultsControllerDelegate, MPMediaPickerControllerDelegate> {

    MPMusicPlayerController *musicPlayer;
	UIPopoverController *popoverController;
	UILabel *lblTitle;
}

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)insertNewObject;

@end
