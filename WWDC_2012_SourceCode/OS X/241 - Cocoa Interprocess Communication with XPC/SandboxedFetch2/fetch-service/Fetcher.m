
/*
     File: Fetcher.m
 Abstract: 
 
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

#import "Fetcher.h"

@implementation Fetcher

- (void)fetchURL:(NSURL *)url withReply:(void (^)(NSFileHandle *, NSError *))reply {
    if (![[url scheme] isEqualToString:@"http"]) {
        reply(nil, [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{NSLocalizedDescriptionKey : @"Invalid URL"}]);
        return;
    }
    
    // We'll call back this reply block later. If this were a manual retain/release application, it is required to use 'copy' on this block to make sure it sticks around long enough for us to call it. This is compiled with ARC though, so the compiler will take care of it for us when we do this assignment.
    replyBlock = reply;
    
    // This object will hold the downloaded data.
    receivedData = [NSMutableData new];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSOperationQueue *queue = [NSOperationQueue new];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    // By assigning a delegate queue here, NSURLConnection will use dispatch queues instead of relying on a CFRunLoop being present in the current thread. Since this code is executing in a serial queue provided by NSXPCConnection, this is required.
    [urlConnection setDelegateQueue:queue];
    [urlConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0];
    expectedSize = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    
    // Send progress update to other side. The NSXPCListenerDelegate configured the connection to implement the 'FetchProgress' protocol, so we'll send the progress update message through the connection's remoteObjectProxy.
    double progress = ([receivedData length] / (double)expectedSize) * 100.0;
    [[self.xpcConnection remoteObjectProxy] setProgress:progress];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Call back the other side's reply block with the error.
    receivedData = nil;
    replyBlock(nil, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Open a temporary file in the temp directory of the container.
    char *tempname;
    if (asprintf(&tempname, "%sfetch.XXXXXXXX", [NSTemporaryDirectory() fileSystemRepresentation]) < 0) {
        replyBlock(nil, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSLocalizedDescriptionKey : @"Couldn't get temporary file name"}]);
        return;
    }
    
    int tempFileFD = -1;
    if ((tempFileFD = mkstemp(tempname)) < 0) {
        free(tempname);
        replyBlock(nil, [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSLocalizedDescriptionKey : @"Couldn't open temporary file"}]);
    }
    
    // Unlink the file so it is removed as soon as it is closed.
    (void)unlink(tempname);
    free(tempname);
    
    // Write the data to the file, and seek to the beginning. Hand ownership of the fd to NSFileHandle.
    NSFileHandle *outFile = [[NSFileHandle alloc] initWithFileDescriptor:tempFileFD closeOnDealloc:YES];
    [outFile writeData:receivedData];
    [outFile seekToFileOffset:0];
    
    // Clear out our received data, then send the file handle back to the main process.
    receivedData = nil;
    replyBlock(outFile, nil);
}

@end
