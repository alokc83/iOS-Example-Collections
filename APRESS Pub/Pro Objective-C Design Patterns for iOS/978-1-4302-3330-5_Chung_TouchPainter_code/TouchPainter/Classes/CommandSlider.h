//
//  CommandSlider.h
//  TouchPainter
//
//  Created by Carlo Chung on 11/9/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Command.h"

@interface CommandSlider : UISlider
{
  @protected
  Command *command_;
}

@property (nonatomic, retain) IBOutlet Command *command;

@end
