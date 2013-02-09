//
//  SuperDBEditCell.h
//  SuperDB
//
//  Created by Kevin Y. Kim on 1/22/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperDBCell.h"

@interface SuperDBEditCell : SuperDBCell <UITextFieldDelegate, UIAlertViewDelegate>

- (IBAction)validate;

@end
