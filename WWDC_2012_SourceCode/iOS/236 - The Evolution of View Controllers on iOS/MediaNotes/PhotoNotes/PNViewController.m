
/*
     File: PNViewController.m
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

#import "PNViewController.h"

#define USE_AUTOLAYOUT 1
#define USE_FULLSCREEN_LAYOUT 1
#define OVERRIDE_SUPPORTED_ORIENTATIONS 0

@interface PNContainerView : UIView
@end

@implementation PNContainerView

+(BOOL)requiresConstraintBasedLayout
{
    return USE_AUTOLAYOUT ? YES : NO;
}
@end


@interface PNViewController ()

@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property(nonatomic, weak) IBOutlet UIToolbar *toolbar;

// Initial launch view stuff
@property(nonatomic, weak) IBOutlet UIView *placeHolderView;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *placeHolderActivityView;
@property(nonatomic, weak) IBOutlet UILabel *placeHolderLabel;

- (IBAction)nextPhoto;
- (IBAction)previousPhoto;

@end


@implementation PNViewController
{
    NSMutableDictionary *photoMap;
    NSURL *currentPhotoURL;
    BOOL syncIsNeeded;
#if USE_AUTOLAYOUT
    NSLayoutConstraint  * __weak toolbarTopConstraint;
#endif
}
@synthesize dataSource=dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        photoMap = [NSMutableDictionary dictionary];
    }

#if USE_FULLSCREEN_LAYOUT
    self.wantsFullScreenLayout = YES;
#endif
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#if USE_AUTOLAYOUT
    [self.toolbar setTranslatesAutoresizingMaskIntoConstraints: NO];
    [self.photoImageView setTranslatesAutoresizingMaskIntoConstraints: NO];
#endif
}

#if OVERRIDE_SUPPORTED_ORIENTATIONS
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationAllButUpsideDownMask;
}
#endif

- (void)associatedCommentDidChange:(NSString *)comment
{
    [photoMap setObject:comment forKey:currentPhotoURL];
}

- (NSString *)associatedComment
{
    NSString *comment = [photoMap objectForKey:currentPhotoURL];
    if(nil == comment) {
        comment = @"A random comment goes here";
        [photoMap setObject:comment forKey:currentPhotoURL];
    }
    return comment;
}

- (NSArray *)itemsForSharing
{
    UIImage *image = [dataSource imageForCurrentItem];
    if(image) {
        return [NSArray arrayWithObject:image];
    }
    else {
        return nil;
    }
}

- (void)didReceiveMemoryWarning
{
    if([self.view window] == nil) {
        [photoMap removeAllObjects];
        self.view = nil;
        self.photoImageView = nil;
        self.toolbar = nil;
        syncIsNeeded = YES;
    }
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    // NSLog(@"%@:%s",self,(char *)_cmd);
}

- (void)viewWillDisappear:(BOOL)animated
{
    // NSLog(@"%@:%s",self,(char *)_cmd);
}

- (void)viewDidAppear:(BOOL)animated
{
    // NSLog(@"%@:%s",self,(char *)_cmd);
}

- (void)viewDidDisappear:(BOOL)animated
{
    // NSLog(@"%@:%s",self,(char *)_cmd);
}

- (void)viewWillLayoutSubviews
{
    if (syncIsNeeded) {
        [self synchronize];
        syncIsNeeded = NO;
    }
}

#define STATUSBAR_HEIGHT(app) ((UIInterfaceOrientationIsLandscape([app statusBarOrientation])) ? [app statusBarFrame].size.width : [app statusBarFrame].size.height)

#if USE_AUTOLAYOUT
- (void)updateViewConstraints
{
    CGFloat toolbarVerticalOffset = self.wantsFullScreenLayout ? STATUSBAR_HEIGHT([UIApplication sharedApplication]) : 0.0;

    // if(0 == [[self.view constraints] count]) {
    if(nil == toolbarTopConstraint) {
        NSLayoutConstraint *tconstraint2 = [NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:toolbarVerticalOffset];
        
        toolbarTopConstraint = tconstraint2;
        
        NSLayoutConstraint *tconstraint1 = [NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
        
        // This may not be needed because it has an intrinsic content size.
        NSLayoutConstraint *tconstraint3 = [NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        
        NSLayoutConstraint *tconstraint4 = [NSLayoutConstraint constraintWithItem:self.toolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.toolbar attribute:NSLayoutAttributeHeight multiplier:0.0 constant:44.0];

        // Make the image view the largest square we can. N.B. We use a content mode of scale aspect fit, so the images won't necessarily appear square
        NSLayoutConstraint *constraint0 = [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.photoImageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        
        // Centered in its superview
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        
        NSLayoutConstraint *constraint2;
        
        if(self.wantsFullScreenLayout) {
            constraint2= [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        }
        else {
            constraint2= [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.toolbar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        }
        
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.photoImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        
        [self.view addConstraints: [NSArray arrayWithObjects:tconstraint1, tconstraint2, tconstraint3, tconstraint4, constraint0,constraint1, constraint2, constraint3, nil]];
    }
    else {
        toolbarTopConstraint.constant = toolbarVerticalOffset;
    }
    [super updateViewConstraints];
}
#endif

- (void)synchronize
{
    [self.placeHolderActivityView stopAnimating];
    [self.photoImageView setImage: [dataSource imageForCurrentItem]];
    currentPhotoURL = [dataSource URLForCurrentItem];
    [self.placeHolderView removeFromSuperview];
    self.placeHolderActivityView = nil;
    self.placeHolderView = nil;
    self.placeHolderLabel = nil;
}

- (void)synchronize:(BOOL)initializationSucceeded
{
    if(initializationSucceeded) {
        [self.placeHolderActivityView stopAnimating];
        [self.photoImageView setImage: [dataSource imageForCurrentItem]];
        currentPhotoURL = [dataSource URLForCurrentItem];
        [[self YYCommentViewController] associatedObjectDidChange:self];
        [UIView animateWithDuration:.25 animations: ^{[self.placeHolderActivityView setAlpha:0.0];}
                         completion:^(BOOL finishedp) {
                             [self.placeHolderView removeFromSuperview];
                             self.placeHolderActivityView = nil;
                             self.placeHolderView = nil;
                             self.placeHolderLabel = nil;
                         }];
    }
    else {
        [self.placeHolderActivityView stopAnimating];
        [self.placeHolderLabel setText:@"No Photos"];
    }
}

- (void)nextPhoto
{
    [dataSource proceedToNextItem];
    currentPhotoURL = [dataSource URLForCurrentItem];
    if(currentPhotoURL) {
        [[self YYCommentViewController] associatedObjectDidChange:self];
        [UIView animateWithDuration: .25 animations: ^{
            [self.photoImageView setAlpha:0.0];
        } completion: ^(BOOL finished) {
            [self.photoImageView setImage: [dataSource imageForCurrentItem]];
            [UIView animateWithDuration: .25 animations: ^{
                [self.photoImageView setAlpha:1.0];
            }];
        }];
    }
}

- (void)previousPhoto
{
    [dataSource proceedToPreviousItem];
    currentPhotoURL = [dataSource URLForCurrentItem];
    if(currentPhotoURL) {
        [[self YYCommentViewController] associatedObjectDidChange:self];    
        [UIView animateWithDuration: .25 animations: ^{
            [self.photoImageView setAlpha:0.0];
        } completion: ^(BOOL finished) {
            [self.photoImageView setImage: [dataSource imageForCurrentItem]];
            [UIView animateWithDuration: .25 animations: ^{
                [self.photoImageView setAlpha:1.0];
            }];
        }];
    }
}

@end
