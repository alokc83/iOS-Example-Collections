//
//  ViewController.h
//  Custom Annotation Object Example
//
//  Created by Giacomo Andreucci on 19/11/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
