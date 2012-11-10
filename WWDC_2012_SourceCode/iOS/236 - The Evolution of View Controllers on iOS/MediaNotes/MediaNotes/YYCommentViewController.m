
/*
     File: YYCommentViewController.m
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

#import <UIKit/UIImagePickerController.h>
#import "YYCommentViewController.h"


@interface YYCommentViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *shareButton;

- (IBAction)enableTextEditing;
- (IBAction)share;
- (IBAction)shootPicture;

- (void)setEditing:(BOOL)flag;

@end


@implementation YYCommentViewController
{
    BOOL _toolbarIsVisible;
    UIPopoverController *_shareController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _toolbarIsVisible  = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textView setBackgroundColor: [UIColor colorWithWhite: .25 alpha: .75]];
    [self.textView setTextColor: [UIColor whiteColor]];
    [self setEditing:NO];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
}

- (NSString *)comment
{
    return [self.associatedObject associatedComment];
}

- (void)setComment:(NSString *)comment
{
    [self.associatedObject associatedCommentDidChange:comment];
}

- (void)toggleToolbar:(UIGestureRecognizer *)gr
{
    [self showToolbar: !_toolbarIsVisible animated: YES duration: .5];
}

- (void)setEditing:(BOOL)flag
{
    [self.textView setEditable:flag];
}

// Delegate and callback methods
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@:%s",self,(char *)_cmd);
    [self.textView setText: [self comment]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@:%s",self,(char *)_cmd);
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@:%s",self,(char *)_cmd);
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@:%s",self,(char *)_cmd);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)textViewDidEndEditing:(UITextView *)tv
{
    if (![self.comment isEqualToString: [tv text]]) {
        [self setComment:[tv text]];
    }
    [self setEditing:NO];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _shareController = nil;
}


// YYCommentViewController API
- (void)showToolbar:(BOOL)show animated:(BOOL)animated duration:(CGFloat)duration
{
    [UIView animateWithDuration: .5 animations: ^{[self.toolbar setAlpha: show ? 1.0 : 0.0];} completion: ^(BOOL finished) {
        if(show) {
            [self.view addSubview: self.toolbar];
            _toolbarIsVisible = YES;
        }
        else {
            [self.toolbar removeFromSuperview];
            _toolbarIsVisible = NO;
        }
    }];
}


- (void)associatedObjectDidChange:(id <NSObject,YYCommentNotifying>)object
{
    if(object != self.associatedObject)
        self.associatedObject = object;
    [self.textView setText: [object associatedComment]];
}

- (IBAction)enableTextEditing
{
    if([self.textView isEditable]) {
        [self setEditing:NO];
        [self.textView resignFirstResponder];
    }
    else {
        [self setEditing: YES];
        [self.textView becomeFirstResponder];
    }
}

- (IBAction)share
{
    if(nil == _shareController) {
        NSMutableArray *itemsForSharing = nil;
        NSArray *items = [self.associatedObject itemsForSharing];
        if(items) {
            itemsForSharing = [NSMutableArray arrayWithArray:items];
            [itemsForSharing addObject: [self comment]];
        }
        else {
            itemsForSharing = [NSMutableArray arrayWithObject: [self comment]];
        }
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:itemsForSharing applicationActivities:nil];

        _shareController = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [_shareController setDelegate:self];
        [_shareController presentPopoverFromBarButtonItem:self.shareButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {

        [_shareController dismissPopoverAnimated:YES];
        _shareController = nil;        
    }
}

- (IBAction)shootPicture
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}


@end
