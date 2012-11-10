/*
     File: AppDelegate.m 
 Abstract: Main controller object as the NSApplicationDelegate. 
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
#import "FileObject.h"
#import "CardBackgroundView.h"

#define kNibName @"FileCard"
#define kImageNibname @"ImageCard"

@implementation AppDelegate

@synthesize window = _window;
@synthesize pageController = _pageController;
@synthesize tableView = _tableView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSURL *dirURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    
    // load all the file card URLs by enumerating through the user's Document folder,
    data = [[NSMutableArray alloc] initWithCapacity:1];
    
    NSDirectoryEnumerator *itr = [[NSFileManager defaultManager] enumeratorAtURL:dirURL includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLLocalizedNameKey, NSURLEffectiveIconKey, NSURLIsDirectoryKey, NSURLTypeIdentifierKey, nil] options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    
    for (NSURL *url in itr) {
        NSNumber *isDirNum;
        [url getResourceValue:&isDirNum forKey:NSURLIsDirectoryKey error:nil];
        if ([isDirNum boolValue]) continue;
        
        [data addObject:[FileObject fileObjectWithURL:url]];
    }
        
    // set the first card in our list
    if ([data count] > 0) {
        [self.pageController setArrangedObjects:data];
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
}

- (IBAction)takeTransitionStyleFrom:(id)sender {
    [self.pageController setTransitionStyle:[(NSButton*)sender selectedTag]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger selectedIndex = [self.tableView selectedRow];
    if (selectedIndex >= 0 && selectedIndex != self.pageController.selectedIndex) {
        
        // The selection of the table view changed. We want to animate to the new selection. However, since we are manually performing the animation, -pageControllerDidEndLiveTransition: will not be called. We are required to [self.pageController completeTransition] when the animation completes.
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[self.pageController animator] setSelectedIndex:selectedIndex];
        } completionHandler:^{
            [self.pageController completeTransition];
        }];
    }
}

// Required method for BookUI mode of NSPageController
// We have different cards for image files and everything else. Therefore, we have different identifiers
- (NSString *)pageController:(NSPageController *)pv identifierForObject:(id)object {
    FileObject *fileObj = (FileObject *)object;
    if (UTTypeConformsTo((__bridge CFStringRef)fileObj.utiType, kUTTypeImage)) {
        return kImageNibname;
    }
    
    return kNibName;
}

// Required method for BookUI mode of NSPageController
- (NSViewController *)pageController:(NSPageController *)pageController viewControllerForIdentifier:(NSString *)identifier {
    return [[NSViewController alloc] initWithNibName:identifier bundle:nil];
}

// Optional delegate method. This method is used to inset the card a little bit from it's parent view
- (NSRect)pageController:(NSPageController *)pageController frameForObject:(id)object {
    return NSInsetRect(pageController.view.bounds, 5, 5);
}

- (void)pageControllerDidEndLiveTransition:(NSPageController *)pageController {
    // Update the NSTableView selection
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:pageController.selectedIndex] byExtendingSelection:NO];
    
    // tell page controller to complete the transition and display the updated file card.
    [pageController completeTransition];
}

@end
