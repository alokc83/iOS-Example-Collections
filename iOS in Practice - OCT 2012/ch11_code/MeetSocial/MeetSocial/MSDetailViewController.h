//
//  MSDetailViewController.h
//  MeetSocial
//
//  Created by Bear Cahill on 7/21/12.
//  Copyright (c) 2012 BrainwashInc.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface MSDetailViewController : UICollectionViewController <EKEventEditViewDelegate, UIViewControllerRestoration, UIDataSourceModelAssociation>


@end
