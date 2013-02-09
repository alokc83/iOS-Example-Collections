//
//  AVPlayerView.h
//  AVMediaPlayer
//
//  Created by Kevin Y. Kim on 9/22/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface AVPlayerView : UIView

@property (strong, nonatomic) AVPlayer* player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
