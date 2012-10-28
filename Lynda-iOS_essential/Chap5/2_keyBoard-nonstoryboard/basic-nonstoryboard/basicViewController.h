//
//  basicViewController.h
//  basic-nonstoryboard
//
//  Created by Alix Cewall on 10/27/12.
//  Copyright (c) 2012 AC. All rights reserved.

// making keyboard go away when we are done with it

#import <UIKit/UIKit.h>

@interface basicViewController : UIViewController {
    IBOutlet UITextField *txtName;
    IBOutlet UILabel *lblMessage;
}

@property (nonatomic, retain) IBOutlet UITextField *txtName;
@property (nonatomic, retain) IBOutlet UILabel *lblMessage;

- (IBAction) printMessage;
- (IBAction) dismissKeyBoard;

@end
