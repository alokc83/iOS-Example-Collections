//
//  ViewController.h
//  MessageImage
//
//  Created by Kevin Y. Kim on 10/2/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) UIImage *image;

- (IBAction)selectAndMessageImage:(id)sender;
- (void)showActivityViewController;

@end
