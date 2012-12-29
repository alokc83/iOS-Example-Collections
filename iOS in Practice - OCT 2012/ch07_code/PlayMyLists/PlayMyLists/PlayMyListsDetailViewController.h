//
//  PlayMyListsDetailViewController.h
//  PlayMyLists
//
//  Created by Bear Cahill on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayMyListsDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
