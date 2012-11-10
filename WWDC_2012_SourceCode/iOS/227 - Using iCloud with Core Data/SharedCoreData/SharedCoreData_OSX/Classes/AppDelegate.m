
/*
     File: AppDelegate.m
 Abstract: Simple app delegate.
 
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

#import "AppDelegate.h"
#import "CoreDataController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSButton *removeButton;
@property (strong) IBOutlet NSArrayController *tableArrayController;


@end


@implementation AppDelegate
{
    BOOL iCloudEnabled;
    CoreDataController *_coreDataController;
}

@synthesize coreDataController = _coreDataController;

#pragma mark - iCloud availability

- (void)checkForiCloud
{
    // obtaining the URL for our ubiquity container could potentially take a long time,
    // so dispatch this call so to not block the main thread
    //
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSURL *ubiquityURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        if (ubiquityURL == nil)
        {
            // display the alert from the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *informativeText = @"Open iCloud System Preferences, and make sure you are logged in.";
                
                [[NSAlert alertWithMessageText:@"iCloud is not configured"
                                 defaultButton:@"OK"
                               alternateButton:nil
                                   otherButton:nil
                     informativeTextWithFormat:informativeText,
                  nil]
                 runModal];
            });
        }
        else
        {
            // user is logged into iCloud
            if (_coreDataController.mainThreadContext)
            {
                //NSLog(@"items = %@", [tableArrayController arrangedObjects]);
            }
        }
    });
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [_coreDataController applicationResumed];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    // listen for editing changes to we can issue a save on our managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidEndEditing:)
                                                 name:NSTextDidEndEditingNotification
                                               object:nil];

    _coreDataController = [[CoreDataController alloc] init];
    [_coreDataController loadPersistentStores];
    
    // start by sorting by last name
    [self.tableArrayController setSortDescriptors:
        [NSArray arrayWithObjects:
            [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES],
            nil]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

// Implementation of the applicationShouldTerminate: method, used here to handle the saving
// of changes in the application managed object context before the application terminates.
//
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    __block int reply = NSTerminateNow;
 
    NSManagedObjectContext *moc = _coreDataController.mainThreadContext;
    [moc performBlockAndWait:^{
        NSError *error;
        if ([moc commitEditing]) {
            if ([moc hasChanges]) {
                if ([moc save:&error]) {
                    BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
                    
                    if (errorResult == YES) {
                        reply = NSTerminateCancel;
                    }  else {
                        int alertReturn = NSRunAlertPanel(nil,
                                                          @"Could not save changes while quitting. Quit anyway?", 
                                                          @"Quit",
                                                          @"Cancel",
                                                          nil);
                        if (alertReturn == NSAlertAlternateReturn) {
                            reply = NSTerminateCancel;	
                        }
                    }
                }
            }
        }
    }];
 
    return reply;
}


#pragma mark - NSTableView notifications

- (void)textDidEndEditing:(NSNotification *)notification
{
    NSError *error = nil;
    NSManagedObjectContext *moc = _coreDataController.mainThreadContext;
    if (![moc save:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    // only allow editing if we have a valid managedObjectContext,
    // the user could be logged out of iCloud so we don't allow editing in this case
    //
    return (_coreDataController.mainThreadContext != nil);
}
@end
