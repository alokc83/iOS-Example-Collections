//
//  PowerViewController.m
//  SuperDB
//
//  Created by Kevin Y. Kim on 1/23/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import "PowerViewController.h"
#import "ManagedObjectConfiguration.h"

@interface PowerViewController ()

@end

@implementation PowerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.config = [[ManagedObjectConfiguration alloc] initWithResource:@"PowerViewConfiguration"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
