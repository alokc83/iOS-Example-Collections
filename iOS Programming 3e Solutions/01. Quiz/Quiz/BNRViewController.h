//
//  BNRViewController.h
//  Quiz
//
//  Created by Michael Ward on 5/9/12.
//  Copyright (c) 2012 Big Nerd Ranch, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRViewController : UIViewController 
{
    int currentQuestionIndex;
    
    // The model objects
    NSMutableArray *questions;
    NSMutableArray *answers;
    
    // The view objects
    IBOutlet UILabel *questionField;
    IBOutlet UILabel *answerField;
}

// Actions for the buttons to invoke
- (IBAction)showQuestion:(id)sender;
- (IBAction)showAnswer:(id)sender;

@end
