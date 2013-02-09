//
//  AudioViewController.m
//  AVMediaPlayer
//
//  Created by Kevin Y. Kim on 9/21/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "AudioViewController.h"

@implementation AudioViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadAssetsForMediaType:MPMediaTypeMusic];
}

@end
