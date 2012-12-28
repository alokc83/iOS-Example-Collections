//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Line;
@interface TouchDrawView : UIView 
    <UIGestureRecognizerDelegate>
{
    NSMutableDictionary *linesInProcess;
    NSMutableArray *completeLines;
    UIPanGestureRecognizer *moveRecognizer;
}
- (void)clearAll;
- (void)endTouches:(NSSet *)touches;

- (Line *)lineAtPoint:(CGPoint)p;
@property (nonatomic, weak) Line *selectedLine;

@end
