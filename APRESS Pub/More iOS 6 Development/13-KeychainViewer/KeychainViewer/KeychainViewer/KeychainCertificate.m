//
//  KeychainCertificate.m
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "KeychainCertificate.h"

@implementation KeychainCertificate

+ (NSArray *)allKeychainCertificates
{
    NSMutableArray *certs = [NSMutableArray array];
    NSDictionary *query = @{
        (__bridge id)kSecClass               : (__bridge id)kSecClassCertificate,
        (__bridge id)kSecReturnRef           : (id)kCFBooleanTrue,
        (__bridge id)kSecReturnAttributes    : (id)kCFBooleanTrue,
        (__bridge id)kSecReturnPersistentRef : (id)kCFBooleanTrue,
        (__bridge id)kSecMatchLimit          : (__bridge id)kSecMatchLimitAll
    };
    CFTypeRef results = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &results);
    if (status == errSecSuccess && results != NULL) {
        for (NSDictionary *result in (__bridge NSArray *)results) {
            id itemRef = [result valueForKey:(__bridge id)kSecValueRef];
            id persistentRef = [result valueForKey:(__bridge id)kSecValuePersistentRef];
            NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:result];
            [attrs removeObjectForKey:(__bridge id)kSecValueRef];
            [attrs removeObjectForKey:(__bridge id)kSecValuePersistentRef];
            
            KeychainCertificate *cert = [[KeychainCertificate alloc] initWithItem:(__bridge CFTypeRef)itemRef];
            cert.persistentRef = persistentRef;
            cert.attributes = attrs;
            [certs addObject:cert];
        }
    }
    return certs;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.type = [(__bridge id)kSecClassCertificate copy];
    }
    return self;
}

- (id)initWithData:(NSData *)data options:(NSDictionary *)options
{
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)data);
    if (cert) {
        self = [self initWithItem:cert];
    }
    return self;
}

- (NSString *)subjectSummary
{
    CFStringRef result = SecCertificateCopySubjectSummary((__bridge SecCertificateRef)(self.item));
    return CFBridgingRelease(result);
}

@end
