//
//  FlowerFactory.m
//  Flyweight
//
//  Created by Carlo Chung on 11/29/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "FlowerFactory.h"
#import "FlowerView.h"

@implementation FlowerFactory


- (UIView *) flowerViewWithType:(FlowerType)type
{
  // lazy-load a flower pool
  if (flowerPool_ == nil)
  {
    flowerPool_ = [[NSMutableDictionary alloc] 
                   initWithCapacity:kTotalNumberOfFlowerTypes];
  }
  
  // try to retrieve a flower
  // from the pool
  UIView *flowerView = [flowerPool_ objectForKey:[NSNumber 
                                                  numberWithInt:type]];
  
  // if the type requested
  // is not available then
  // create a new one and
  // add it to the pool
  if (flowerView == nil)
  {
    UIImage *flowerImage;
    
    switch (type) 
    {
      case kAnemone:
        flowerImage = [UIImage imageNamed:@"anemone.png"];
        break;
      case kCosmos:
        flowerImage = [UIImage imageNamed:@"cosmos.png"];
        break;
      case kGerberas:
        flowerImage = [UIImage imageNamed:@"gerberas.png"];
        break;
      case kHollyhock:
        flowerImage = [UIImage imageNamed:@"hollyhock.png"];
        break;
      case kJasmine:
        flowerImage = [UIImage imageNamed:@"jasmine.png"];
        break;
      case kZinnia:
        flowerImage = [UIImage imageNamed:@"zinnia.png"];
        break;
      default:
        break;
    } 
    
    flowerView = [[[FlowerView alloc] 
                   initWithImage:flowerImage] autorelease];
    [flowerPool_ setObject:flowerView 
                    forKey:[NSNumber numberWithInt:type]];
  }
  
  return flowerView;
}

- (void) dealloc
{
  [flowerPool_ release];
  [super dealloc];
}

@end
