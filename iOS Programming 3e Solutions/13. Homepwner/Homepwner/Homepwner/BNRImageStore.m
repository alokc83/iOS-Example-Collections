//
//  BNRImageStore.m
//  Homepwner
//
//  Created by joeconway on 9/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BNRImageStore.h"

@implementation BNRImageStore
+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultImageStore];
}

+ (BNRImageStore *)defaultImageStore
{
    static BNRImageStore *defaultImageStore = nil;
    if (!defaultImageStore) {
        // Create the singleton
        defaultImageStore = [[super allocWithZone:NULL] init];
    }
    return defaultImageStore;
}

- (id)init {
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [dictionary setObject:i forKey:s];
}
- (UIImage *)imageForKey:(NSString *)s
{
    return [dictionary objectForKey:s];
}
- (void)deleteImageForKey:(NSString *)s
{
    if(!s)
        return;
    [dictionary removeObjectForKey:s];
}

@end
