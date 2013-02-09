//
//  ScribbleThumbnailProxy.h
//  TouchPainter
//
//  Created by Carlo Chung on 10/3/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScribbleThumbnailView.h"
#import "Command.h"

@interface ScribbleThumbnailViewImageProxy : ScribbleThumbnailView
{
  @private
  Scribble *scribble_;
  Command *touchCommand_;
  UIImage *realImage_;
  BOOL loadingThreadHasLaunched_;  
}

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) Scribble *scribble;
@property (nonatomic, retain) Command *touchCommand;

@end
