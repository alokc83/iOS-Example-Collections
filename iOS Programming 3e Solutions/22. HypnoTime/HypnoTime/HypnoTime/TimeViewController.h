//
//  TimeViewController.h
//  HypnoTime
//
//  Created by joeconway on 8/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeViewController : UIViewController
{
    IBOutlet UILabel __weak *timeLabel;
}

- (IBAction)showCurrentTime:(id)sender;

@end
