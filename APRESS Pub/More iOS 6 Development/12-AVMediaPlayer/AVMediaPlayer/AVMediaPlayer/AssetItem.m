//
//  AssetItem.m
//  AVMediaPlayer
//
//  Created by Kevin Y. Kim on 9/21/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "AssetItem.h"
#import <AVFoundation/AVFoundation.h>

#define kAssetItemDispatchQueue "AssetQueue"

@interface AssetItem ()
@property (strong, nonatomic) dispatch_queue_t dispatchQueue;
- (AVAsset *)assetCopyIfLoaded;
- (AVAsset *)localAsset;
- (NSString *)loadTitleForAsset:(AVAsset *)a;
- (NSString *)loadArtistForAsset:(AVAsset *)a;
- (UIImage *)loadImageForAsset:(AVAsset *)a;
- (BOOL)assetHasVideo:(AVAsset *)a;
@end


@implementation AssetItem

@synthesize title = _title;
@synthesize artist = _artist;
@synthesize image = _image;

- (id)initWithURL:(NSURL *)aURL
{
    self = [super init];
    if (self) {
        self.assetURL = aURL;
        self.dispatchQueue = dispatch_queue_create(kAssetItemDispatchQueue, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (id)initWithAsset:(AssetItem *)assetItem
{
    self = [super init];
	if (self) {
		self.assetURL = assetItem.assetURL;
        self.asset = [assetItem assetCopyIfLoaded];
        _title = assetItem.title;
        _artist = assetItem.artist;
        _image = assetItem.image;
        _metadataLoaded = assetItem.metadataLoaded;
        _isVideo = assetItem.isVideo;
        
        self.dispatchQueue = dispatch_queue_create(kAssetItemDispatchQueue, DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

#pragma mark - NSCopying Protocol Methods

- (id)copyWithZone:(NSZone *)zone
{
	AssetItem *copy = [[AssetItem allocWithZone:zone] initWithAsset:self];
	return copy;
}

- (BOOL)isEqual:(id)anObject
{
	if (self == anObject)
		return YES;
	
	if ([anObject isKindOfClass:[AssetItem class]]) {
		AssetItem *assetItem = anObject;
		if (self.assetURL && assetItem.assetURL)
			return [self.assetURL isEqual:assetItem.assetURL];
		return NO;
	}
	return NO;
}

- (NSUInteger)hash
{
    return (self.assetURL) ? [self.assetURL hash] : [super hash];
}

#pragma mark - Property Overrides

// Make a copy since AVAsset can only be safely accessed from one thread at a time
- (AVAsset*)asset
{
	__block AVAsset *theAsset = nil;
	dispatch_sync(self.dispatchQueue, ^(void) {
		theAsset = [[self localAsset] copy];
	});
	return theAsset;
}

- (NSString *)title
{
    if (_title == nil)
        return [self.assetURL lastPathComponent];
    return _title;
}

- (NSString *)artist
{
    if (_artist == nil)
        return @"Unknown";
    return _artist;
}

#pragma mark - Instance Methods

- (void)loadAssetMetadataWithCompletionHandler:(void (^)(AssetItem *assetItem))completion
{
    dispatch_async(self.dispatchQueue, ^(void){
        AVAsset *a = [self localAsset];
        [a loadValuesAsynchronouslyForKeys:@[@"commonMetadata"] completionHandler:^{
            NSError *error;
            AVKeyValueStatus cmStatus = [a statusOfValueForKey:@"commonMetadata" error:&error];
            switch (cmStatus) {
                case AVKeyValueStatusLoaded:
                    _title = [self loadTitleForAsset:a];
                    _artist = [self loadArtistForAsset:a];
                    _image = [self loadImageForAsset:a];
                    _metadataLoaded = YES;
                    break;
                    
                case AVKeyValueStatusFailed:
                case AVKeyValueStatusCancelled:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"The asset's available metadata formats were not loaded:\n%@", [error localizedDescription]);
                    });
                    break;
            }
            
            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                    completion(self);
            });
        }];
    });
}

- (void)loadAssetForPlayingWithCompletionHandler:(void (^)(AssetItem *assetItem, NSArray *keys))completion;
{
    dispatch_async(self.dispatchQueue, ^(void){
        NSArray *keys = @[ @"tracks", @"playable" ];
        AVAsset *a = [self localAsset];
        [a loadValuesAsynchronouslyForKeys:keys completionHandler:^{
            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                    completion(self, keys);
            });
        }];
    });
}

#pragma mark - (Private) Instance Methods

- (AVAsset*)assetCopyIfLoaded
{
	__block AVAsset *theAsset = nil;
	dispatch_sync(self.dispatchQueue, ^(void){
		theAsset = [_asset copy];
	});
	return theAsset;
}

// lazy instantiation on local dispatch queue
- (AVAsset*)localAsset
{
    //check( dispatch_get_current_queue() == self.assetQueue );
    
    if (_asset == nil) {
        _asset = [[AVURLAsset alloc] initWithURL:self.assetURL options:nil];
    }
    return  _asset;
}

- (NSString *)loadTitleForAsset:(AVAsset *)a
{
    //	check( dispatch_get_current_queue() == self.assetQueue );
    NSString *assetTitle = nil;
    NSArray *titles = [AVMetadataItem metadataItemsFromArray:[a commonMetadata] withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
    if ([titles count] > 0) {
        // Try to get a title that matches one of the user's preferred languages.
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        
        for (NSString *thisLanguage in preferredLanguages) {
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:thisLanguage];
            NSArray *titlesForLocale = [AVMetadataItem metadataItemsFromArray:titles withLocale:locale];
            if ([titlesForLocale count] > 0) {
                assetTitle = [[titlesForLocale objectAtIndex:0] stringValue];
                break;
            }
        }
        
        // No matches in any of the preferred languages. Just use the primary title metadata we find.
        if (assetTitle == nil) {
            assetTitle = [[titles objectAtIndex:0] stringValue];
        }
    }
    return assetTitle;
}

- (NSString *)loadArtistForAsset:(AVAsset *)a
{
    //	check( dispatch_get_current_queue() == self.assetQueue );
    NSString *assetArtist = nil;
    NSArray *titles = [AVMetadataItem metadataItemsFromArray:[a commonMetadata] withKey:AVMetadataCommonKeyArtist keySpace:AVMetadataKeySpaceCommon];
    if ([titles count] > 0) {
        // Try to get a artist that matches one of the user's preferred languages.
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        
        for (NSString *thisLanguage in preferredLanguages) {
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:thisLanguage];
            NSArray *titlesForLocale = [AVMetadataItem metadataItemsFromArray:titles withLocale:locale];
            if ([titlesForLocale count] > 0) {
                assetArtist = [[titlesForLocale objectAtIndex:0] stringValue];
                break;
            }
        }
        
        // No matches in any of the preferred languages. Just use the primary artist metadata we find.
        if (assetArtist == nil) {
            assetArtist = [[titles objectAtIndex:0] stringValue];
        }
    }
    return assetArtist;
}

- (UIImage *)loadImageForAsset:(AVAsset *)a
{
    //	check( dispatch_get_current_queue() == self.assetQueue );
    UIImage *assetImage = nil;
    NSArray *images = [AVMetadataItem metadataItemsFromArray:[a commonMetadata] withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon];
    if ([images count] > 0) {
        AVMetadataItem *item = [images objectAtIndex:0];
        NSData *imageData = nil;
        if ([item.value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *valueDict = (NSDictionary *)item.value;
            imageData = [valueDict objectForKey:@"data"];
        }
        else if ([item.value isKindOfClass:[NSData class]])
            imageData = (NSData *)item.value;
        assetImage = [UIImage imageWithData:imageData];
    }
    return assetImage;
}

- (BOOL)assetHasVideo:(AVAsset *)a
{
    NSArray *videoTracks = [a tracksWithMediaType:AVMediaTypeVideo];
    return ([videoTracks count] > 0);
}

@end
