//
//  UIColor+Extract.h
//  TouchTracker
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extract)
- (void)extract_getRed:(float *)r green:(float *)g blue:(float *)b;
- (UIColor *)extract_invertedColor;
@end