//
//  PlayerViewController.m
//  AVMediaPlayer
//
//  Created by Kevin Y. Kim on 9/22/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "PlayerViewController.h"
#import <CoreMedia/CoreMedia.h>

static void *PlayerViewControllerStatusObservationContext = &PlayerViewControllerStatusObservationContext;
static void *PlayerViewControllerCurrentItemObservationContext = &PlayerViewControllerCurrentItemObservationContext;
static void *AVPlayerViewControllerRateObservationContext = &AVPlayerViewControllerRateObservationContext;

@interface PlayerViewController ()
@property (assign, nonatomic) float prescrubRate;
@property (strong, nonatomic) id playerTimerObserver;

- (void)showPlay;
- (void)showPause;
- (void)updatePlayPause;
- (void)updateRate;

- (void)addPlayerTimerObserver;
- (void)removePlayerTimerObserver;
- (void)updateScrubber:(CMTime)currentTime;

- (void)playerItemDidReachEnd:(NSNotification *)notification;

- (void)handleStatusContext:(NSDictionary *)change;
- (void)handleRateContext:(NSDictionary *)change;
- (void)handleCurrentItemContext:(NSDictionary *)change;
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
    self.pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pausePressed:)];
    [self.pause setStyle:UIBarButtonItemStyleBordered];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.assetItem) {
        [self.assetItem loadAssetForPlayingWithCompletionHandler:^(AssetItem *assetItem, NSArray *keys){
            NSError *error = nil;
            AVAsset *asset = assetItem.asset;
            for (NSString *key in keys) {
                AVKeyValueStatus status = [asset statusOfValueForKey:key error:&error];
                if (status == AVKeyValueStatusFailed) {
                    NSLog(@"Asset Load Failed: %@ | %@", [error localizedDescription], [error localizedFailureReason]);
                    return;
                }
                // need to handle AVKeyValueStatusCancelled
            }
            
            if (!asset.playable) {
                NSLog(@"Asset Can't be Played");
                return;
            }
            
            if (self.playerItem) {
                [self.playerItem removeObserver:self forKeyPath:@"status"];
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                                              object:self.playerItem];
            }
            self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
            [self.playerItem addObserver:self
                              forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                 context:PlayerViewControllerStatusObservationContext];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:self.playerItem];
            
            if (self.player == nil) {
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                [self.player addObserver:self
                              forKeyPath:@"currentItem"
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                 context:PlayerViewControllerCurrentItemObservationContext];
                [self.player addObserver:self
                              forKeyPath:@"rate"
                                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                 context:AVPlayerViewControllerRateObservationContext];
            }
            
            if (self.player.currentItem != self.playerItem)
                [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
            
            self.artist.text = self.assetItem.artist;
            self.song.text = self.assetItem.title;
            self.imageView.image = self.assetItem.image;
            self.imageView.hidden = self.assetItem.isVideo;
            self.scrubber.value = 0.0f;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Key Value Observer Method

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
	if (context == PlayerViewControllerStatusObservationContext) {
        [self handleStatusContext:change];
	}
	/* AVPlayer "rate" property value observer. */
	else if (context == AVPlayerViewControllerRateObservationContext) {
        [self handleRateContext:change];
	}
	else if (context == PlayerViewControllerCurrentItemObservationContext) {
        [self handleCurrentItemContext:change];
	}
	else {
        NSLog(@"Other");
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}

- (IBAction)beginScrubbing:(id)sender
{
	self.prescrubRate = self.player.rate;
	self.player.rate = 0.0f;
    [self removePlayerTimerObserver];
}

- (IBAction)scrub:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]]) {
		UISlider* slider = sender;
		if (CMTIME_IS_INVALID(self.playerItem.duration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(self.playerItem.duration);
		if (isfinite(duration)) {
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			double time = duration * (value - minValue) / (maxValue - minValue);
			[self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
            
            Float64 remainingSeconds = duration - time;
            self.elapsedTime.text = [NSString stringWithFormat:@"%d:%02d", (int)time / 60, (int)time % 60];
            self.remainingTime.text = [NSString stringWithFormat:@"%d:%02d", (int)remainingSeconds / 60, (int)remainingSeconds % 60];
		}
	}
}

- (IBAction)endScrubbing:(id)sender
{
	if (self.playerTimerObserver == nil) {
        [self addPlayerTimerObserver];
    }
    
	if (self.prescrubRate != 0.0f) {
        self.player.rate = self.prescrubRate;
        self.prescrubRate = 0.0f;
	}
}

- (IBAction)volumeChanged:(id)sender
{
    float volume = [self.volume value];
    NSArray *audioTracks = [self.assetItem.asset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    [self.playerItem setAudioMix:audioMix];
}

- (IBAction)donePressed:(id)sender
{
    [self.player pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playPressed:(id)sender
{
    [self.player play];
    [self updatePlayPause];
}

- (void)pausePressed:(id)sender
{
    [self.player pause];
    [self updatePlayPause];
}

- (IBAction)ratePressed:(id)sender
{
    float rate = self.player.rate;
    rate *= 2.0f;
    if (rate > 2.0f)
        rate = 0.5;
    self.player.rate = rate;
}

#pragma mark - (Private) Instance Methods

- (void)showPlay
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    [toolbarItems replaceObjectAtIndex:2 withObject:self.play];
    self.toolbar.items = toolbarItems;
}

- (void)showPause
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    [toolbarItems replaceObjectAtIndex:2 withObject:self.pause];
    self.toolbar.items = toolbarItems;
}

- (void)updatePlayPause
{
    if (self.player.rate == 0.0f)
        [self showPlay];
	else
        [self showPause];
}

- (void)updateRate
{
    float rate = self.player.rate;
    if (rate == 0.0f)
        rate = 1.0f;
    self.rate.title = [NSString stringWithFormat:@"%.1fx", rate];
}

- (void)addPlayerTimerObserver
{
    __block id blockSelf = self;
    self.playerTimerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC)
                                                                         queue:nil
                                                                    usingBlock:^(CMTime time){
                                                                        [blockSelf updateScrubber:time];
                                                                    }];
}

- (void)removePlayerTimerObserver
{
	if (self.playerTimerObserver) {
		[self.player removeTimeObserver:self.playerTimerObserver];
		self.playerTimerObserver = nil;
	}
}

- (void)updateScrubber:(CMTime)currentTime
{
	if (CMTIME_IS_INVALID(self.playerItem.duration)) {
		self.scrubber.minimumValue = 0.0;
		return;
	}
    
	double duration = CMTimeGetSeconds(self.playerItem.duration);
	if (isfinite(duration))
	{
		float minValue = [self.scrubber minimumValue];
		float maxValue = [self.scrubber maximumValue];
		double time = CMTimeGetSeconds([self.player currentTime]);
		[self.scrubber setValue:(maxValue - minValue) * time / duration + minValue];
        
        Float64 elapsedSeconds = CMTimeGetSeconds(currentTime);
        Float64 remainingSeconds = CMTimeGetSeconds(self.playerItem.duration) - elapsedSeconds;
        self.elapsedTime.text = [NSString stringWithFormat:@"%d:%02d", (int)elapsedSeconds / 60, (int)elapsedSeconds % 60];
        self.remainingTime.text = [NSString stringWithFormat:@"%d:%02d", (int)remainingSeconds / 60, (int)remainingSeconds % 60];
	}
}

- (void)handleStatusContext:(NSDictionary *)change
{
    [self updatePlayPause];
    
    AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    switch (status) {
        case AVPlayerStatusUnknown:
            [self removePlayerTimerObserver];
            [self updateScrubber:CMTimeMake(0, NSEC_PER_SEC)];
            break;
            
        case AVPlayerStatusReadyToPlay:
            [self addPlayerTimerObserver];
            break;
            
        case AVPlayerStatusFailed:
            NSLog(@"Player Status Failed");
            break;
    }
}

- (void)handleRateContext:(NSDictionary *)change
{
    [self updatePlayPause];
    [self updateRate];
}

- (void)handleCurrentItemContext:(NSDictionary *)change
{
    // We've added/replaced the AVPlayer's AVPlayerItem
    AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
    if (newPlayerItem != (id)[NSNull null]) {
        // We really have a new AVPlayerItem
        self.playerView.player = self.player;
        [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    }
    else {
        // No AVPlayerItem
        NSLog(@"No AVPlayerItem");
    }
}

@end
