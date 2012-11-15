//
//  tViewViewController.h
//  1_tableView
//
//  Created by Alix Cewall on 11/14/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tViewViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    
    NSArray *execrises; 
}

@end
