//
//  RandomNumberViewController.h
//  RandomNumber
//
//  Created by Gary Bennett on 7/2/10.
//  Copyright xcelme.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RandomNumberViewController : UIViewController {

	IBOutlet UILabel *randNumber; //instance variable
	
}
- (IBAction)seed:(id)sender;
- (IBAction)generate:(id)sender;


@property (retain,nonatomic) UILabel *randNumber; //getter and setter methods

@end