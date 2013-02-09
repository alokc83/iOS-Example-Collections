//
//  StrategyViewController.h
//  Strategy
//
//  Created by Carlo Chung on 8/2/10.
//  Copyright Carlo Chung 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumericInputValidator.h"
#import "AlphaInputValidator.h"
#import "CustomTextField.h"

@interface StrategyViewController : UIViewController <UITextFieldDelegate> 
{
  @private
  CustomTextField *numericTextField_;
  CustomTextField *alphaTextField_;
}

@property (nonatomic, retain) IBOutlet CustomTextField *numericTextField;
@property (nonatomic, retain) IBOutlet CustomTextField *alphaTextField;

@end

