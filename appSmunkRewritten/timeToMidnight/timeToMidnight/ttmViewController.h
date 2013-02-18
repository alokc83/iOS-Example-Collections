//
//  ttmViewController.h
//  timeToMidnight
//
//  Created by Alix Cewall on 11/13/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ttmViewController : UIViewController
{
    NSTimer *timer;
    
}
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

- (void)updateLabel;

@end
