/*
     File: PassSigner.m
 Abstract: signpass
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "PassSigner.h"
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>

#define PASS_IDENTITY_PREFIX @"Pass Type ID: "

@interface NSData(SHA1Hashing)
- (NSString *)SHA1HashString;
@end

@implementation NSData(SHA1Hashing)

// Returns the SHA1 hash of a data as a string
- (NSString *)SHA1HashString {
    
    // Generate the hash.
    unsigned char sha1[CC_SHA1_DIGEST_LENGTH];
    if(!CC_SHA1([self bytes], (CC_LONG)[self length], sha1)) {
        return nil;
    }
    
    // Append the bytes in the correct format.
    NSMutableString * hashedResult = [[NSMutableString alloc] init];
    for (unsigned i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [hashedResult appendFormat:@"%02x", sha1[i]];    
    }
    return [hashedResult autorelease];
}

@end

@implementation PassSigner

+ (SecIdentityRef)passSigningIdentityRef:(NSString*)passTypeIdentifier
{
    OSStatus status;
    
    NSDictionary* matchingDictionary = @{ (NSString*)kSecClass : (NSString*)kSecClassIdentity, (NSString*)kSecMatchSubjectEndsWith : passTypeIdentifier, (NSString*)kSecReturnRef: (NSNumber*)kCFBooleanTrue};
    CFTypeRef result;
    
    status = SecItemCopyMatching((CFDictionaryRef) matchingDictionary, &result);

    if (status == 0)
        return (SecIdentityRef)[(id)result autorelease];
    else
        return nil;
}

+ (NSString*)passTypeIdentifierForPassAtURL:(NSURL*)passURL
{
    NSError* error = nil;
    NSURL* passJSONURL = [passURL URLByAppendingPathComponent:@"pass.json"];
    NSData* passData = [NSData dataWithContentsOfURL:passJSONURL];
    NSDictionary* passDictionary = [NSJSONSerialization JSONObjectWithData:passData options:0 error:&error];
    
    NSString* passTypeIdentifier = [passDictionary objectForKey:@"passTypeIdentifier"];
    
    return passTypeIdentifier;
}

+ (void)signPassWithURL:(NSURL *)passURL certSuffix:(NSString*)certSuffix outputURL:(NSURL *)outputURL zip:(BOOL)zip {
        
    // Dictionary to store our manifest hashes
    NSMutableDictionary *manifestDictionary = [[NSMutableDictionary alloc] init];
    
    // Temporary files
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *temporaryDirectory = NSTemporaryDirectory();
    NSString *temporaryPath = [temporaryDirectory stringByAppendingPathComponent:[passURL lastPathComponent]];
    NSURL *tempURL = [NSURL fileURLWithPath:temporaryPath];
    
    NSError *error = nil;
    
    // Make sure we're starting fresh
    [defaultManager removeItemAtURL:tempURL error:&error];
    
    // Copy the pass to the temporary spot
    if (![defaultManager copyItemAtURL:passURL toURL:tempURL error:&error]) {
        NSLog(@"error: %@", [error localizedDescription]);
        exit(0);
    }
    
    // Build an enumerator to go through each file in the pass directory
    NSDirectoryEnumerator *enumerator = [defaultManager enumeratorAtURL:tempURL includingPropertiesForKeys:nil options:0 errorHandler:nil];
    
    // For each file in the pass directory...
    for (NSURL *theURL in enumerator) {
        NSNumber *isRegularFileNum = nil;
        NSError *error = nil;
        
        // Don't allow oddities like symbolic links
        if (![theURL getResourceValue:&isRegularFileNum forKey:NSURLIsRegularFileKey error:&error] || ![isRegularFileNum boolValue]) {
            if (error) {
                NSLog(@"error: %@", [error localizedDescription]);
            }
            continue;
        }
        
        // Build a hash of the data.
        NSData *fileData = [NSData dataWithContentsOfURL:theURL];
        NSString *sha1Hash = [fileData SHA1HashString];
        
        // Build a key, relative to the root of the directory
        NSArray *basePathComponents = [tempURL pathComponents];
        NSArray *urlPathComponents = [theURL pathComponents];
        
        NSRange range;
        range.location = ([basePathComponents count] + 1);
        range.length = [urlPathComponents count] - ([basePathComponents count] + 1);
        NSArray *relativePathComponents = [urlPathComponents subarrayWithRange:range];
        
        NSString *relativePath = [NSString pathWithComponents:relativePathComponents];
        
        if (relativePath) {
            // Store the computed hash and key
            [manifestDictionary setObject:sha1Hash forKey:relativePath];
        }
    }
    
    // Write out the manifest dictionary
    NSURL *manifestURL = [tempURL URLByAppendingPathComponent:@"manifest.json"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:manifestDictionary options:NSJSONWritingPrettyPrinted error:nil];
    [jsonData writeToURL:manifestURL atomically:YES];
    NSLog (@"%@", manifestDictionary);
    
    OSStatus status;
    if (certSuffix == nil) {
        certSuffix = [PassSigner passTypeIdentifierForPassAtURL:passURL];
    }
    
    if (certSuffix == nil) {
        NSLog(@"Couldn't find a passTypeIdentifier in the pass");
        return;
    }
    
    SecIdentityRef identity = [PassSigner passSigningIdentityRef:certSuffix];

    if (identity == nil) {
        NSLog(@"Couldn't find an identity for %@", certSuffix);
        return;
    }
    
    //Sign manifest
    NSData *signedData = nil;
    size_t len = [jsonData length];
    const void *bytes = [jsonData bytes];
    
    status = CMSEncodeContent(identity,
                              NULL,
                              0,
                              TRUE,
                              kCMSAttrSigningTime,
                              bytes, 
                              len, 
                              (CFDataRef *)&signedData);
    
    if (status != noErr) {
        NSString *secError = (NSString *)[NSMakeCollectable(SecCopyErrorMessageString(status, NULL)) autorelease];
        NSLog(@"Could not sign manifest data: %@", secError);
    } else {
        // Write signature to disk
        NSURL *signature = [tempURL URLByAppendingPathComponent:@"signature"];
        [signedData writeToURL:signature atomically:YES];
    }
    
    //Zip if necessary
    if (zip) {
        NSTask* zipTask;
        
        // Make a task to zip our contents
        zipTask = [[NSTask alloc] init];
        [zipTask setLaunchPath:@"/usr/bin/zip"];
        [zipTask setCurrentDirectoryPath:[tempURL path]];

        NSArray *argsArray = [NSArray arrayWithObjects:@"-r", @"-q", [outputURL path], @".", nil];
        [zipTask setArguments:argsArray];
        
        // Fire and wait. 
        [zipTask launch];
        [zipTask waitUntilExit];
        [zipTask release];
    }
}

@end
