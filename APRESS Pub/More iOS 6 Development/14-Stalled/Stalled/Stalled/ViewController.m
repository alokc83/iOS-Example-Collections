//
//  ViewController.m
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize numberOfOperations;
@synthesize progressBar;
@synthesize progressLabel;

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

- (IBAction)go:(id)sender
{
    NSInteger operationCount = [self.numberOfOperations.text integerValue];
    for (NSInteger i = 0; i <= operationCount; i++) {
        NSLog(@"Calculating Square Root of %d", i);
        double squareRootOfI = sqrt((double)i);
        self.progressBar.progress = ((float)i / (float)operationCount);
        self.progressLabel.text = [NSString stringWithFormat:@"Square Root of %d is %.6f", i, squareRootOfI];
    }
}

@end
