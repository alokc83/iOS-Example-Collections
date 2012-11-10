
/*
     File: StacheCamViewController+AVFFaceDetection.m
 Abstract: Category for methods related to AVFoundation-based face detection
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


#import "StacheCamViewController+AVFFaceDetection.h"
#import "StacheCamViewController+Graphics.h"
#import "UserDefaults.h"

@implementation StacheCamViewController (AVFFaceDetection)

- (void) setupAVFoundationFaceDetection
{
	self.avfProcessingInterval = 1;
	self.avfFaceLayers = [NSMutableDictionary new];
	self.indexForFaceID = [NSMutableDictionary new];
	
	self.metadataOutput = [AVCaptureMetadataOutput new];
	if ( ! [self.session canAddOutput:self.metadataOutput] ) {
		[self teardownAVFoundationFaceDetection];
		return;
	}

	// Metadata processing will be fast, and mostly updating UI which should be done on the main thread
	// So just use the main dispatch queue instead of creating a separate one
	// (compare this to the expensive CoreImage face detection, done on a separate queue)
	[self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
	[self.session addOutput:self.metadataOutput];

	if ( ! [self.metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeFace] ) {
		// face detection isn't supported (via AV Foundation), fall back to CoreImage
		[self teardownAVFoundationFaceDetection];
		return;
	}
	// We only want faces, if we don't set this we would detect everything available
	// (some objects may be expensive to detect, so best form is to select only what you need)
	self.metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeFace ];
	
	// update UI to reflect accessibility
	self.mustacheSwitch.enabled = (self.funnyFaces.count > 0); // check we successfully loaded graphics
	self.avfRectSwitch.enabled = YES;
	self.mustacheSwitch.on = UserDefaults.displayAVFMustaches;
	self.avfRectSwitch.on = UserDefaults.displayAVFRects;
	[self updateAVFoundationDetection:nil];
}

- (void) teardownAVFoundationFaceDetection
{
	if ( self.metadataOutput )
		[self.session removeOutput:self.metadataOutput];
	self.metadataOutput = nil;
	self.avfFaceLayers = nil;
	self.indexForFaceID = nil;
	
	// update UI to reflect inaccessibility
	self.mustacheSwitch.enabled = NO;
	self.avfRectSwitch.enabled = NO;
	self.mustacheSwitch.on = NO;
	self.avfRectSwitch.on = NO;
}

- (IBAction)updateAVFoundationDetection:(UISwitch*)sender
{
	if ( !self.metadataOutput )
		return;
	
	// update stored user defaults so we come back in the same mode
	UserDefaults.displayAVFMustaches = self.mustacheSwitch.on;
	UserDefaults.displayAVFRects = self.avfRectSwitch.on;
	BOOL detectFaces = UserDefaults.displayAVFMustaches || UserDefaults.displayAVFRects;
	
	// enable/disable the AVCaptureMetadataOutput to control the flow of AVCaptureMetadataOutputObjectsDelegate calls
	[[self.metadataOutput connectionWithMediaType:AVMediaTypeMetadata] setEnabled:detectFaces];
	
	// update graphics associated with previously detected faces
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	self.avfFPSLabel.hidden = !detectFaces;
	self.fpsView.hidden = self.avfFPSLabel.hidden && self.ciFPSLabel.hidden;
	[CATransaction commit];
	
	if (detectFaces) {
		if ( sender == self.mustacheSwitch ) {
			if ( ! UserDefaults.displayAVFMustaches ) {
				// now disabled, just hide current contents (when turning on, we'll need to check yaw value)
				for ( CALayer* layer in self.avfFaceLayers.allValues ) {
					layer.sublayers = [NSArray new];
				}
			}
		} else if ( sender == self.avfRectSwitch ) {
			CGFloat borderWidth = UserDefaults.displayAVFRects ? FACE_RECT_BORDER_WIDTH : 0;
			for ( CALayer* layer in self.avfFaceLayers.allValues ) {
				[layer setBorderWidth:borderWidth];
			}
		}
	} else {
		// dispatch to the end of queue in case a delegate call was already pending before we stopped the output
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			for ( CALayer * layer in self.avfFaceLayers.allValues )
				[layer removeFromSuperlayer];
			[self.avfFaceLayers removeAllObjects];
		});
	}
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer {
	if (recognizer.state != UIGestureRecognizerStateEnded)
		return; // don't track during gesture-down

	CGPoint location = [recognizer locationInView:self.previewView];
	
	// find which layer was tapped (if any
	CALayer* hitLayer = nil;
	NSNumber* hitID = nil;
	for ( NSNumber* faceID in self.avfFaceLayers ) {
		CALayer* layer = [self.avfFaceLayers objectForKey:faceID];
		CGPoint convertedLocation = [layer convertPoint:location fromLayer:self.previewLayer.superlayer];
		if ( [layer containsPoint:convertedLocation] ) {
			hitLayer = layer;
			hitID = faceID;
			break; // unlikely to have overlapping face rects, just use the first one we find
		}
	}
	if ( ! hitLayer || hitLayer.sublayers.count==0 )
		return;
	
	NSNumber* graphicNumber = [self.indexForFaceID objectForKey:hitID];
	NSUInteger graphicIdx = (graphicNumber ? [graphicNumber integerValue] : 0);
	if ( ++graphicIdx >= self.funnyFaces.count )
		graphicIdx -= self.funnyFaces.count;
	[self.indexForFaceID setObject:[NSNumber numberWithInteger:graphicIdx] forKey:hitID];
	//NSLog(@"Tapped upon faceID %@ now using graphic %d",hitID,graphicIdx);
	
	// we'll just wait until the next face detection to update the graphics
}

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)faces fromConnection:(AVCaptureConnection *)connection
{
	// We can assume all received metadata objects are AVMetadataFaceObject only
	// because we set the AVCaptureMetadataOutput's metadataObjectTypes
	// to solely provide AVMetadataObjectTypeFace (see setupAVFoundationFaceDetection)
	
	if ( ! self.previewLayer.connection.enabled )
		return; // don't update face graphics when preview is frozen
	
	// Measure/report performance statistics
	if ( self.avfFaceLayers.count == 0 ) {
		self.avfLastFrameTime = [NSDate date];
	} else if ( faces.count == 0 ) {
		self.avfFPSLabel.text = [NSString stringWithFormat:@"AVF FPS:"];
	} else {
		NSDate* curTime = [NSDate date];
		self.avfProcessingInterval = self.avfProcessingInterval*0.75 + [curTime timeIntervalSinceDate:self.avfLastFrameTime]*0.25;
		self.avfFPSLabel.text = [NSString stringWithFormat:@"AVF FPS: % 3.0f",1/self.avfProcessingInterval];
		self.avfLastFrameTime = curTime;
	}
	
	// As we process faces below, remove them from this set so at the end we'll know which faces were lost
	NSMutableSet* unseen = [NSMutableSet setWithArray:self.avfFaceLayers.allKeys];
	NSMutableArray* facesForMetadata = [NSMutableArray arrayWithCapacity:faces.count];
	
	// Begin display updates
	[CATransaction begin];
	if ( ! UserDefaults.usingAnimation )
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	else
		[CATransaction setAnimationDuration:self.avfProcessingInterval];
	
	for ( AVMetadataFaceObject * object in faces ) {
		NSNumber* faceID = [NSNumber numberWithInteger:object.faceID];
		[unseen removeObject:faceID];
		
		CALayer * layer = [self.avfFaceLayers objectForKey:faceID];
		if ( ! layer ) { // new face, create a layer
			CALayer *layer = [CALayer new];
			if(UserDefaults.displayAVFRects)
				layer.borderWidth = FACE_RECT_BORDER_WIDTH;
			layer.borderColor = [[UIColor greenColor] CGColor];
			[self.previewLayer addSublayer:layer];
			[self.avfFaceLayers setObject:layer forKey:faceID];
		}
		
#warning transformedMetadataObjectForMetadataObject: will be available in iOS 6 dev seed 2 and later
		AVMetadataFaceObject * adjusted = (AVMetadataFaceObject*)[self.previewLayer transformedMetadataObjectForMetadataObject:object];

		CATransform3D transform = CATransform3DIdentity;
		[layer setTransform:transform]; // reset identity before setting frame
		[layer setFrame:adjusted.bounds];
		if (adjusted.hasRollAngle)
			transform = CATransform3DRotate(transform, DegreesToRadians(adjusted.rollAngle), 0, 0, 1);
		[layer setTransform:transform];
		
		id cgFace = nil;
		if ( UserDefaults.displayAVFMustaches ) {
			// find the image we're supposed to be using given the current yaw
			NSNumber* graphicNumber = [self.indexForFaceID objectForKey:faceID];
			NSUInteger graphicIdx = (graphicNumber ? [graphicNumber integerValue] : 0);
			CGFloat yaw = 0;
			if (adjusted.hasYawAngle)
				yaw = adjusted.yawAngle;
			UIImage* image = [self pickGraphic:graphicIdx forYaw:yaw];
			cgFace = (__bridge id)[image CGImage];
			
			// update the image being displayed
			if ( layer.sublayers.count == 0 )
				[layer addSublayer:[CALayer new]];
			CALayer* graphicLayer = [layer.sublayers objectAtIndex:0];
			graphicLayer.contents = cgFace;

			// we'll fit the image to the face width and scale the height correspondingly to keep the aspect ratio
			CGRect frame = layer.bounds;
			CGFloat newHeight = frame.size.width * image.size.height / image.size.width;
			frame.origin.y += (frame.size.height - newHeight) / 2;
			frame.size.height = newHeight;
			// and apply some scaling factor too
			frame.origin.x += (1-SCALE_FUNNY_FACE) * frame.size.width / 2;
			frame.origin.y += (1-SCALE_FUNNY_FACE) * frame.size.height / 2;
			frame.size.width *= SCALE_FUNNY_FACE;
			frame.size.height *= SCALE_FUNNY_FACE;
			graphicLayer.frame = frame;
		}
		
		[facesForMetadata addObject: cgFace ? cgFace : [NSNull null] ];
		
	}

	// Store this metadata and graphic in case we take a still image
	@synchronized(self.lastMetadata) {
		self.lastMetadata = [faces copy];
		self.facesForMetadata = facesForMetadata;
	}
	
	// remove the graphics for faces that weren't detected
	for ( NSNumber* faceID in unseen ) {
		CALayer * layer = [self.avfFaceLayers objectForKey:faceID];
		[layer removeFromSuperlayer];
		[self.avfFaceLayers removeObjectForKey:faceID];
		[self.indexForFaceID removeObjectForKey:faceID];
	}
	
	[CATransaction commit];
}

// Picks the graphic with the yaw value closest to the specified yaw value
- (UIImage*) pickGraphic:(NSUInteger)idx forYaw:(CGFloat)yaw
{
	NSDictionary* yawImages = [self.funnyFaces objectAtIndex:idx];
	NSArray* testYaws = [yawImages allKeys];
	
	CGFloat bestYaw = 0;
	CGFloat bestDist = fabsf([[testYaws objectAtIndex:bestYaw] floatValue] - yaw);
	for ( NSUInteger i=1; i<testYaws.count; ++i )  {
		CGFloat testYaw = [[testYaws objectAtIndex:i] floatValue];
		CGFloat dist = fabsf(testYaw - yaw);
		if ( dist < bestDist ) {
			bestYaw = i;
			bestDist = dist;
		}
	}
	
	return [yawImages objectForKey:[testYaws objectAtIndex:bestYaw]];
}

@end















