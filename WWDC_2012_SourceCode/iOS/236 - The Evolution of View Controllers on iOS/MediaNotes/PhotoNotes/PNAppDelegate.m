
/*
     File: PNAppDelegate.m
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

#import "PNAppDelegate.h"
#import "PNViewController.h"
#import "YYCommentContainerViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>


@implementation PNAppDelegate
{
    NSMutableArray *photoAssets;
    ALAssetsLibrary *assetsLibrary;
    ALAsset *currentAsset;
    UIImage *currentPhotoImage;
    NSInteger currentPhotoIndex;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UIViewController *viewController = [[PNViewController alloc] initWithNibName:@"PNViewController" bundle:nil];
    [(PNViewController *)viewController setDataSource:self];

    [self initializePhotos];
    
    self.viewController = [[YYCommentContainerViewController alloc] initWithController:viewController];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

// Hardwire to a maximum number of photos for the purposes of this demonstration
#define PHOTO_ASSETS_CAPACITY 50

// ALAssetsGroupSavedPhotos
- (void)initializePhotos
{
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    currentPhotoIndex = -1;
    photoAssets = [NSMutableArray arrayWithCapacity: PHOTO_ASSETS_CAPACITY];
    __block NSInteger photoIndex = 0;
    __block BOOL syncContentController = YES;
    [assetsLibrary enumerateGroupsWithTypes: ALAssetsGroupAlbum
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                     NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
                                     if([groupName hasPrefix:PNALBUM_PREFIX]) {
                                         [group setAssetsFilter: [ALAssetsFilter allPhotos]];
                                         [group enumerateAssetsUsingBlock: ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                                             if (index != NSNotFound && asset) {
                                                 [photoAssets addObject: asset];
                                                 photoIndex++;
                                                 currentPhotoIndex = 0;
                                             }
                                             if(photoIndex == PHOTO_ASSETS_CAPACITY) {
                                                 *stop = YES;
                                             }
                                         }];
                                     }
                                     if(syncContentController) {
                                         syncContentController = NO; // Only synchronize the content controller once.
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if(currentPhotoIndex == 0) {
                                                 [self setCurrentPhotoToIndex:0];
                                             }
                                             [(PNViewController *)[self.viewController contentController] synchronize: (currentPhotoIndex >= 0)];
                                         });
                                     }
                                 }
                               failureBlock: ^(NSError *error) {
                                   NSLog(@"User denied access to photo library... %@",error);
                               }];
    
}

- (void)setCurrentPhotoToIndex:(NSInteger)idx
{
    currentAsset = [photoAssets objectAtIndex:idx];
    // NSDictionary *map = [currentAsset valueForProperty: ALAssetPropertyURLs];
    ALAssetRepresentation *rep = [currentAsset representationForUTI:@"public.jpeg"];
    CGImageRef imageRef = [rep fullScreenImage];
    if(imageRef) {
        currentPhotoImage = [UIImage imageWithCGImage:imageRef];
        currentPhotoIndex = idx;
    }
}

- (UIImage *)imageForCurrentItem;
{
    return currentPhotoImage;
}

- (NSURL *)URLForCurrentItem
{
    NSDictionary *map = [currentAsset valueForProperty:ALAssetPropertyURLs];
    return [map objectForKey:@"public.jpeg"];
}

- (void) proceedToNextItem
{
    if([photoAssets count] > 0) {
        currentPhotoIndex++;
        [self setCurrentPhotoToIndex: (currentPhotoIndex < [photoAssets count]) ? currentPhotoIndex : 0];
    }
}

- (void) proceedToPreviousItem
{
    if([photoAssets count] > 0) {
        currentPhotoIndex--;
        [self setCurrentPhotoToIndex: (currentPhotoIndex < 0) ? [photoAssets count] - 1 : currentPhotoIndex];
    }
}


@end
