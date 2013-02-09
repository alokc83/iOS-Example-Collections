//
//  VideoViewController.m
//  AVMediaPlayer
//
//  Created by Kevin Y. Kim on 9/21/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "VideoViewController.h"

@implementation VideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadAssetsForMediaType:MPMediaTypeAnyVideo];
}

@end
