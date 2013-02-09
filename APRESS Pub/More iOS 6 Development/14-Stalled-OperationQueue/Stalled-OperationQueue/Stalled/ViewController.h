//
//  ViewController.h
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SquareRootOperation.h"
#import "ProgressCell.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SquareRootOperationDelegate>

@property (weak, nonatomic) IBOutlet UITextField *numberOfOperations;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) IBOutlet ProgressCell *progressCell;


- (IBAction)go:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)cancelOperation:(id)sender;

@end
