//
//  ScribblesViewController.h
//  TouchPainter
//
//  Created by Carlo Chung on 10/18/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScribbleThumbnailCell.h"
#import "ScribbleManager.h"
#import "CommandBarButton.h"

@interface ThumbnailViewController : UIViewController 
										<UITableViewDelegate,
										 UITableViewDataSource>

{
	@private
	IBOutlet UINavigationItem *navItem_;
	ScribbleManager *scribbleManager_;
}

@end
