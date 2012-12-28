//
//  quizViewController.h
//  Quiz
//
//  Created by Katie on 12/27/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface quizViewController : UIViewController{
    int currentQuestionIndex;
    
    //The Model Object
    NSMutableArray *questions;
    NSMutableArray *answers;
    
    //the view object
    IBOutlet UILabel *questionField;
    IBOutlet UILabel *answerField;
    
}

- (IBAction)showQuestion:(id)sender;
- (IBAction)showAnswer:(id)sender;


@end
