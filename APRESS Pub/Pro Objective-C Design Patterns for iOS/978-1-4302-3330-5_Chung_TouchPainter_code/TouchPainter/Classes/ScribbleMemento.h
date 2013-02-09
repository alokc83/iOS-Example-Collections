//
//  ScirbbleMemento.h
//  TouchPainter
//
//  Created by Carlo Chung on 9/27/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mark.h"


@interface ScribbleMemento : NSObject
{
  @private
  id <Mark> mark_;
  BOOL hasCompleteSnapshot_;
}

+ (ScribbleMemento *) mementoWithData:(NSData *)data;
- (NSData *) data;

@end
