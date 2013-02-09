//
//  DecoratorView.h
//  Decorator
//
//  Created by Carlo Chung on 1/25/11.
//  Copyright 2011 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DecoratorView : UIView 
{
  @private
  UIImage *image_;
}

@property (nonatomic, retain) UIImage *image;

@end
