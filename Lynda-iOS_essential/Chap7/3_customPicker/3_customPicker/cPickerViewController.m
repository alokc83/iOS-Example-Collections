//
//  cPickerViewController.m
//  3_customPicker
//
//  Created by Alix Cewall on 11/13/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import "cPickerViewController.h"

@interface cPickerViewController ()

@end

@implementation cPickerViewController

//Method for UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return moods.count;
}


//method for UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    return [moods objectAtIndex:row];
}

- (void)viewDidLoad
{
    
    moods = [[NSArray alloc] initWithObjects:@"Ecstatic",@"Happy",@"Excited",@"Cheerful",@"Fine",
             @"Tired",@"Maudlin",@"Depressed",@"Overwhelmed", nil];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
