//
//  AppPlayList.h
//  PlayMyLists
//
//  Created by Bear Cahill on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AppPlayList : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *tracks;
@end

@interface AppPlayList (CoreDataGeneratedAccessors)

- (void)addTracksObject:(NSManagedObject *)value;
- (void)removeTracksObject:(NSManagedObject *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;
@end
