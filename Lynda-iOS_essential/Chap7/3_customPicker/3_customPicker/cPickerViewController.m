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

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
   
    // MiAddition
    //NSString *selectedMood;
    
    UIColor *newColor;
    switch (row) {
        case 0: case 2: case 4:
            newColor = [UIColor yellowColor];
            break;
        case 1: case 3: case 5:
            newColor = [UIColor grayColor];
            break;
        case 6: case 7: case 8:
            newColor = [UIColor blackColor];
        default:
            newColor = [UIColor redColor];
            break;
    }
    self.view.backgroundColor = newColor; 
    
    //my addition to the program
    
    // MiAddition of program
    /* switch (row) {
         case 0: 
             selectedMood = @"Ecstatic";
             [lblMood setText:selectedMood];
             break;
         case 1:
             selectedMood = @"Happy";
             [lblMood setText:selectedMood];
             break;
         case 2:
             selectedMood = @"Excited";
             [lblMood setText:selectedMood];
             break;
         case 3:
             selectedMood = @"Cheerful";
             [lblMood setText:selectedMood];
             break;
         case 4:
             selectedMood = @"Fine";
             [lblMood setText:selectedMood];
             break;
         case 5:
             selectedMood = @"Tired";
             [lblMood setText:selectedMood];
             break;
         case 6:
             selectedMood = @"Maudlin";
             [lblMood setText:selectedMood];
             break;
         case 7:
             selectedMood = @"Depressed";
             [lblMood setText:selectedMood];
             break;
         case 8:
             selectedMood = @"Overwhelmed";
             [lblMood setText:selectedMood];
             break;
         default:
             selectedMood = @"Default Mood";
             [lblMood setText:selectedMood];
             break;
     } */
     
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
