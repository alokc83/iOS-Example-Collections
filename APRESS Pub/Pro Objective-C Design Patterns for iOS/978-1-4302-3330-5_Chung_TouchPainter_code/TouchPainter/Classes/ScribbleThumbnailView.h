//
//  ScribbleThumbnail.h
//  TouchPainter
//
//  Created by Carlo Chung on 10/18/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scribble.h"
#import "ScribbleSource.h"

@interface ScribbleThumbnailView : UIView <ScribbleSource> 
{
  @protected
  NSString *imagePath_;
  NSString *scribblePath_;
}

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) Scribble *scribble;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, copy) NSString *scribblePath;

@end
