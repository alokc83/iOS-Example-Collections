//
//  cPickerViewController.h
//  3_customPicker
//
//  Created by Alix Cewall on 11/13/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cPickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    
    IBOutlet UIPickerView *moodPicker;
}

@end
