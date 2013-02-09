//
//  AppDelegate.m
//  SuperDB
//
//  Created by Kevin Y. Kim on 1/22/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFromUbiquitousContent:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SuperDB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    __block NSPersistentStoreCoordinator *psc = _persistentStoreCoordinator;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPersistentStore *newStore = nil;
        NSError *error = nil;
        
        NSString *dataFile = @"SuperDB.sqlite";
        NSString *dataDir = @"Data.nosync";
        NSString *logsDir = @"Logs";
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        id ubiquityToken = [fileManager ubiquityIdentityToken];
        NSURL *ubiquityURL = [fileManager URLForUbiquityContainerIdentifier:nil];
        if (ubiquityToken && ubiquityURL) {
            NSString *dataDirPath = [[ubiquityURL path] stringByAppendingPathComponent:dataDir];
            if([fileManager fileExistsAtPath:dataDirPath] == NO) {
                NSError *fileSystemError;
                [fileManager createDirectoryAtPath:dataDirPath withIntermediateDirectories:YES attributes:nil error:&fileSystemError];
                if(fileSystemError != nil) {
                    NSLog(@"Error creating database directory %@", fileSystemError);
                }
            }
            
            NSURL *logsURL = [NSURL fileURLWithPath:[[ubiquityURL path] stringByAppendingPathComponent:logsDir]];
            NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                                             NSInferMappingModelAutomaticallyOption : @YES,
                                          NSPersistentStoreUbiquitousContentNameKey : [ubiquityURL lastPathComponent],
                                           NSPersistentStoreUbiquitousContentURLKey : logsURL };
            [psc lock];
            NSURL *dataFileURL = [NSURL fileURLWithPath:[dataDirPath stringByAppendingPathComponent:dataFile]];
            newStore = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dataFileURL options:options error:&error];
                        [psc unlock];
        }
        else {
            NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFile];
            NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                                             NSInferMappingModelAutomaticallyOption : @YES };
            [psc lock];
            newStore = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
            [psc unlock];
        }
        
        if (!newStore) {
            /*
             Replace this implementation with code to handle the error appropriately.
             abort() causes the application to generate a crash log and terminate.
             You should not use this function in a shipping application,
             although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DataChanged" object:self userInfo:nil];
        });
    });

    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Handle Changes from iCloud to Ubiquitous Container
- (void)mergeChangesFromUbiquitousContent:(NSNotification *)notification
{
    NSManagedObjectContext* moc = [self managedObjectContext];
    [moc performBlock:^{
        [moc mergeChangesFromContextDidSaveNotification:notification];
        NSNotification* refreshNotification = [NSNotification notificationWithName:@"DataChanged" object:self userInfo:[notification userInfo]];
        [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    }];
}

@end
