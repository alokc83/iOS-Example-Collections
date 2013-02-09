//
//  ScribbleThumbnailCell.h
//  TouchPainter
//
//  Created by Carlo Chung on 10/18/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScribbleThumbnailView.h"

@interface ScribbleThumbnailCell : UITableViewCell 
{
	
}

+ (NSInteger) numberOfPlaceHolders;
- (void) addThumbnailView:(UIView *)thumbnailView 
                      atIndex:(NSInteger)index;

@end
