//
//  ProgressCell.h
//  Stalled
//
//  Created by Kevin Y. Kim on 7/30/12.
//  Copyright (c) 2012 AppOrchard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end
