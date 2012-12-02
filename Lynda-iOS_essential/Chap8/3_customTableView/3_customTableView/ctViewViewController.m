//
//  ctViewViewController.m
//  3_customTableView
//
//  Created by Alix Cewall on 11/15/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "ctViewViewController.h"

@interface ctViewViewController ()

@end

@implementation ctViewViewController

//AL

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section ==0) return @"Chest";
    if (section ==1) return @"Shoulder";
    if (section ==2) return @"Back";
    if (section ==3) return @"Abs";
    if (section ==4) return @"Legs";
    if (section ==5) return @"Arms";
    return @"Others";
}

//
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return 6;
    if(section == 1) return 3;
    if(section == 2) return 6;
    if(section == 3) return 3;
    if(section == 4) return 8;
    if(section == 5) return 6;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    //create a cell
    if( nil == cell )
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    // determin the correct row
    //it will be restarted from 0 everytime as as we are jsut loading in from
    //one array, we need to offset it by the right amount depending on the secion
    int theRow = indexPath.row;
    if (indexPath.section == 1 ) theRow += 6;
    if (indexPath.section == 2 ) theRow += 9;
    if (indexPath.section == 3 ) theRow += 15;
    if (indexPath.section == 4 ) theRow += 18;
    if (indexPath.section == 5 ) theRow += 26;
   
    //Fill it with contents
    cell.textLabel.text = [execrises objectAtIndex:theRow];
    
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
