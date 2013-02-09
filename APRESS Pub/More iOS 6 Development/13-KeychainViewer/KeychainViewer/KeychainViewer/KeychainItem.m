//
//  KeychainItem.m
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/4/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "KeychainItem.h"

@implementation KeychainItem

- (id)initWithItem:(CFTypeRef)item
{
    self = [self init];
    if (self) {
        self.item = CFBridgingRelease(item);
    }
    return self;
}

- (id)initWithData:(NSData *)data options:(NSDictionary *)options
{
    return nil;
}

- (BOOL)save:(NSError **)error
{
    NSDictionary *attributes = @{
        (__bridge id)kSecValueRef : self.item,
        (__bridge id)kSecReturnPersistentRef : (id)kCFBooleanTrue
    };
    CFTypeRef cfPersistentRef;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, &cfPersistentRef);
    
    if (status != errSecSuccess) {
        NSDictionary *userInfo = nil;
        switch (status) {
            case errSecParam:
                userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"errorSecParam", @"One or more parameters passed to the function were not valid.") };
                break;
            case errSecAllocate:
                userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"errSecAllocate", @"Failed to allocate memory.") };
                break;
            case errSecDuplicateItem:
                userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"errSecDuplicateItem", @"The item already exists.") };
                break;
        }
        if (*error)
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:userInfo];
        return NO;
    }
    
    self.persistentRef = CFBridgingRelease(cfPersistentRef);
    return YES;
}

- (id)valueForAttribute:(CFTypeRef)attr
{
    return [self.attributes valueForKey:(__bridge id)attr];
}

@end
