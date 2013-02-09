//
//  DecoratorViewController.m
//  Decorator
//
//  Created by Carlo Chung on 11/15/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "DecoratorViewController.h"
#import "UIImage+Transform.h"
#import "UIImage+Shadow.h"
#import "ImageTransformFilter.h"
#import "ImageShadowFilter.h"
#import "DecoratorView.h"

@implementation DecoratorViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
  [super viewDidLoad];
  
  // load the original image
  UIImage *image = [UIImage imageNamed:@"Image.png"];
  
 
  // create a transformation
  CGAffineTransform rotateTransform = CGAffineTransformMakeRotation(-M_PI / 4.0);
  CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(-image.size.width / 2.0, 
                                                                          image.size.height / 8.0);
  CGAffineTransform finalTransform = CGAffineTransformConcat(rotateTransform, translateTransform);
  
  // a true subclass approach
  id <ImageComponent> transformedImage = [[[ImageTransformFilter alloc] initWithImageComponent:image
                                                                                     transform:finalTransform] 
                                          autorelease];
  id <ImageComponent> finalImage = [[[ImageShadowFilter alloc] initWithImageComponent:transformedImage] 
                autorelease]; 

  /*
  // a category approach
  // add transformation
  UIImage *transformedImage = [image imageWithTransform:finalTransform];
  
  // add shadow
  id <ImageComponent> finalImage = [transformedImage imageWithDropShadow];

  // category approach in one line
  //id <ImageComponent> finalImage = [[image imageWithTransform:finalTransform] imageWithDropShadow];
  */
  
  // create a new image view
  // with a filtered image
  DecoratorView *decoratorView = [[[DecoratorView alloc] initWithFrame:[self.view bounds]]
                                  autorelease];
  [decoratorView setImage:finalImage];
  [self.view addSubview:decoratorView];
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
