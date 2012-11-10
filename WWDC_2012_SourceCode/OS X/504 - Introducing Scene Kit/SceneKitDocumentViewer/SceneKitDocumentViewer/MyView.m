/*
     File: MyView.m 
 Abstract: n/a 
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

#import "MyView.h"

@implementation MyView {
    SCNMaterial *selectedMaterial;
}

- (void)loadSceneAtURL:(NSURL *)url
{
    //clear selection
    selectedMaterial = nil;
    
    //load specified scene
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setValue:[NSNumber numberWithBool:YES] forKey:SCNSceneSourceCreateNormalsIfAbsentKey]; //create normals if absent
    [options setValue:[NSNumber numberWithBool:YES] forKey:SCNSceneSourceFlattenSceneKey]; //optimize the rendering by flattening the scene graph when possible. Note that this would prevent you from animating objects independantly.
    
    self.scene = [SCNScene sceneWithURL:url options:options error:nil];
}

#pragma mark -

- (void)commonInit {
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Drag and drop

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return NSDragOperationCopy;    
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
        NSData *data = [pasteboard dataForType:NSFilenamesPboardType];
        if (data) {
            NSString *errorDescription;
            NSArray *filenames = [NSPropertyListSerialization propertyListFromData:data 
                                                                  mutabilityOption:kCFPropertyListImmutable 
                                                                            format:nil 
                                                                  errorDescription:&errorDescription];

            if (filenames != nil) {
                if ([filenames isKindOfClass:[NSArray class]]) {
                    if ([filenames count] > 0) {
                        [self loadSceneAtURL:[NSURL fileURLWithPath:[filenames objectAtIndex:0] isDirectory:NO]];
                        return YES;
                    }
                }
            }
        }
    }
    
    return NO;
}


#pragma mark - Mouse selection

- (void)selectNode:(SCNNode *)node geometryElementIndex:(NSUInteger)index
{
    //unhighlight previous selection
    [selectedMaterial.emission removeAllAnimations];
    
    //clear selection
    selectedMaterial = nil;
    
    //highight selection
    if (node != nil) {
        //convert geometry element index to material index
        index = index % [node.geometry.materials count];
        
        //make the material unique (i.e. unshared)
        SCNMaterial *unsharedMaterial = [[node.geometry.materials objectAtIndex:index] copy];
        [node.geometry replaceMaterialAtIndex:index withMaterial:unsharedMaterial];
        
        //select it
        selectedMaterial = unsharedMaterial;
        
        //animate it
        CABasicAnimation *highlightAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
        highlightAnimation.toValue = [NSColor blueColor];
        highlightAnimation.fromValue = [NSColor blackColor];
        highlightAnimation.repeatCount = MAXFLOAT;
        highlightAnimation.autoreverses = YES;
        highlightAnimation.duration = 0.5;
        highlightAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [selectedMaterial.emission addAnimation:highlightAnimation forKey:@"highlight"];
    }
}

#pragma mark - Mouse events

- (void)mouseDown:(NSEvent *)event
{
    NSPoint mouseLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    NSArray *hits = [self hitTest:mouseLocation options:nil];
    
    if ([hits count] > 0) {
        SCNHitTestResult *hit = [hits objectAtIndex:0]; //nearest object hit
        [self selectNode:hit.node geometryElementIndex:hit.geometryIndex];
    } else {
        [self selectNode:nil geometryElementIndex:NSNotFound];
    }
    
    [super mouseDown:event];
}

@end
