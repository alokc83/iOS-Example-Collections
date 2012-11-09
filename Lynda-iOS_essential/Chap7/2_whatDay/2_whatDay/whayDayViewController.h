//
//  whayDayViewController.h
//  2_whatDay
//
//  Created by Alix Cewall on 11/8/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface whayDayViewController : UIViewController {
    IBOutlet UIDatePicker *dp;
}

@property (nonatomic, retain) UIDatePicker *dp;

- (IBAction) displayDay ;

@end
