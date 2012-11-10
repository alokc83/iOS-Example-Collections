
/*
     File: Zipper.m
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

#import "Zipper.h"
#include <zlib.h>

@implementation Zipper

#define ZIP_BUF_SIZE	16384

// Given an input and output file, compress the input into the output using
// the gzip algorithm (using given compression level and strategy).
//
// Return Z_OK on success.  Otherwise return a zlib error.
static int
zip_compress_file(int infd, int outfd, int level, int strategy, 
                  const char **errmsg)
{
    int err = Z_OK;
    int len;
    uint8_t *buf = NULL;
    gzFile gzoutfp = NULL;
    char mode[5] = "wb  ";
    
    // Build mode argument for gzdopen().
    if (level < 1 || level > 9)
	    level = 6;
    mode[2] = '0' + level;
    switch (strategy) {
        case Z_FILTERED:
            mode[3] = 'f';
            break;
        case Z_HUFFMAN_ONLY:
            mode[3] = 'h';
            break;
        case Z_RLE:
            mode[3] = 'R';
            break;
        case Z_FIXED:
            mode[3] = 'F';
            break;
        default:
            mode[3] = '\0';
            break;
    }
    
    if ((buf = (uint8_t *)malloc(ZIP_BUF_SIZE)) == NULL) {
        err = Z_MEM_ERROR;
        if (errmsg)
            *errmsg = "Out of memory";
        goto errout;
    }
    // Use zlib gzip wrapper functions to do the compression.
    if ((gzoutfp = gzdopen(outfd, mode)) == NULL) {
	    err = Z_ERRNO;
	    if (errmsg)
		    *errmsg = "Can't not gzdopen() output file";
	    goto errout;
    }
    
    while(1) {
	    if ((len = (int)read(infd, buf, ZIP_BUF_SIZE)) < 0) {
		    err = Z_ERRNO;
            if (errmsg)
                *errmsg = "Can't read input";
		    goto errout;
	    }
        
	    if (0 == len)
		    break;
        
	    if (gzwrite(gzoutfp, buf, len) != len) {
		    if (errmsg)
		    	*errmsg = gzerror(gzoutfp, &err);
		    goto errout;
	    }
    }
    
errout:
    if (buf)
	    free(buf);
    if (gzoutfp)
	    gzclose(gzoutfp);
    return (err);
}

+ (Zipper *)sharedZipper {
    static dispatch_once_t onceToken;
    static Zipper *shared;
    dispatch_once(&onceToken, ^{
        shared = [Zipper new];
    });
    return shared;
}

// This method will handle compressing a file. Note that NSFileHandle works together with NSXPCConnection, to allow an open file to be automatically passed from one application to another. The zip service itself does not have permissions to access arbitary files. It will be allowed to talk only to the file that it is given from the main GUI application.
- (void)compressFile:(NSFileHandle *)inFile toFile:(NSFileHandle *)outFile withReply:(void (^)(NSError *error))reply {
    int64_t errcode = 0;
    const char *errmsg = NULL;
    int infd = [inFile fileDescriptor];
    int outfd = [outFile fileDescriptor];
    if (infd == -1 || outfd == -1) {
        errcode = Z_ERRNO;
        errmsg = "Invalid file descriptor(s)";
    } else {
        errcode = zip_compress_file(infd, outfd, 6, 0, &errmsg);
    }
    
    // Create an error object to pass back, if appropriate.
    NSError *error = nil;
    if (errcode) {
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errcode userInfo:nil];
    }
    
    // Invoke the reply block, which will send a response back to the main application to let it know that we are finished.
    reply(error);
}

// Implement the one method in the NSXPCListenerDelegate protocol.
- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // Configure the new connection and resume it. Because this is a singleton object, we set 'self' as the exported object and configure the connection to export the 'Zip' protocol that we implement on this object.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(Zip)];
    newConnection.exportedObject = self;
    [newConnection resume];
    
    return YES;
}

@end
