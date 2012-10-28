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
    NSString *msg = [[NSString alloc] initWithFormat:@"Hello, %@",txtName.text];
    [lblMessage setText:msg];
    [msg release];
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
