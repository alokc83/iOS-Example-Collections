//
//  ViewController.m
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (assign, nonatomic) NSInteger cancelledIndex;
@end

@implementation ViewController
@synthesize numberOfOperations;
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue addObserver:self forKeyPath:@"operations" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    self.cancelledIndex = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)go:(id)sender
{
    NSInteger operationCount = [numberOfOperations.text integerValue];
    SquareRootOperation *newOperation = [[SquareRootOperation alloc] initWithMaxNumber:operationCount delegate:self];
    [self.queue addOperation:newOperation];
}

- (IBAction)backgroundTap:(id)sender
{
    [self.numberOfOperations resignFirstResponder];
}

- (IBAction)cancelOperation:(id)sender
{
    self.cancelledIndex = [sender tag];
    NSOperation *operation = [[self.queue operations] objectAtIndex:self.cancelledIndex];
    [operation cancel];
    if (![operation isExecuting])
        [self.tableView reloadData];
}

#pragma mark - Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    if (nil == [self.queue operations])
        NSLog(@"NIL QUEUE OPERATIONS");
    else
        NSLog(@"%d", [[self.queue operations] count]);
    
    return [[self.queue operations] count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"OperationQueueCell";
    ProgressCell *cell = [theTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ProgressCell" owner:self options:nil];
        cell = (ProgressCell *)self.progressCell;
        self.progressCell = nil;
    }
    SquareRootOperation *rowOp = (SquareRootOperation *)[[self.queue operations] objectAtIndex:[indexPath row]];
    UIProgressView *progressView = cell.progressBar;
    progressView.progress = [rowOp percentComplete];
    
    UILabel *progressLabel = cell.progressLabel;
    progressLabel.text = [rowOp progressString];
    cell.accessoryView.tag = [indexPath row];
    
    return cell;
}

#pragma mark  - SquareRootOperation Delegate Method

- (void)operationProgressChanged:(SquareRootOperation *)op {
    NSUInteger opIndex = [[self.queue operations] indexOfObject:op];
    NSUInteger reloadIndices[] = {0, opIndex};
    NSIndexPath *reloadIndexPath = [NSIndexPath indexPathWithIndexes:reloadIndices length:2];
    ProgressCell *cell = (ProgressCell *)[tableView cellForRowAtIndexPath:reloadIndexPath];
    if (cell) {
        UIProgressView *progressView = cell.progressBar;
        progressView.progress = [op percentComplete];
        UILabel *progressLabel = cell.progressLabel;
        progressLabel.text = [op progressString];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

#pragma mark - KVO method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
    NSArray *old = (NSArray *)[change objectForKey:NSKeyValueChangeOldKey];
    NSArray *new = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
    
    if ([kind integerValue] == NSKeyValueChangeSetting) {
        [self.tableView beginUpdates];
        if ([old count] < [new count]) {
            NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:([new count]-1) inSection:0]];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        else if ([old count] > [new count]) {
            NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.cancelledIndex inSection:0]];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            self.cancelledIndex = -1;
        }
        [self.tableView endUpdates];
    }
}

@end
