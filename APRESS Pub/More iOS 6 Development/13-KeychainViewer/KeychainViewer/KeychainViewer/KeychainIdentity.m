//
//  KeychainIdentity.m
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "KeychainIdentity.h"
#import "AppDelegate.h"

@interface KeychainIdentity ()
@property (assign, nonatomic, readonly, getter=isTrusted) BOOL trusted;
@property (assign, nonatomic, readonly) SecTrustRef trust;
@property (assign, nonatomic, readonly) SecCertificateRef anchorCertificate;
@property (assign, nonatomic, readonly) SecCertificateRef certificate;
- (BOOL)recoverTrust;
@end
//@property (assign, nonatomic, readonly) SecKeyRef publicKey;
//@property (assign, nonatomic, readonly) SecKeyRef privateKey;

@implementation KeychainIdentity

@synthesize trusted = _trusted;
@synthesize trust = _trust;
@synthesize anchorCertificate = _anchorCertificate;
@synthesize certificate = _certificate;
//@synthesize publicKey = _publicKey;
//@synthesize privateKey = _privateKey;

+ (NSArray *)allKeychainIdentities
{
    NSMutableArray *idents = [NSMutableArray array];
    NSDictionary *query = @{
        (__bridge id)kSecClass               : (__bridge id)kSecClassIdentity,
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
            
            KeychainIdentity *ident = [[KeychainIdentity alloc] initWithItem:(__bridge CFTypeRef)itemRef];
            ident.persistentRef = persistentRef;
            ident.attributes = attrs;
            [idents addObject:ident];
        }
    }
    return idents;
}

- (void)dealloc
{
//    if (_publicKey)
//        CFRelease(_publicKey);
//    
    if (_trust)
        CFRelease(_trust);
    
    if (_certificate)
        CFRelease(_certificate);
    
    if (_anchorCertificate)
        CFRelease(_anchorCertificate);
}

- (id)init
{
    self = [super init];
    if (self) {
        self.type = [(__bridge id)kSecClassIdentity copy];
//        _certificate = NULL;
        _trusted = NO;
        _trust = NULL;
    }
    return self;
}

- (id)initWithData:(NSData *)data options:(NSDictionary *)options
{
    CFDataRef inPKCS12Data = (__bridge CFDataRef)data;
//    NSDictionary *optionsDictionary = @{ (__bridge id)kSecImportExportPassphrase : password };
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus status = SecPKCS12Import(inPKCS12Data, (__bridge CFDictionaryRef)options, &items);
    if (status != errSecSuccess) {
        NSLog(@"Error Reading P12 file");
        abort();
    }
    
    CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
    SecIdentityRef identity = (SecIdentityRef)CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
    if (identity)
        self = [self initWithItem:identity];
    
    return self;
}

- (NSData *)encrypt:(NSData *)data
{
    if (!self.isTrusted)
        return nil;
    
    SecKeyRef publicKey = SecTrustCopyPublicKey(self.trust);
    size_t keyBlockSize = SecKeyGetBlockSize(publicKey);
    size_t bufferSize = keyBlockSize*sizeof(uint8_t);
    
    uint8_t *srcBuffer = malloc(bufferSize);
    size_t srcBufferLen = keyBlockSize - 11;
    
    uint8_t *buffer = malloc(bufferSize);
    size_t bufferLen = keyBlockSize;
    
    NSMutableData *result = [[NSMutableData alloc] init];
    
    NSRange range = NSMakeRange(0, keyBlockSize);
    while (range.location < data.length) {
        memset(srcBuffer, 0x0, bufferSize);
        memset(buffer, 0x0, bufferSize);
        
        if (NSMaxRange(range) > data.length)
            range.length = data.length - range.location;
        
        [data getBytes:srcBuffer range:range];
        OSStatus status = SecKeyEncrypt(publicKey, kSecPaddingPKCS1, srcBuffer, srcBufferLen, buffer, &bufferLen);
        if (status != errSecSuccess) {
            NSLog(@"Error Encrypting Data");
            free(buffer);
            free(srcBuffer);
            free(publicKey);
            return nil;
        }
        [result appendBytes:buffer length:bufferLen];
        range.location += srcBufferLen;
    }
    
    free(buffer);
    free(srcBuffer);
    free(publicKey);
    
    return result;
}

- (NSData *)decrypt:(NSData *)data
{
    if (!self.isTrusted)
        return nil;
    
    SecKeyRef privateKey;
    OSStatus status =  SecIdentityCopyPrivateKey((__bridge SecIdentityRef)self.item, &privateKey);
    if (status != errSecSuccess && privateKey != NULL) {
        CFRelease(privateKey);
        privateKey = NULL;
        return nil;
    }

    size_t keyBlockSize = SecKeyGetBlockSize(privateKey);
    size_t bufferSize = keyBlockSize*sizeof(uint8_t);
    
    uint8_t *srcBuffer = malloc(bufferSize);
    
    uint8_t *buffer = malloc(bufferSize);
    size_t bufferLen = keyBlockSize;
    
    NSMutableData *result = [[NSMutableData alloc] init];
    
    NSRange range = NSMakeRange(0, keyBlockSize);
    while (range.location < data.length) {
        memset(srcBuffer, 0x0, bufferSize);
        memset(buffer, 0x0, bufferSize);
        
        if (NSMaxRange(range) > data.length)
            range.length = data.length - range.location;
        
        [data getBytes:srcBuffer range:range];
        OSStatus status = SecKeyDecrypt(privateKey, kSecPaddingPKCS1, srcBuffer, keyBlockSize, buffer, &bufferLen);
        if (status != errSecSuccess) {
            NSLog(@"Error Decrypting Data");
            free(buffer);
            free(srcBuffer);
            free(privateKey);
            return nil;
        }
        [result appendBytes:buffer length:bufferLen];
        range.location += keyBlockSize;
    }
    
    free(buffer);
    free(srcBuffer);
    free(privateKey);
    
    return result;
}

- (SecCertificateRef)anchorCertificate
{
    if (_anchorCertificate == NULL) {
        id persistentRef = [[NSUserDefaults standardUserDefaults] objectForKey:@"anchor_certificate"];
        NSDictionary *query = @{
        (__bridge id)kSecClass               : (__bridge id)kSecClassCertificate,
        (__bridge id)kSecValuePersistentRef  : persistentRef,
        (__bridge id)kSecReturnRef           : (id)kCFBooleanTrue,
        (__bridge id)kSecMatchLimit          : (__bridge id)kSecMatchLimitOne
        };
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&_anchorCertificate);
        if (status != errSecSuccess || _anchorCertificate == NULL) {
            NSLog(@"Error loading Anchor Certificate");
            abort();
        }
    }
    return _anchorCertificate;
}

- (SecCertificateRef)certificate
{
    if (_certificate == NULL) {
        OSStatus status = SecIdentityCopyCertificate((__bridge SecIdentityRef)self.item, &_certificate);
        if (status != errSecSuccess) {
            NSLog(@"Error retrieving Identity Certificate");
            return NULL;
        }
    }
    return _certificate;
}

- (SecTrustRef)trust
{
    if (_trust == NULL) {
        SecPolicyRef policy = SecPolicyCreateBasicX509();
        NSArray *certs = @[ (__bridge id)self.certificate, (__bridge id)self.anchorCertificate ];
        OSStatus status = SecTrustCreateWithCertificates((__bridge CFTypeRef)certs, policy, &_trust);
        if (status != errSecSuccess) {
            NSLog(@"Error Creating Trust from Certificate");
            return NULL;
        }
    }
    return _trust;
}

- (BOOL)isTrusted
{
    if (_trust == NULL) {
        SecTrustResultType trustResult;
        OSStatus status = SecTrustEvaluate(self.trust, &trustResult);
        if (status == errSecSuccess) {
            switch (trustResult) {
                case kSecTrustResultInvalid:
                case kSecTrustResultDeny:
                case kSecTrustResultFatalTrustFailure:
                case kSecTrustResultOtherError:
                    _trusted = NO;
                    break;
                case kSecTrustResultProceed:
                case kSecTrustResultConfirm:
                case kSecTrustResultUnspecified:
                    _trusted = YES;
                    break;
                case kSecTrustResultRecoverableTrustFailure:
                    _trusted = [self recoverTrust];
                    break;
            }
        }
        else
            _trusted = NO;
    }
    return _trusted;
}

- (BOOL)recoverTrust
{
    NSArray *anchorCerts = @[ (__bridge id)self.anchorCertificate ];
    SecTrustSetAnchorCertificates(self.trust, (__bridge CFArrayRef)anchorCerts);
    SecTrustSetAnchorCertificatesOnly(self.trust, NO);
    SecTrustResultType trustResult;
    OSStatus status = SecTrustEvaluate(self.trust, &trustResult);
    if (status == errSecSuccess) {
        switch (trustResult) {
            case kSecTrustResultInvalid:
            case kSecTrustResultDeny:
            case kSecTrustResultFatalTrustFailure:
            case kSecTrustResultOtherError:
            case kSecTrustResultRecoverableTrustFailure:
                return NO;
                break;
            case kSecTrustResultProceed:
            case kSecTrustResultConfirm:
            case kSecTrustResultUnspecified:
                return YES;
                break;
        }
    }
    return NO;
}


//- (SecKeyRef)publicKey
//{
//    if (!self.isTrusted)
//        return nil;
//    
//    if (_publicKey == NULL) {
//        _publicKey = SecTrustCopyPublicKey(self.trust);
//    }
//    return _publicKey;
//}

//- (SecKeyRef)privateKey
//{
//    if (!self.isTrusted)
//        return nil;
//    
//    if (_privateKey == NULL) {
//        OSStatus status =  SecIdentityCopyPrivateKey((__bridge SecIdentityRef)self.item, &_privateKey);
//        if (status != errSecSuccess && _privateKey != NULL) {
//            CFRelease(_privateKey);
//            _privateKey = NULL;
//        }
//    }
//    return _privateKey;
//}

#pragma mark - (Private) Property Overrides



@end
