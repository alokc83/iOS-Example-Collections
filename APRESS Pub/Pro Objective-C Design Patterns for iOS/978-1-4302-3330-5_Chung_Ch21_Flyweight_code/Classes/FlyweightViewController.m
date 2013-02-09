//
//  FlyweightViewController.m
//  Flyweight
//
//  Created by Carlo Chung on 11/28/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "FlyweightViewController.h"
#import "FlowerFactory.h"
#import "ExtrinsicFlowerState.h"


@implementation FlyweightViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  // construct a flower list
  FlowerFactory *factory = [[[FlowerFactory alloc] init] autorelease];
  NSMutableArray *flowerList = [[[NSMutableArray alloc] 
                                 initWithCapacity:500] autorelease];
  
  for (int i = 0; i < 500; ++i)
  {
    // retrieve a shared instance 
    // of a flower flyweight object
    // from a flower factory with a
    // random flower type
    FlowerType flowerType = arc4random() % kTotalNumberOfFlowerTypes;
    UIView *flowerView = [factory flowerViewWithType:flowerType];
    
    // set up a location and an area for the flower
    // to display onscreen
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat x = (arc4random() % (NSInteger)screenBounds.size.width);
    CGFloat y = (arc4random() % (NSInteger)screenBounds.size.height);
    NSInteger minSize = 10;
    NSInteger maxSize = 50;
    CGFloat size = (arc4random() % (maxSize - minSize + 1)) + minSize;

    // assign attributes for a flower
    // to an extrinsic state object
    ExtrinsicFlowerState extrinsicState;
    extrinsicState.flowerView = flowerView;
    extrinsicState.area = CGRectMake(x, y, size, size);
    
    // add an extrinsic flower state
    // to the flower list
    [flowerList addObject:[NSValue value:&extrinsicState 
                            withObjCType:@encode(ExtrinsicFlowerState)]];
  }
 
  // add the flower list to
  // this FlyweightView instance
  [(FlyweightView *)self.view setFlowerList:flowerList];
}


- (void)didReceiveMemoryWarning 
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)dealloc 
{
  [super dealloc];
}

@end
