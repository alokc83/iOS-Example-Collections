//
//  Min2MidnightViewController.h
//  MinutesToMidnight
//
//  Created by Katie on 2/18/13.
//  Copyright (c) 2013 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Min2MidnightViewController : UIViewController
{
NSTimer *timer;

}

@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

-(void)onTimer;

- (void) updateLabel;

@end
