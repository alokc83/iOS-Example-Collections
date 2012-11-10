/*
     File: AppDelegate.m 
 Abstract: This sample's NSApplicationDelegate object.
  
  Version: 1.1 
  
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
  
 */

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong) NSMutableArray *data;
@property (assign) id initialSelectedObject;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSURL *dirURL = [[NSBundle mainBundle] resourceURL];

    // load all the necessary image files by enumerating through the bundle's Resources folder,
    // this will only load images of type "kUTTypeImage"
    //
    self.data = [[NSMutableArray alloc] initWithCapacity:1];

    NSDirectoryEnumerator *itr = [[NSFileManager defaultManager] enumeratorAtURL:dirURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLLocalizedNameKey, NSURLEffectiveIconKey, NSURLIsDirectoryKey, NSURLTypeIdentifierKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];

    for (NSURL *url in itr) {
        NSString *utiValue;
        [url getResourceValue:&utiValue forKey:NSURLTypeIdentifierKey error:nil];
        
        if (UTTypeConformsTo((__bridge CFStringRef)(utiValue), kUTTypeImage)) {
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
            [self.data addObject:image];
        }
    }

    // set the first image in our list to the main magnifying view
    if ([self.data count] > 0) {
        [self.pageController setArrangedObjects:self.data];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    switch ([menuItem tag]) {
        case 0:
            [menuItem setState:(self.pageController.transitionStyle == NSPageControllerTransitionStyleHorizontalStrip) ?
                    NSOnState : NSOffState];
            break;
        case 1:
            [menuItem setState:(self.pageController.transitionStyle == NSPageControllerTransitionStyleStackHistory) ?
                    NSOnState : NSOffState];
            break;
        case 2:
            [menuItem setState:(self.pageController.transitionStyle == NSPageControllerTransitionStyleStackBook) ?
                    NSOnState : NSOffState];
            break;
    }
    
    return YES;
}

// user is choosing between "stack" style scrolling or "slide show" style scrolling
- (IBAction)takeTransitionStyleFrom:(id)sender {

    switch([sender tag]) {
        case 0:
            self.pageController.transitionStyle = NSPageControllerTransitionStyleHorizontalStrip;
            break;
        case 1:
            self.pageController.transitionStyle = NSPageControllerTransitionStyleStackHistory;
            break;
        case 2:
        default:
            self.pageController.transitionStyle = NSPageControllerTransitionStyleStackBook;
            break;
    }
}

@end


@implementation AppDelegate (NSPageControllerDelegate)
- (NSString *)pageController:(NSPageController *)pageController identifierForObject:(id)object {
    return @"picture";
}

- (NSViewController *)pageController:(NSPageController *)pageController viewControllerForIdentifier:(NSString *)identifier {
    return [[NSViewController alloc] initWithNibName:@"imageview" bundle:nil];
}

-(void)pageController:(NSPageController *)pageController prepareViewController:(NSViewController *)viewController withObject:(id)object {
    // viewControllers may be reused... make sure to reset important stuff like the current magnification factor.
    
    // Normally, we want to reset the magnification value to 1 as the user swipes to other images. However if the user cancels the swipe, we want to leave the original magnificaiton and scroll position alone.
    
    BOOL isRepreparingOriginalView = (self.initialSelectedObject && self.initialSelectedObject == object) ? YES : NO;
    if (!isRepreparingOriginalView) {
        [(NSScrollView*)viewController.view setMagnification:1.0];
    }
    
    // Since we implement this delegate method, we are reponsible for setting the representedObject.
    viewController.representedObject = object;
}

- (void)pageControllerWillStartLiveTransition:(NSPageController *)pageController {
    // Remember the initial selected object so we can determine when a cancel occurred.
    self.initialSelectedObject = [pageController.arrangedObjects objectAtIndex:pageController.selectedIndex];
}

- (void)pageControllerDidEndLiveTransition:(NSPageController *)pageController {
    [pageController completeTransition];
}

@end