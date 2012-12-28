//
//  BNRViewController.m
//  Quiz
//
//  Created by Michael Ward on 5/9/12.
//  Copyright (c) 2012 Big Nerd Ranch, Inc. All rights reserved.
//

#import "BNRViewController.h"

@implementation BNRViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Create two arrays and make the pointers point to them
        questions = [NSMutableArray array];
        answers = [NSMutableArray array];
        
        // Add questions and answers to the arrays
        [questions addObject:@"From what is cognac made?"];
        [answers addObject:@"Grapes"];
        
        [questions addObject:@"What is 7 + 7?"];
        [answers addObject:@"14"];
        
        [questions addObject:@"What is the capital of Vermont?"];
        [answers addObject:@"Montpelier"];
        
    }
    return self;
}

- (IBAction)showQuestion:(id)sender 
{
    // Step to the next question
    currentQuestionIndex++;
    
    // Am I past the last question?
    if (currentQuestionIndex == [questions count]) {
        // If so, go back to the first question
        currentQuestionIndex = 0;
    }
    
    // Get the string in the current index of the questions array
    NSString *question = [questions objectAtIndex:currentQuestionIndex];
    
    // Output the question string to the debug console
    NSLog(@"Displaying question: %@",question);
    
    // Display the string in the question text field
    [questionField setText:question];
    
    // Clear the answer text field
    [answerField setText:@"???"];
}

- (IBAction)showAnswer:(id)sender 
{
    // Get the string in the current index of the answers array
    NSString *answer = [answers objectAtIndex:currentQuestionIndex];
    
    // Display the answer string in the answer text field
    [answerField setText:answer];
}
@end
