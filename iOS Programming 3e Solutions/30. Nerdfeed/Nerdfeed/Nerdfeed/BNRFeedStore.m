//
//  BNRFeedStore.m
//  Nerdfeed
//
//  Created by joeconway on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BNRFeedStore.h"
#import "BNRConnection.h"
#import "RSSChannel.h"
#import "RSSItem.h"

NSString * const BNRFeedStoreUpdateNotification = @"BNRFeedStoreUpdateNotification";


@implementation BNRFeedStore
+ (BNRFeedStore *)sharedStore
{
    static BNRFeedStore *feedStore = nil;
    if(!feedStore)
        feedStore = [[BNRFeedStore alloc] init];
    
    return feedStore;
}

// new
- (BOOL)hasItemBeenRead:(RSSItem *)item
{
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"Link"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"urlString like %@", 
                         [item link]];
    [req setPredicate:pred];
    NSArray *entries = [context executeFetchRequest:req error:nil];
    if([entries count] > 0)
        return YES ;
    
    return NO;
}

- (void)markItemAsRead:(RSSItem *)item
{
    if([self hasItemBeenRead:item])
        return;
    
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Link"
                                                         inManagedObjectContext:context];
    [obj setValue:[item link] forKey:@"urlString"];
    [context save:nil];
}
- (void)contentChange:(NSNotification *)note 
{
    [context mergeChangesFromContextDidSaveNotification:note];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{    
        NSNotification *updateNote = [NSNotification notificationWithName:BNRFeedStoreUpdateNotification 
                                                                   object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:updateNote];        
    }];
}

- (id)init 
{
    self = [super init];
    if(self) {
        [[NSNotificationCenter defaultCenter] 
          addObserver:self 
             selector:@selector(contentChange:) 
                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
               object:nil];

        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = 
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *ubContainer = [fm URLForUbiquityContainerIdentifier:nil];
        
/*        NSArray *a = [[NSArray alloc] initWithObjects:@"String", nil];
        [[NSFileManager defaultManager] createDirectoryAtURL:[ubContainer URLByAppendingPathComponent:@"Documents"]
                                 withIntermediateDirectories:YES attributes:nil error:nil];
        [a writeToURL:[[ubContainer URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"foo"] atomically:YES];*/
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:@"nerdfeed" forKey:NSPersistentStoreUbiquitousContentNameKey];
        [options setObject:ubContainer forKey:NSPersistentStoreUbiquitousContentURLKey];
        
        NSError *error = nil;
       /* NSString *dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                                NSUserDomainMask, 
                                                                YES) objectAtIndex:0];
        dbPath = [dbPath stringByAppendingPathComponent:@"feed.db"];
        NSURL *dbURL = [NSURL fileURLWithPath:dbPath];*/
        NSURL *nosyncDir = [ubContainer URLByAppendingPathComponent:@"feed.nosync"];
        [fm createDirectoryAtURL:nosyncDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSURL *dbURL = [nosyncDir URLByAppendingPathComponent:@"feed.db"];
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType 
                               configuration:nil
                                         URL:dbURL
                                     options:options
                                       error:&error]) {
            [NSException raise:@"Open failed"
                        format:@"Reason: %@", [error localizedDescription]];
        }
        

        
        // Create the managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
                
        // The managed object context can manage undo, but we don't need it
        [context setUndoManager:nil];        
    }
    return self;
}

- (void)setTopSongsCacheDate:(NSDate *)topSongsCacheDate
{
    [[NSUserDefaults standardUserDefaults] setObject:topSongsCacheDate
                                              forKey:@"topSongsCacheDate"];
}

- (NSDate *)topSongsCacheDate
{
    return [[NSUserDefaults standardUserDefaults]
                        objectForKey:@"topSongsCacheDate"];
}

- (void)fetchTopSongs:(int)count withCompletion:(void (^)(RSSChannel *obj, NSError *err))block
{
    // Construct the cache path
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                               NSUserDomainMask,
                                                               YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:@"apple.archive"];

    // Make sure we have cached at least once before by checking to see
    // if this date exists!
    NSDate *tscDate = [self topSongsCacheDate];
    if(tscDate) {
        // How old is the cache?
        NSTimeInterval cacheAge = [tscDate timeIntervalSinceNow];
        if(cacheAge > -300.0) {
            // If it is less than 300 seconds (5 minutes) old, return cache
            // in completion block
            NSLog(@"Reading cache!");
            RSSChannel *cachedChannel = [NSKeyedUnarchiver
                                            unarchiveObjectWithFile:cachePath];
            if(cachedChannel) {
                // Execute the controller's completion block to reload its table
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    block(cachedChannel, nil);
                }];
                // Don't need to make the request, just get out of this method
                return; 
            }
        } 
    }

    // Prepare a request URL, including the argument from the controller
    NSString *requestString = [NSString stringWithFormat:
                                @"http://itunes.apple.com/us/rss/topsongs/limit=%d/json", count];
    NSURL *url = [NSURL URLWithString:requestString];
    
    // Set up the connection as normal
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    RSSChannel *channel = [[RSSChannel alloc] init];
    
    BNRConnection *connection = [[BNRConnection alloc] initWithRequest:req];

    [connection setCompletionBlock:^(RSSChannel *obj, NSError *err) {
        // This is the store's completion code:
        // If everything went smoothly, save the channel to disk and mark cache date
        if(!err) {
            [self setTopSongsCacheDate:[NSDate date]];
            [NSKeyedArchiver archiveRootObject:obj toFile:cachePath];
        }
        
        // This is the controller's completion code:
        block(obj, err);
    }];
    [connection setJsonRootObject:channel];
    
    [connection start];
}

- (RSSChannel *)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *obj, NSError *err))block
{
    NSURL *url = [NSURL URLWithString:@"http://forums.bignerdranch.com/"
                  @"smartfeed.php?limit=1_DAY&sort_by=standard"
                  @"&feed_type=RSS2.0&feed_style=COMPACT"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];

    // Create an empty channel
    RSSChannel *channel = [[RSSChannel alloc] init];
    
    // Create a connection "actor" object that will transfer data from the server
    BNRConnection *connection = [[BNRConnection alloc] initWithRequest:req];
    
    // When the connection completes, this block from the controller will be executed.
    NSString *cachePath = 
        [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, 
                                             NSUserDomainMask, 
                                             YES) objectAtIndex:0];
                                             
    cachePath = [cachePath stringByAppendingPathComponent:@"nerd.archive"];

    // Load the cached channel, or create an empty one to fill up
    RSSChannel *cachedChannel = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    if(!cachedChannel)
        cachedChannel = [[RSSChannel alloc] init];

    RSSChannel *channelCopy = [cachedChannel copy];
    
    // When the connection completes, this block from the controller will be executed.
    [connection setCompletionBlock:^(RSSChannel *obj, NSError *err) {
        if(!err) {
            [channelCopy addItemsFromChannel:obj];
            [NSKeyedArchiver archiveRootObject:channelCopy toFile:cachePath];
        }

        block(channelCopy, err);
    }];
    
    // Let the empty channel parse the returning data from the web service
    [connection setXmlRootObject:channel];
    
    // Begin the connection
    [connection start];
    
    return cachedChannel;
}
@end
