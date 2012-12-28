//
//  quizViewController.m
//  Quiz
//
//  Created by Katie on 12/27/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "quizViewController.h"

@interface quizViewController ()

@end

@implementation quizViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //call the init with method implemented by the superclass
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        //Create two array and make the pointers point to them
        questions = [[NSMutableArray alloc] init];
        answers = [[NSMutableArray alloc] init];
        
        //Add questions and answers to arrays
        [questions addObject:@"What is 7 + 7"];
        [answers addObject:@"14"];
        
        [questions addObject:@"What is 6 + 4"];
        [answers addObject:@"10"];
        
        [questions addObject:@"What is Captial of India"];
        [answers addObject:@"New Delhi"];
        
        [questions addObject:@"Who is the Creator of world in Hindu Mythology"];
        [answers addObject:@"Brahma"];
    }
    
    //Return the address of the new object
    return self;
    
}

- (IBAction)showQuestion:(id)sender
{
    //Step to the next question
    currentQuestionIndex++;
    
    //Am I past the last question?
    if(currentQuestionIndex == [questions count])
    {
        //Go back to the first Question
        currentQuestionIndex = 0;
    }
    
    //get he string at that index in the question array
    
    NSString *question = [questions objectAtIndex:currentQuestionIndex];
    
    //Log the string to the console
    NSLog(@"Displaying the Question: %@",questions);
    
    //Display the string in the question field
    [questionField setText:question];
    
    //Clear the answer field
    [answerField setText:@"????????"];
    
}


- (IBAction)showAnswer:(id)sender
{
    //What is the answer of current question ?
    NSString *answer = [answers objectAtIndex:currentQuestionIndex];
    
    //Display it in the answerfield
    [answerField setText:answer];
    
    
}

/* COMMENTED AS BIG NERD SAYS THAT WE HAVE TO START PRACTICING TAKING CARE OF EVERYTHING BY OUTSELF
 
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 
 */
@end
