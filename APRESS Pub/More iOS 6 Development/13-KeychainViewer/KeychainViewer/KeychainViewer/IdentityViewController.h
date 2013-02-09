//
//  IdentityViewController.h
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "KeychainItemViewController.h"

@interface IdentityViewController : KeychainItemViewController

@property (weak, nonatomic) IBOutlet UIButton *cryptButton;
- (IBAction)crypt:(id)sender;

@end
