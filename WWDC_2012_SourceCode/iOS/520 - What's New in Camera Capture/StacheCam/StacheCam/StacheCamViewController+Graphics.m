
/*
     File: StacheCamViewController+Graphics.m
 Abstract: Category for methods related to loading and displaying graphical overlays, and capturing still images to the assets library
  Version: 2.1
 
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


#import "StacheCamViewController+Graphics.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

const CGFloat SCALE_FUNNY_FACE = 0.9;

static inline NSNumber* boxInt(NSInteger x) { return [NSNumber numberWithInt:x]; }
static inline NSInteger unboxInt(NSNumber* x) { return [x integerValue]; }

static CGContextRef CreateCGBitmapContextForSize(CGSize size);
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);
static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
static UIImage* newHorizFlippedImage(UIImage* image);
static BOOL writeCGImageToCameraRoll(CGImageRef cgImage, NSDictionary *metadata);
static AVCaptureVideoOrientation avOrientationForDeviceOrientation(UIDeviceOrientation deviceOrientation);

@implementation StacheCamViewController (Graphics)

- (void) setupGraphics
{
	// we will check for graphics rendered for these yaw angles
	NSArray* yaws = @[ boxInt(0), boxInt(45), boxInt(90), boxInt(270), boxInt(315) ];
	
	NSMutableArray* images = [NSMutableArray new];
	for(size_t i=0; true; ++i ) {
		NSMutableDictionary* yawImages = [NSMutableDictionary dictionaryWithCapacity:yaws.count];
		// load what we find
		for ( NSNumber* yaw in yaws ) {
			UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"face%zuy%@.png",i,yaw]];
			if ( image )
				[yawImages setObject:image forKey:yaw];
		}
		// if we didn't find anything, we're done here
		if ( yawImages.count == 0 )
			break;
		// check each yaw angle, if one side is missing, fill it in by flipping the other side
		for ( NSNumber* yaw in yaws ) {
			UIImage* image = [yawImages objectForKey:yaw];
			NSNumber* symmetricKey = boxInt(360-unboxInt(yaw));
			if ( image && ! [yawImages objectForKey:symmetricKey] ) {
				[yawImages setObject:newHorizFlippedImage(image) forKey:symmetricKey];
			}
		}
		// add the dictionary for this face
		[images addObject:yawImages];
	}
	self.funnyFaces = images;

	self.stillImageOutput = [AVCaptureStillImageOutput new];
	if ( [self.session canAddOutput:self.stillImageOutput] ) {
		[self.session addOutput:self.stillImageOutput];
	} else {
		self.stillImageOutput = nil;
	}
	
}

- (void) teardownGraphics
{
	self.stillImageOutput = nil;
	self.funnyFaces = nil;
}

- (IBAction)takePicture:(id)sender
{
	// Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation = avOrientationForDeviceOrientation(curDeviceOrientation);
	[stillImageConnection setVideoOrientation:avcaptureOrientation];
	[stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
	[stillImageConnection setAutomaticallyAdjustsVideoMirroring:NO];
	[stillImageConnection setVideoMirrored:[self.previewLayer.connection isVideoMirrored]];
	
	BOOL doingFaceDetection = self.mustacheSwitch.on;
	if (doingFaceDetection)
		[self.stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
																		forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	else
		[self.stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
																		forKey:AVVideoCodecKey]]; 
	
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:
	 ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
		if (error) {
			displayErrorOnMainQueue(error, @"Take picture failed");
		} else if ( ! imageDataSampleBuffer ) {
			displayErrorOnMainQueue(nil, @"Take picture failed: received null sample buffer");
		} else {
			if ( ! doingFaceDetection ) {
				
				// Simple JPEG case, just save it
				NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
				NSDictionary* attachments = (__bridge_transfer NSDictionary*) CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
				writeJPEGDataToCameraRoll(jpegData, attachments);
				
			} else {
				
				// Draw the face graphics onto the image we captured
				CGImageRef cgImageResult = [self newFaceGraphics:imageDataSampleBuffer];
				
				if ( cgImageResult ) {
					// write it to the camera roll
					NSDictionary* attachments = (__bridge_transfer NSDictionary*)CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
					writeCGImageToCameraRoll(cgImageResult,attachments);
					CGImageRelease(cgImageResult);
				}
			}
		}
		
		// We used KVO in the main StacheCamViewController to freeze the preview when a still image was captured.
		// Now we are ready to take another image, unfreeze the preview
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self unfreezePreview];
		});
	}];
}

- (CGImageRef) newFaceGraphics:(CMSampleBufferRef) imageDataSampleBuffer
{
	CVImageBufferRef srcCVImageBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
	if ( ! srcCVImageBuffer ) {
		displayErrorOnMainQueue(nil, @"Take picture failed: still image sample buffer did not contain image buffer");
		return NULL;
	}
	
	CGImageRef srcImage = NULL;
	OSStatus err = CreateCGImageFromCVPixelBuffer(srcCVImageBuffer, &srcImage);
	if( err!=noErr || ! srcImage ) {
		displayErrorOnMainQueue(nil, [NSString stringWithFormat:@"Take picture failed: could not create CGImage (OSStatus %ld, img %p)",err,srcImage]);
		return NULL;
	}
	
	CGRect backgroundImageRect = CGRectMake(0., 0., CGImageGetWidth(srcImage), CGImageGetHeight(srcImage));
	CGContextRef bitmapContext = CreateCGBitmapContextForSize(backgroundImageRect.size);
	if ( ! bitmapContext ) {
		displayErrorOnMainQueue(nil, @"Take picture failed: could not create CGBitmapContext");
		CFRelease(srcImage);
		return NULL;
	}
	
	CGContextClearRect(bitmapContext, backgroundImageRect);
	CGContextDrawImage(bitmapContext, backgroundImageRect, srcImage);
	CFRelease(srcImage);
	
	@synchronized(self.lastMetadata) {
		if ( self.facesForMetadata.count != self.lastMetadata.count ) {
			displayErrorOnMainQueue(nil, [NSString stringWithFormat:@"Error: mismatch of metadata (%u) and face graphics (%u)",self.lastMetadata.count,self.facesForMetadata.count]);
			CGContextRelease (bitmapContext);
			return NULL;
		}
		
		for ( NSUInteger i=0; i<self.lastMetadata.count; ++i ) {
			id graphic = [self.facesForMetadata objectAtIndex:i];
			if ( graphic == [NSNull null] ) {
				NSLog(@"Error: null image for face %u of %u",i,self.lastMetadata.count);
				continue;
			}
			CGImageRef img = (__bridge CGImageRef)graphic;
			
			AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
			AVMetadataFaceObject * originalFace = [self.lastMetadata objectAtIndex:i];
#warning transformedMetadataObjectForMetadataObject: will be available in iOS 6 dev seed 2 and later
			AVMetadataFaceObject * adjustedFace = (AVMetadataFaceObject*)[self.stillImageOutput transformedMetadataObjectForMetadataObject:originalFace connection:stillImageConnection];
			
			CGRect frame = adjustedFace.bounds;
			// we'll fit the image to the face width and scale the height correspondingly to keep the aspect ratio
			CGFloat imgWidth = CGImageGetWidth(img);
			CGFloat imgHeight = CGImageGetHeight(img);
			CGFloat newHeight = frame.size.width * imgHeight / imgWidth;
			frame.origin.y += (frame.size.height - newHeight) / 2;
			frame.size.height = newHeight;
			// and apply some scaling factor too
			frame.origin.x += (1-SCALE_FUNNY_FACE) * frame.size.width / 2;
			frame.origin.y += (1-SCALE_FUNNY_FACE) * frame.size.height / 2;
			frame.size.width *= SCALE_FUNNY_FACE;
			frame.size.height *= SCALE_FUNNY_FACE;
			
			CGContextSaveGState(bitmapContext);
			
			// match AVF's top-left convention
			CGContextTranslateCTM(bitmapContext, 0, backgroundImageRect.size.height);
			CGContextScaleCTM(bitmapContext, 1, -1);
			
			// We flipped y axis above so we can pass AVF's coordinates here
			CGContextTranslateCTM(bitmapContext, frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2);
			if ( adjustedFace.hasRollAngle && adjustedFace.rollAngle!=0 )
				CGContextRotateCTM(bitmapContext, DegreesToRadians(adjustedFace.rollAngle));
			
			// convert back to CGContext layout to draw the image
			BOOL mirrored = [self.previewLayer.connection isVideoMirrored];
			CGContextScaleCTM(bitmapContext, mirrored?-1:1, -1); // respect mirroring on x, but must also reflip y axis for drawing
			CGContextDrawImage(bitmapContext, CGRectMake(-frame.size.width/2, -frame.size.height/2, frame.size.width, frame.size.height), img);
			
			CGContextRestoreGState(bitmapContext);
		}
	}
	
	// convert the drawing context to a final image
	CGImageRef cgImageResult = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease (bitmapContext);
	if ( ! cgImageResult ) {
		displayErrorOnMainQueue(nil, @"Failed to convert context to CGImage");
		return NULL;
	}
	return cgImageResult;
}

@end


// creates a CGContext of the specified size for doing off-screen graphics
static CGContextRef CreateCGBitmapContextForSize(CGSize size)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate (NULL,
		size.width,
		size.height,
		8, // bits per component
		(size.width * 4), // row size - four bytes per pixel
		colorSpace,
		kCGImageAlphaPremultipliedLast);
	CGContextSetAllowsAntialiasing (context, NO);
    CGColorSpaceRelease( colorSpace );
    return context;
}

// locks the base address of the pixel buffer and creates a CGImage referencing the image data
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut)
{
	CVPixelBufferRetain( pixelBuffer );
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	void *sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
	
	CGBitmapInfo bitmapInfo;
	OSType sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
	if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
	else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	else {
		displayErrorOnMainQueue(nil, [NSString stringWithFormat:@"Unknown pixel format %lu",sourcePixelFormat]);
		CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
		CVPixelBufferRelease( pixelBuffer );
		return -95014;
	}
	
	size_t sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
	size_t width = CVPixelBufferGetWidth( pixelBuffer );
	size_t height = CVPixelBufferGetHeight( pixelBuffer );
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
	CGDataProviderRef provider = CGDataProviderCreateWithData( pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer );
	if ( provider ) {
		*imageOut = CGImageCreate( width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault );
		CGDataProviderRelease( provider );
	}
	
	if ( colorspace ) CGColorSpaceRelease( colorspace );
	return noErr;
}

// passed as a callback to CGDataProviderCreateWithData for automatic cleanup
static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size)
{	
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
	CVPixelBufferRelease( pixelBuffer );
}

// returns a new image flipped over the y axis
static UIImage* newHorizFlippedImage(UIImage* image) {
	CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
	CGContextRef bitmapContext = CreateCGBitmapContextForSize(bounds.size);
	if ( ! bitmapContext ) {
		displayErrorOnMainQueue(nil, @"Could not flip funny face");
		return image;
	}
	CGContextTranslateCTM(bitmapContext, bounds.size.width, 0);
	CGContextScaleCTM(bitmapContext, -1, 1);
	CGContextDrawImage(bitmapContext, bounds, image.CGImage);
	CGImageRef cgImageResult = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease (bitmapContext);
	if ( ! cgImageResult ) {
		displayErrorOnMainQueue(nil, @"Failed to convert flipped context to CGImage");
		return image;
	}
	UIImage * ans = [UIImage imageWithCGImage:cgImageResult];
	CGImageRelease(cgImageResult);
	return ans;
}

// takes an image, compresses to JPEG and forwards to writeJPEGDataToCameraRoll()
static BOOL writeCGImageToCameraRoll(CGImageRef cgImage, NSDictionary *metadata)
{
	NSMutableData* destinationData = [NSMutableData dataWithLength:0];
	CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)destinationData, CFSTR("public.jpeg"), 1, NULL);
	if ( destination==NULL ) {
		displayErrorOnMainQueue(nil, @"Save to camera roll failed: could not create destination");
		return NO;
	}
	
	const float JPEGCompQuality = 0.85f; // JPEGHigherQuality
	NSDictionary* optionsDict = @{ (__bridge NSString*)kCGImageDestinationLossyCompressionQuality : [NSNumber numberWithFloat:JPEGCompQuality] };
	
	CGImageDestinationAddImage( destination, cgImage, (__bridge CFDictionaryRef)optionsDict );
	BOOL success = CGImageDestinationFinalize( destination );
	CFRelease(destination);
	if ( success ) {
		writeJPEGDataToCameraRoll(destinationData, metadata);
	} else {
		displayErrorOnMainQueue(nil, @"Save to camera roll failed: could not finalize destination");
	}
	
	return success;
}

// writes the image to the asset library
void writeJPEGDataToCameraRoll(NSData* data, NSDictionary* metadata)
{
	ALAssetsLibrary *library = [ALAssetsLibrary new];
	[library writeImageDataToSavedPhotosAlbum:data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
		if (error) {
			displayErrorOnMainQueue(error, @"Save to camera roll failed");
		}
	}];
}

// converts UIDeviceOrientation to AVCaptureVideoOrientation
static AVCaptureVideoOrientation avOrientationForDeviceOrientation(UIDeviceOrientation deviceOrientation)
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

