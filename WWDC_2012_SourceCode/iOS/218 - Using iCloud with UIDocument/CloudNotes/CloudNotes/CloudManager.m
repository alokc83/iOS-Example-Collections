

/*
 
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

#import "CloudManager.h"

NSString* const ICloudStateUpdatedNotification = @"ICloudStateUpdatedNotification";
NSString* const UbiquitousContainerFetchingWillBeginNotification = @"UbiquitousContainerFetchingWillBeginNotification";
NSString* const UbiquitousContainerFetchingDidEndNotification = @"UbiquitousContainerFetchingDidEndNotification";

static CloudManager* __sharedManager;

@implementation CloudManager
{
    BOOL _isCloudEnabled;
    NSURL* _dataDirectoryURL;
}

@synthesize isCloudEnabled = _isCloudEnabled;
@synthesize dataDirectoryURL = _dataDirectoryURL;

+ (CloudManager*)sharedManager
{
    if (!__sharedManager) {
        __sharedManager = [[CloudManager alloc] init];
    }
    
    return __sharedManager;
}

- (id)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateICloudEnabled:) name:NSUbiquityIdentityDidChangeNotification object:nil];
        [self updateFileStorageContainerURL:nil];
    }
    
    return self;
}

- (void)setIsCloudEnabled:(BOOL)isCloudEnabled
{
    // Asynchronously update our data directory URL and documents directory URL
    // If we're enabling cloud storage, we move any local documents into the cloud container after the URLs are updated.
    
    if (isCloudEnabled != _isCloudEnabled) {
        _isCloudEnabled = isCloudEnabled;
        NSURL* oldDataDirectoryURL = [self dataDirectoryURL];
        NSURL* oldDocumentsDirectoryURL = [self documentsDirectoryURL];
        [self updateFileStorageContainerURL:^(void) {
            if (isCloudEnabled) {
                // Now move any existing local documents into iCloud.
                
                NSArray* localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:oldDocumentsDirectoryURL includingPropertiesForKeys:nil options:0 error:nil];
                NSArray* localPreviews = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:oldDataDirectoryURL includingPropertiesForKeys:nil options:0 error:nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    NSFileManager* fileManager = [[NSFileManager alloc] init];
                    NSURL* newDataDirectoryURL = [self dataDirectoryURL];
                    NSURL* newDocumentsDirectoryURL = [self documentsDirectoryURL];
                    
                    for (NSURL* documentURL in localDocuments) {
                        if ([[documentURL pathExtension] isEqualToString:@"note"]) {
                            NSURL* destinationURL = [newDocumentsDirectoryURL URLByAppendingPathComponent:[documentURL lastPathComponent]];
                            [fileManager setUbiquitous:YES itemAtURL:documentURL destinationURL:destinationURL error:nil];
                        }
                    }
                    
                    for (NSURL* previewURL in localPreviews) {
                        if ([[previewURL pathExtension] isEqualToString:@"preview"]) {
                            NSURL* destinationURL = [newDataDirectoryURL URLByAppendingPathComponent:[previewURL lastPathComponent]];
                            [fileManager setUbiquitous:YES itemAtURL:previewURL destinationURL:destinationURL error:nil];
                        }
                    }
                });
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:ICloudStateUpdatedNotification object:nil];
    }
}

- (NSURL*)documentsDirectoryURL
{
    return [_dataDirectoryURL URLByAppendingPathComponent:@"Documents"];
}

- (void)updateFileStorageContainerURL:(void (^)(void))completionHandler
{
    // Perform the asynchronous update of the data directory and document directory URLs
    
    @synchronized (self) {
        _dataDirectoryURL = nil;
        if (self.isCloudEnabled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UbiquitousContainerFetchingWillBeginNotification object:nil];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                _dataDirectoryURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:@"com.apple.CloudNotes"];
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:UbiquitousContainerFetchingDidEndNotification object:nil];
                    
                    if (completionHandler) {
                        completionHandler();
                    }
                });
            });
        }
        else {
            _dataDirectoryURL = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
        }
    }
}

- (void)updateICloudEnabled:(NSNotification*)notification
{
    // Broadcast our own notification for iCloud state changes that other parts of our application can use and know the CloudManager has updated itself for the new state when they receive the notication.
    
    if ([[NSFileManager defaultManager] ubiquityIdentityToken]) {
        if (self.isCloudEnabled) {
            // If we're using iCloud already and we moved to a new token, broadcast a state change for that
            [[NSNotificationCenter defaultCenter] postNotificationName:ICloudStateUpdatedNotification object:nil];
        }
    }
    else {
        // If there is no tken now, set our state to NO, which will broadcast a state change if we were using iCloud
        self.isCloudEnabled = NO;
    }
}

@end
