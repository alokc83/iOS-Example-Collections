//
//  KeychainIdentity.h
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "KeychainItem.h"

@interface KeychainIdentity : KeychainItem

+ (NSArray *)allKeychainIdentities;
- (NSData *)encrypt:(NSData *)data;
- (NSData *)decrypt:(NSData *)data;

@end
