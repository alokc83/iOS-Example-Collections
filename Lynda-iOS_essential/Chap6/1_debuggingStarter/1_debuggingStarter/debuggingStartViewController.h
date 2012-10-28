//
//  debuggingStartViewController.h
//  1_debuggingStarter
//
//  Created by Alix Cewall on 10/28/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface debuggingStartViewController : UIViewController
{
    IBOutlet UILabel *myLabel;
}

@property (nonatomic, retain) UILabel *myLabel;

- (IBAction) setLabel;

@end
