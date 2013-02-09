//
//  KeychainItem.h
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/4/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainItem : NSObject

@property (strong, nonatomic) id item;
@property (strong, nonatomic) id type;
@property (strong, nonatomic) NSDictionary *attributes;
@property (strong, nonatomic) id persistentRef;

- (id)initWithItem:(CFTypeRef)item;
- (id)initWithData:(NSData *)data options:(NSDictionary *)options;
- (BOOL)save:(NSError **)error;
- (id)valueForAttribute:(CFTypeRef)attr;

@end
