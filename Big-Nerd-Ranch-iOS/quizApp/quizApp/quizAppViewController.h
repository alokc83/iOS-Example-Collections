//
//  quizAppViewController.h
//  quizApp
//
//  Created by Katie on 12/24/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface quizAppViewController : UIViewController <UIApplicationDelegate>{
    int currentQuestionIndex;
    //model objects
    NSMutableArray *questions;
    NSMutableArray *answers;
    
    //View Objects
    IBOutlet UILabel *questionField;
    IBOutlet UILabel *answerField;
    
}


- (IBAction)showQuestion:(id)sender;
- (IBAction)showAnswer:(id)sender;

@end
