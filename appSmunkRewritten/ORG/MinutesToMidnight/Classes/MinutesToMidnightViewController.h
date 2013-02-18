//
//  MinutesToMidnightViewController.h
//  MinutesToMidnight
//
//  Created by apple on 10/1/08.
//  Copyright Amuck LLC 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MinutesToMidnightViewController : UIViewController {
    IBOutlet UILabel *countdownLabel;
}
-(void)updateLabel;
@end

