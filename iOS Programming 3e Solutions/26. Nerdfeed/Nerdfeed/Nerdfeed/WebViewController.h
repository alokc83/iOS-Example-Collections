//
//  WebViewController.h
//  Nerdfeed
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListViewController.h"

@interface WebViewController : UIViewController <ListViewControllerDelegate, UISplitViewControllerDelegate>
@property (nonatomic, readonly) UIWebView *webView;
@end
