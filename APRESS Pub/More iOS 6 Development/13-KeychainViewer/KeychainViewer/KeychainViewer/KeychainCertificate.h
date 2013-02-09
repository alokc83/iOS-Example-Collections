//
//  KeychainCertificate.h
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "KeychainItem.h"

@interface KeychainCertificate : KeychainItem

@property (strong, nonatomic, readonly) NSString *subjectSummary;

+ (NSArray *)allKeychainCertificates;

@end
