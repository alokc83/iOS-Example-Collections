//
//  CoordinatingController.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/18/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "CoordinatingController.h"

@interface CoordinatingController ()

- (void) initialize;

@end


@implementation CoordinatingController

@synthesize activeViewController=activeViewController_;
@synthesize canvasViewController=canvasViewController_;

static CoordinatingController *sharedCoordinator = nil;

- (void) initialize
{
  canvasViewController_ = [[CanvasViewController alloc] init];
  activeViewController_ = canvasViewController_;
}

#pragma mark -
#pragma mark CoordinatingController Singleton Implementation

+ (CoordinatingController *) sharedInstance
{
  if (sharedCoordinator == nil)
  {
    sharedCoordinator = [[super allocWithZone:NULL] init];
    
    // initialize the first view controller
    // and keep it with the singleton
    [sharedCoordinator initialize];
  }
  
  return sharedCoordinator;
}

+ (id) allocWithZone:(NSZone *)zone
{
  return [[self sharedInstance] retain];
}

- (id) copyWithZone:(NSZone*)zone
{
  return self;
}

- (id) retain
{
  return self;
}

- (NSUInteger) retainCount
{
  return NSUIntegerMax;
}

- (void) release
{
  // do nothing
}

- (id) autorelease
{
  return self;
}


#pragma mark -
#pragma mark A method for view transitions

- (IBAction) requestViewChangeByObject:(id)object
{
  
  if ([object isKindOfClass:[UIBarButtonItem class]])
  {
    switch ([(UIBarButtonItem *)object tag]) 
    {
      case kButtonTagOpenPaletteView:
      {
        // load a PaletteViewController
        PaletteViewController *controller = [[[PaletteViewController alloc] init] autorelease];
        
        // transition to the PaletteViewController
        [canvasViewController_ presentModalViewController:controller
                                                 animated:YES];
        
        // set the activeViewController to 
        // paletteViewController
        activeViewController_ = controller;
      }
        break;
      case kButtonTagOpenThumbnailView:
      {
        // load a ThumbnailViewController
        ThumbnailViewController *controller = [[[ThumbnailViewController alloc] init] autorelease];
        
        
        // transition to the ThumbnailViewController
        [canvasViewController_ presentModalViewController:controller
                                                 animated:YES];
        
        // set the activeViewController to
        // ThumbnailViewController
        activeViewController_ = controller;
      }
        break;
      default:
        // just go back to the main canvasViewController
        // for the other types 
      {
        // The Done command is shared on every 
        // view controller except the CanvasViewController
        // When the Done button is hit, it should
        // take the user back to the first page in
        // conjunction with the design
        // other objects will follow the same path
        [canvasViewController_ dismissModalViewControllerAnimated:YES];
        
        // set the activeViewController back to 
        // canvasViewController
        activeViewController_ = canvasViewController_;
      }
        break;
    }
  }
  // every thing else goes to the main canvasViewController
  else 
  {
    [canvasViewController_ dismissModalViewControllerAnimated:YES];
    
    // set the activeViewController back to 
    // canvasViewController
    activeViewController_ = canvasViewController_;
  }
  
}

@end
