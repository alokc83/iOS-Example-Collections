//
//  PlayerViewController.m
//  MPMediaPlayer
//
//  Created by Kevin Y. Kim on 9/19/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "PlayerViewController.h"

@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPausePressed:)];
    [self.pause setStyle:UIBarButtonItemStyleBordered];

    self.player = [MPMusicPlayerController applicationMusicPlayer];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(playingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:self.player];
    [notificationCenter addObserver:self
                           selector:@selector(playbackStateChanged:)
                               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object:self.player];
    [self.player beginGeneratingPlaybackNotifications];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:@[self.mediaItem]];
    [self.player setQueueWithItemCollection:collection];
    [self.player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.player endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.player];
}

- (IBAction)volumeChanged:(id)sender
{
    self.player.volume = [self.volume value];
}

- (IBAction)donePressed:(id)sender
{
    [self.player stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playPausePressed:(id)sender
{
    MPMusicPlaybackState playbackState = [self.player playbackState];
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[self.player play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[self.player pause];
	}
}

#pragma mark - MPMusicPlayerController Notification Methods

- (void)playingItemChanged:(NSNotification *)notification
{
	MPMediaItem *currentItem = [self.player nowPlayingItem];
    if (nil == currentItem) {
        [self.imageView setImage:nil];
        [self.imageView setHidden:YES];
        [self.artist setText:nil];
        [self.song setText:nil];
    }
    else {
        MPMediaItemArtwork *artwork = [currentItem valueForProperty: MPMediaItemPropertyArtwork];
        if (artwork) {
            UIImage *artworkImage = [artwork imageWithSize:CGSizeMake(320, 320)];
            [self.imageView setImage:artworkImage];
            [self.imageView setHidden:NO];
        }
        
        // Display the artist and song name for the now-playing media item
        [self.artist setText:[currentItem valueForProperty:MPMediaItemPropertyArtist]];
        [self.song setText:[currentItem valueForProperty:MPMediaItemPropertyTitle]];
    }
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    MPMusicPlaybackState playbackState = [self.player playbackState];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self.toolbar items]];
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
        [items replaceObjectAtIndex:2 withObject:self.play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
        [items replaceObjectAtIndex:2 withObject:self.pause];
	}
    [self.toolbar setItems:items animated:NO];
}

@end
