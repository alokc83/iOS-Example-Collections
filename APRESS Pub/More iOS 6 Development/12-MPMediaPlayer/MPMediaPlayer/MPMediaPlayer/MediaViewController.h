//
//  MediaViewController.h
//  MPMediaPlayer
//
//  Created by Kevin Y. Kim on 9/19/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MediaViewController : UITableViewController

@property (strong, nonatomic) NSArray *mediaItems;
- (void)loadMediaItemsForMediaType:(MPMediaType)mediaType;

@end
