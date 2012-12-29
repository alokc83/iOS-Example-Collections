//
//  MSMasterViewController.h
//  MeetSocial
//
//  Created by Bear Cahill on 7/21/12.
//  Copyright (c) 2012 BrainwashInc.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSMasterViewController : UIViewController <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UISegmentedControl *segSearchZipOrKeyword;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segSearchGroupsOrEvents;
@property (retain, nonatomic) IBOutlet UITextField *tfSearchText;

@end
