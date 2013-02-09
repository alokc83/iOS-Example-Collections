//
//  ViewController.m
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import "ViewController.h"
#import "SquareRootBatch.h"

#define kTimerInterval (1.0/60.0)
#define kBatchSize     10

@interface ViewController ()
@property (assign, nonatomic) BOOL processRunning;
@end

@implementation ViewController
@synthesize numberOfOperations;
@synthesize progressBar;
@synthesize progressLabel;
@synthesize goStopButton;

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
    if (!self.processRunning) {
        NSInteger operationCount = [numberOfOperations.text integerValue];
        SquareRootBatch *batch = [[SquareRootBatch alloc] initWithMaxNumber:operationCount];
        
        [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(processChunk:) userInfo:batch repeats:YES];
        [goStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.processRunning = YES;
    }
    else {
        self.processRunning = NO;
        [goStopButton setTitle:@"Go" forState:UIControlStateNormal];
    }
}

- (void)processChunk:(NSTimer *)timer
{
    if (!self.processRunning) {
        // Cancelled
        [timer invalidate];
        progressLabel.text = @"Calculations Cancelled";
        return;
    }
    
    SquareRootBatch *batch = (SquareRootBatch *)[timer userInfo];
    NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate] + (kTimerInterval / 2.0);
    
    BOOL isDone = NO;
    while (([NSDate timeIntervalSinceReferenceDate] < endTime) && !isDone) {
        for (int i = 0; i < kBatchSize; i++) {
            if (![batch hasNext]) {
                isDone = YES;
                i = kBatchSize;
            }
            else {
                NSInteger current = batch.current;
                double nextSquareRoot = [batch next];
                NSLog(@"Calculated square root of %d as %.6f", current, nextSquareRoot);
            }
        }
    }
    progressLabel.text = [batch percentCompletedText];
    progressBar.progress = [batch percentCompleted];
    
    if (isDone) {
        [timer invalidate];
        self.processRunning = NO;
        progressLabel.text = @"Calculations Finished";
        [goStopButton setTitle:@"Go" forState:UIControlStateNormal];
    }
}

@end
