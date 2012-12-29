//
//  HWViewController.h
//  HelloWorld
//
//  Created by Bear Cahill on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblHelloWorld;
- (IBAction)doBtnHide:(id)sender;
@end
