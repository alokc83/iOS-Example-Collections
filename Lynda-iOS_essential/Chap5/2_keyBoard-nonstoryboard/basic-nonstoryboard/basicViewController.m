//
//  basicViewController.m
//  basic-nonstoryboard
//
//  Created by Alix Cewall on 10/27/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "basicViewController.h"

@interface basicViewController ()
@end



@implementation basicViewController

@synthesize txtName;
@synthesize lblMessage;


- (IBAction) printMessage
{
//[comment] As you are clicking text field, Text field is first responder, so eaisest way to
//resign as first responder. Next statment do that only.
    [txtName resignFirstResponder];
    
    NSString *msg = [[NSString alloc] initWithFormat:@"Hello, %@",txtName.text];
    [lblMessage setText:msg];
    [msg release];
}

//[comment] fucntion which dismiss the keyboard
- (IBAction) dismissKeyBoard
{
    [txtName resignFirstResponder];
}

//[comment] function that dismiss the keyboard when press return key
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txtName resignFirstResponder];
    return YES;
}

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

@end
