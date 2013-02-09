//
//  DetailViewController.h
//  DebugTest
//
//  Created by Kevin Y. Kim on 9/25/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
