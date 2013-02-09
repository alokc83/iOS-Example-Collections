//
//  CustomBarButton.h
//  TouchPainter
//
//  Created by Carlo Chung on 10/19/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  "Command.h"

@interface CommandBarButton : UIBarButtonItem
{
  @protected
  Command *command_;
}

@property (nonatomic, retain) IBOutlet Command *command;

@end

