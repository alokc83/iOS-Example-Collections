//
//  ScribbleSource.h
//  TouchPainter
//
//  Created by Carlo Chung on 11/9/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scribble.h"

@protocol ScribbleSource

- (Scribble *) scribble;

@end
