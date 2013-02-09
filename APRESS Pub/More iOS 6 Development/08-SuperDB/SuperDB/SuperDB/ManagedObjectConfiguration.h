//
//  HeroDetailConfiguration.h
//  SuperDB
//
//  Created by Kevin Y. Kim on 1/23/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManagedObjectConfiguration : NSObject

- (id)initWithResource:(NSString *)resource;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)headerInSection:(NSInteger)section;
- (NSDictionary *)rowForIndexPath:(NSIndexPath *)indexPath;

- (NSString *)cellClassnameForIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)valuesForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)attributeKeyForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)labelForIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isDynamicSection:(NSInteger)section;
- (NSString *)dynamicAttributeKeyForSection:(NSInteger)section;

@end
