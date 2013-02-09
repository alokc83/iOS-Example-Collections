//
//  MarkEnumerator+Private.h
//  TouchPainter
//
//  Created by Carlo Chung on 1/6/11.
//  Copyright 2011 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MarkEnumerator ()

- (id) initWithMark:(id <Mark>)mark;
- (void) traverseAndBuildStackWithMark:(id <Mark>)mark;

@end
