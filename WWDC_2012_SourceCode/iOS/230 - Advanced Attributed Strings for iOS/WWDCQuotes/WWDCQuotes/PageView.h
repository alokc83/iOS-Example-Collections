//
//  PageView.h
//  WWDCQuotes
//
//  Created by Johannes Fortmann on 6/5/12.
//  Copyright (c) 2012 Johannes Fortmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Page.h"

@interface PageView : UIImageView

@property (weak, nonatomic) Page *page;
@property (assign, nonatomic) BOOL unstyledDrawing;
@property (assign, nonatomic) float lineHeight;

+ (UIImage *)renderPagePreview:(Page *)page withSize:(CGSize)size;
- (void)selectParagraphAtPosition:(CGPoint)position showMenu:(BOOL)shouldShowMenu;
@end
