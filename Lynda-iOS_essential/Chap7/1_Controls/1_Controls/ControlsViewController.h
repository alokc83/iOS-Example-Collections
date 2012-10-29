//
//  ControlsViewController.h
//  1_Controls
//
//  Created by Alix Cewall on 10/28/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ControlsViewController : UIViewController {
    IBOutlet UISegmentedControl *colorChooser;
    IBOutlet UITextView *sampleText;
    
}

@property (nonatomic, retain) UISegmentedControl *colorChooser;
@property (nonatomic, retain) UITextView *sampleText;

- (IBAction) colorChanged; 

@end
