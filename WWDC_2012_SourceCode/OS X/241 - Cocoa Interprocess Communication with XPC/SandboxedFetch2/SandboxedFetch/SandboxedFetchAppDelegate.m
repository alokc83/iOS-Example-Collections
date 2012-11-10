
/*
     File: SandboxedFetchAppDelegate.m
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

#import "SandboxedFetchAppDelegate.h"

#import <errno.h>
#import <fcntl.h>

#import "Zipper.h"
#import "Fetcher.h"

@implementation SandboxedFetchAppDelegate

#pragma mark Error Alert Sheet

- (void)showErrorAlert:(NSError *)error {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

#pragma mark Progress Panel Sheet

- (void)startProgressPanelWithMessage:(NSString *)message indeterminate:(BOOL)indeterminate {
    // Display a progress panel as a sheet
    self.progressMessage = message;
    if (indeterminate) {
        [self.progressIndicator setIndeterminate:YES];
    } else {
        [self.progressIndicator setIndeterminate:NO];
        [self.progressIndicator setDoubleValue:0.0];
    }
    [self.progressIndicator startAnimation:self];
    [self.progressCancelButton setEnabled:NO];
    [NSApp beginSheet:self.progressPanel
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:NULL];
}

- (void)stopProgressPanel {
    [self.progressPanel orderOut:self];
    [NSApp endSheet:self.progressPanel returnCode:0];
}

- (void)setProgress:(double)progress {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.progressIndicator setDoubleValue:progress];
    }];
}

- (IBAction)cancel:(id)sender {
    [self.progressPanel orderOut:self];
    [NSApp endSheet:self.progressPanel returnCode:1];
}


#pragma mark Save Panel Sheet
- (void)saveFile:(NSFileHandle *)fileHandle
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];

    NSString *fileName = [[NSURL URLWithString:[self.sourceURL stringValue]] lastPathComponent];
    if ([self.compressCheckbox state] == NSOffState) {
        [savePanel setNameFieldStringValue:fileName];
    } else {
        [savePanel setNameFieldStringValue:[fileName stringByAppendingPathExtension:@"gz"]];
    }
    
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [savePanel orderOut:self];

            NSError *error;
                                    
            if ([self.compressCheckbox state] == NSOffState) {
                [self startProgressPanelWithMessage:@"Copying..." indeterminate:YES];
                
                NSData *fetchedData = [fileHandle availableData];
                BOOL result = [fetchedData writeToURL:[savePanel URL] options:0 error:&error];
                if (!result) {
                    [self showErrorAlert:error];
                }
                
                [self stopProgressPanel];
                [fileHandle closeFile];
                
            } else {
                [self startProgressPanelWithMessage:@"Compressing..." indeterminate:YES];
                
                // Create the file, then create an NSFileHandle to transport it to our zip service.
                if (![[NSData data] writeToURL:[savePanel URL] options:0 error:&error]) {
                    [fileHandle closeFile];
                    [self showErrorAlert:error];
                    return;
                }

                // Create an NSFileHandle for transporting to our zip service. By opening it here, we are able to transfer the ability to write to this file to the service even though it does not have permission to open it on its own.
                NSFileHandle *outFile = [NSFileHandle fileHandleForWritingToURL:[savePanel URL] error:&error];
                if (!outFile) {
                    [fileHandle closeFile];
                    [self showErrorAlert:error];
                    return;
                }
                
                // Create a connection to the service and send it the message along with our file handles.
                NSXPCConnection *zipServiceConnection = [[NSXPCConnection alloc] initWithServiceName:@"com.apple.SandboxedFetch.zip-service"];
                zipServiceConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(Zip)];
                [zipServiceConnection resume];
                
                [[zipServiceConnection remoteObjectProxy] compressFile:fileHandle toFile:outFile withReply:^(NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self stopProgressPanel];
                        if (error) {
                            [self showErrorAlert:error];
                        }
                    }];
                    // At this point we have received a response and we no longer need to keep our connection. If we need another one, we'll just recreate it. We should invalidate the connection so it can finish any appropriate cleanup.
                    [zipServiceConnection invalidate];
                }];
            }
        }
        
        [fileHandle closeFile];
    }];
}

#pragma mark Actions

- (IBAction)fetch:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[self.sourceURL stringValue] forKey:@"LastFetchURL"];
    
    [self startProgressPanelWithMessage:@"Downloading..." indeterminate:NO];

    // Create a connection to our fetch-service and ask it to download for us.
    NSXPCConnection *fetchServiceConnection = [[NSXPCConnection alloc] initWithServiceName:@"com.apple.SandboxedFetch.fetch-service"];
    
    // The fetch-service will implement the 'Fetch' protocol.
    fetchServiceConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(Fetch)];
    
    // This object will implement the 'FetchProgress' protocol, so the Fetcher can report progress back and we can display it to the user.
    fetchServiceConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(FetchProgress)];
    fetchServiceConnection.exportedObject = self;
    
    [fetchServiceConnection resume];
        
    [[fetchServiceConnection remoteObjectProxy] fetchURL:[NSURL URLWithString:[self.sourceURL stringValue]] withReply:^(NSFileHandle *fileHandle, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self stopProgressPanel];
            
            if (error) {
                [self showErrorAlert:error];
            } else if ([fileHandle fileDescriptor] == -1) {
                [self showErrorAlert:[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil]];
            } else {
                [self saveFile:fileHandle];
            }
        }];
        // We're done with the connection at this point, so we should invalidate it.
        [fetchServiceConnection invalidate];
    }];
}

#pragma mark Delegate Methods

- (void)applicationWillFinishLaunching:(NSNotification*)aNotification {
    [self addObserver:self forKeyPath:@"sourceURL" options:NSKeyValueObservingOptionNew context: NULL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *lastFetchURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastFetchURL"];
    if (lastFetchURL) {
        [self.sourceURL setStringValue:lastFetchURL];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end
