//
//  FlyweightView.m
//  Flyweight
//
//  Created by Carlo Chung on 11/29/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "FlyweightView.h"
#import "ExtrinsicFlowerState.h"

@implementation FlyweightView

@synthesize flowerList=flowerList_;

extern NSString *FlowerObjectKey, *FlowerLocationKey;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
  // Drawing code
  
  for (NSValue *stateValue in flowerList_)
  {
    ExtrinsicFlowerState state;
    [stateValue getValue:&state];
    
    UIView *flowerView = state.flowerView;
    CGRect area = state.area;
    
    [flowerView drawRect:area];
  }
}


- (void)dealloc 
{
  [flowerList_ release];
  [super dealloc];
}


@end
