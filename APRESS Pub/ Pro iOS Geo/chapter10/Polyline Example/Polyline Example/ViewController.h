//
//  ViewController.h
//  Polyline Example
//
//  Created by Giacomo Andreucci on 22/11/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <MKMapViewDelegate>
{
    //MKPolyline *polyLine;
    MKPolygon * polygon;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property(nonatomic, retain) MKPolyline *polyLine;
@property(nonatomic, retain) MKPolygon *polygon;
@property (weak, nonatomic) IBOutlet UISwitch *showHideSwitch;
- (IBAction)showHideOverlay:(id)sender;

@end
