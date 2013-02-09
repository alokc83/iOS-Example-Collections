//
//  ViewController.m
//  Map Type Control
//
//  Created by Giacomo Andreucci on 08/11/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;
- (IBAction)changeMapType:(id)sender;

@end

@implementation ViewController
@synthesize mapView;
@synthesize mapTypeControl;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    MKCoordinateRegion region;
    region.center.latitude = 40.716667;
    region.center.longitude = -74;
    region = MKCoordinateRegionMakeWithDistance(region.center, 100000, 50000);
   /* region.span.latitudeDelta =1;
    region.span.longitudeDelta =3;*/
    
    [mapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeMapType:(id)sender {
    if ([mapTypeControl selectedSegmentIndex] == 0){
        mapView.mapType = MKMapTypeStandard;
    }
    else if ([mapTypeControl selectedSegmentIndex] == 1)
    {
        mapView.mapType = MKMapTypeSatellite;
        
        
    }
    
    else if ([mapTypeControl selectedSegmentIndex] == 2)
    {
        mapView.mapType = MKMapTypeHybrid;
        
    }
}
@end
