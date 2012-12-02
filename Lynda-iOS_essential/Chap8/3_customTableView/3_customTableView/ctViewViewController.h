//
//  ctViewViewController.h
//  3_customTableView
//
//  Created by Alix Cewall on 11/15/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ctViewViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    
    NSArray *execrises;
}
@end
