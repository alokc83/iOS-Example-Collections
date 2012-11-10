
/*
     File: YYCommentContainerViewController.m
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

#import "YYCommentContainerViewController.h"

#define USE_AUTOLAYOUT 1
#define ENABLE_KEYBOARD_AVOIDANCE 1

/*
 By enabling these defines and disabling USE_AUTOLAYOUT you will see other ways to update the layout during rotation. ENABLE_WILL_ROTATE_ADJUSTMENT is an example of how NOT to do it. Note that rotations of full screen presentations no longer result in rotation callbacks to the presenting controller upon dismissal.
 */
#define ENABLE_LAYOUT_SUBVIEWS 0
#define ENABLE_WILL_ROTATE_ADJUSTMENT 0


@interface YYCommentContainerView : UIView
@end

@implementation YYCommentContainerView

+(BOOL)requiresConstraintBasedLayout
{
    return USE_AUTOLAYOUT ? YES : NO;
}

@end

@implementation UIViewController(YYCommentContainer)

- (YYCommentViewController *)YYCommentViewController
{
    return [[self parentViewController] YYCommentViewController];
}

@end

@interface YYCommentContainerViewController ()

@property (nonatomic, strong) YYCommentViewController *commentViewController;

@end

@implementation YYCommentContainerViewController
{
    BOOL _commentViewIsVisible;
    BOOL _observersRegistered;
    CGFloat _keyboardOverlap;
    UIView *_commentView;
}

@synthesize contentController;

- (id)initWithController:(UIViewController *)child
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.contentController = child;
        [self addChildViewController:child];
        [child didMoveToParentViewController:self];
    }

    if(child.wantsFullScreenLayout) {
        self.wantsFullScreenLayout = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    }

    self.commentViewController = [[YYCommentViewController alloc] initWithNibName:nil bundle:nil];
    [self.commentViewController setAssociatedObject:(id <NSObject,YYCommentNotifying>)child];
    return self;
}


- (YYCommentViewController *)YYCommentViewController
{
    YYCommentViewController *controller = self.commentViewController;
    if((__bridge void *)[self contentController] == (__bridge void *)[controller associatedObject])
        return controller;
    else
        return nil;
}

- (void)loadView
{
    CGRect r = [[UIScreen mainScreen] bounds];
    self.view = [[UIView alloc] initWithFrame: r];

    _commentView = [self.commentViewController view];
    [_commentView.layer setCornerRadius:8.0];
    [_commentView setAlpha:0.0];
    self.contentController.view.frame = r;

    [_commentView setBounds: CGRectMake(0.0, 0.0, r.size.width/2.0, r.size.height/4.0)];

    [self.view addSubview:self.contentController.view];
    
    UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleCommentViewVisibility:)];
    [self.view addGestureRecognizer:gr];
    
#if USE_AUTOLAYOUT
    [_commentView setTranslatesAutoresizingMaskIntoConstraints: NO];
#endif
}


- (void)adjustCommentViewFrame
{
    CGRect vb = [self.view bounds];
    CGFloat height = vb.size.height;
    CGFloat width = vb.size.width;
    CGRect r = _commentView.frame;
    r.origin.y = (height - _commentView.bounds.size.height);
    r.origin.x = (width - _commentView.bounds.size.width)/2.0;
    [_commentView setFrame: r];
}

- (void)adjustCommentViewYPosition:(CGFloat)yOffset duration:(CGFloat)duration completion: (void (^)(BOOL finished))block
{
    CGRect r = _commentView.frame;
    r.origin.y -= yOffset;
    [UIView animateWithDuration:duration animations:^{_commentView.frame = r;} completion: block];
}


- (NSString *)title
{
    return [self.contentController title];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.contentController supportedInterfaceOrientations];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)toggleCommentViewVisibility:(UIGestureRecognizer *)gr
{
    BOOL began = ([gr state] == UIGestureRecognizerStateBegan);
    if(!began) return;
    
    if(_commentViewIsVisible) {
        _commentViewIsVisible = NO;
        [self.commentViewController willMoveToParentViewController:nil];
        [self.commentViewController beginAppearanceTransition:NO animated:YES];
        [UIView animateWithDuration:.5 animations: ^{[_commentView setAlpha:0.0];} completion:^(BOOL finished) {
            // N.B. When we remove the superview we lose our constraints for that view.            
            [_commentView removeFromSuperview];
            [self.commentViewController endAppearanceTransition];
            [self.commentViewController removeFromParentViewController];
        }];
    }
    else {
        _commentViewIsVisible = YES;
        [self addChildViewController:self.commentViewController];
        [self.commentViewController beginAppearanceTransition:YES animated:YES];
        [self.view insertSubview:_commentView aboveSubview:self.contentController.view];
        
#if (!USE_AUTOLAYOUT)
        [self adjustCommentViewFrame];
#else
        [self.view setNeedsUpdateConstraints];
#endif
        
        [UIView animateWithDuration:.5 animations: ^{[_commentView setAlpha:1.0];} completion:^(BOOL finished) {
            [self.commentViewController endAppearanceTransition];
            [self.commentViewController didMoveToParentViewController:self];
        }];
        
    }
}

#if (!USE_AUTOLAYOUT && ENABLE_LAYOUT_SUBVIEWS)
- (void)viewWillLayoutSubviews
{
    if(_commentViewIsVisible) {
        [self adjustCommentViewFrame];
    }
}

#else

// If our content controller has been removed because of a memory warning we need to reinsert if we are appearing.
- (void)viewWillLayoutSubviews
{
    if (NO == [self.contentController isViewLoaded]) {
        if(_commentViewIsVisible) {
            [self.view insertSubview:[self.contentController view] belowSubview:_commentView];
        }
        else {
            [self.view addSubview:[self.contentController view]];
        }
    }
}
#endif


#if ENABLE_WILL_ROTATE_ADJUSTMENT
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(_commentViewIsVisible) {
        [self adjustCommentViewFrame];
    }
}
#endif

#if USE_AUTOLAYOUT
- (void)updateViewConstraints
{
    if(_commentViewIsVisible) {
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem: _commentView attribute: NSLayoutAttributeCenterX relatedBy: NSLayoutRelationEqual
                                                                          toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem: _commentView attribute: NSLayoutAttributeBottom relatedBy: NSLayoutRelationEqual
                                                                          toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];        
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem: _commentView attribute: NSLayoutAttributeWidth relatedBy: NSLayoutRelationEqual
                                                                          toItem:self.view attribute:NSLayoutAttributeWidth multiplier:.5 constant:0.0];

        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem: _commentView attribute: NSLayoutAttributeHeight relatedBy: NSLayoutRelationEqual
                                                                          toItem:self.view attribute:NSLayoutAttributeHeight multiplier:.25 constant:0.0];
        
        [self.view addConstraints: [NSArray arrayWithObjects:constraint1,constraint2,constraint3,constraint4,nil]];
    }
    [super updateViewConstraints]; 
}
#endif

- (void)viewWillAppear:(BOOL)animated
{
    [self.contentController beginAppearanceTransition:YES animated:animated];
    if(_commentViewIsVisible) {
        [self.commentViewController beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.contentController beginAppearanceTransition:NO animated:animated];
    if(_commentViewIsVisible) {
        [self.commentViewController beginAppearanceTransition:NO animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.contentController endAppearanceTransition];
    if(_commentViewIsVisible) {
        [self.commentViewController endAppearanceTransition];
    }
#if ENABLE_KEYBOARD_AVOIDANCE
    if(NO == _observersRegistered) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        _observersRegistered = YES;
    }
#endif
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.contentController endAppearanceTransition];
    if(_commentViewIsVisible) {
        [self.commentViewController endAppearanceTransition];
    }    
#if ENABLE_KEYBOARD_AVOIDANCE
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _observersRegistered = NO;
#endif
}

#if ENABLE_KEYBOARD_AVOIDANCE

- (void)_keyboardWillShow:(NSNotification *)notification
{
    // Gather some info about the keyboard and its animation
    CGRect keyboardEndFrame = CGRectZero;
    NSTimeInterval animationDuration = 0.0;
    [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView: nil];
    _keyboardOverlap = keyboardEndFrame.size.height;

    [self adjustCommentViewYPosition: _keyboardOverlap duration: animationDuration completion:nil];
}

- (void)_keyboardWillHide:(NSNotification *)notification
{
    // Gather some info about the keyboard and its animation
    NSTimeInterval animationDuration = 0.0;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [self adjustCommentViewYPosition: -1.0 *_keyboardOverlap duration:animationDuration completion:nil];
    _keyboardOverlap = 0;
}

#endif

@end
