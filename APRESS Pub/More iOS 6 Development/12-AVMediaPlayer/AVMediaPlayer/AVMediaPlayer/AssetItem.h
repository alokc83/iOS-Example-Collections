//
//  AssetItem.h
//  AVMediaPlayer
//
//  Created by Kevin Y. Kim on 9/21/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVAsset;

@interface AssetItem : NSObject <NSCopying>

@property (strong, nonatomic) NSURL *assetURL;
@property (strong, nonatomic) AVAsset *asset;

@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *artist;
@property (strong, nonatomic, readonly) UIImage *image;

@property (assign, nonatomic, readonly) BOOL metadataLoaded;
@property (assign, nonatomic, readonly) BOOL isVideo;

- (id)initWithURL:(NSURL *)aURL;
- (id)initWithAsset:(AssetItem *)assetItem;

- (void)loadAssetMetadataWithCompletionHandler:(void (^)(AssetItem *assetItem))completion;
- (void)loadAssetForPlayingWithCompletionHandler:(void (^)(AssetItem *assetItem, NSArray *keys))completion;

@end
