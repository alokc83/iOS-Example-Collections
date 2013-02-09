//
//  ViewController.m
//  Polyline Example
//
//  Created by Giacomo Andreucci on 22/11/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import "ViewController.h"
#import "CustomAnnotation.h"

@interface ViewController ()

@end

@implementation ViewController
//@synthesize polyLine;
@synthesize polygon;
@synthesize showHideSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_mapView setDelegate:self];
    
    //Set the region shown in the map view
	CLLocationCoordinate2D regionCenter;
    regionCenter.latitude = 40.664167;
    regionCenter.longitude = -73.938611;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(regionCenter, 10000, 10000);
    [_mapView setRegion:region animated:TRUE];
    
    //Create the array of map points 
    MKMapPoint * pointsArray = malloc(sizeof(CLLocationCoordinate2D)*4);
    pointsArray[0]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(40.730742,-73.992257));
    
    pointsArray[1]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(40.677762,-73.985409));
    
    pointsArray[2]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(40.639047,-73.918120));
    
    pointsArray[3]= MKMapPointForCoordinate(CLLocationCoordinate2DMake(40.685396,-73.880044));
  
    //Pass the array to the MKPolyline instance and add the overlay to the map view
    //polyLine = [MKPolyline polylineWithPoints:pointsArray count:4];
    //[_mapView addOverlay:polyLine];
    polygon = [MKPolygon polygonWithPoints:pointsArray count:4];
    [_mapView addOverlay:polygon];
    
    for (int i = 0; i<4; i++) {
        
        CustomAnnotation *annotation = [[CustomAnnotation alloc]initWithLocation: MKCoordinateForMapPoint(pointsArray[i]) title: [NSString stringWithFormat:@"Annotation N. %i", i] andSubtitle:[NSString stringWithFormat:@"This is annotation N. %i", i]];
        [_mapView addAnnotation:annotation];
        
    }
    
    free(pointsArray);
    
}

- (MKOverlayView *)mapView:(MKMapView *)theMapView viewForOverlay:(id )overlay

{

    /*MKPolylineView  * polyLineView = [[MKPolylineView alloc] initWithPolyline:polyLine];
    
    polyLineView.strokeColor = [UIColor redColor];
    
    polyLineView.lineWidth = 3;

    return polyLineView;*/
    
    MKPolygonView  * polygonView = [[MKPolygonView alloc] initWithPolygon:polygon];
    
    
    polygonView.fillColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    
    polygonView.strokeColor = [UIColor redColor];
    
    polygonView.lineWidth = 3;
    
    return polygonView;
         
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showHideOverlay:(id)sender {
    
    if(showHideSwitch.on) {
    [_mapView addOverlay:polygon];
    }
    
    else {
        
    [_mapView removeOverlay:polygon];
    }
}
@end
