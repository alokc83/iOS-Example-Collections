//
//  tViewViewController.m
//  1_tableView
//
//  Created by Alix Cewall on 11/14/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "tViewViewController.h"

@interface tViewViewController ()

@end

@implementation tViewViewController

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return execrises.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Create Cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    //Fill it with contents
    cell.textLabel.text = [execrises objectAtIndex:indexPath.row];
    
    //return it
    return cell;
}

- (void)viewDidLoad
{
    //Load from plist file
    
    NSString *myfile = [[NSBundle mainBundle] pathForResource:@"execrise" ofType:@"plist"];
    execrises = [[NSArray alloc] initWithContentsOfFile:myfile];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
