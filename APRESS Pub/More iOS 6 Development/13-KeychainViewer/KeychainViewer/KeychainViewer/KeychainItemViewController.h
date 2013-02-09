//
//  KeychainItemViewController.h
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeychainItem;

@interface KeychainItemViewController : UIViewController

@property (strong, nonatomic) KeychainItem *item;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)done:(id)sender;

@end
