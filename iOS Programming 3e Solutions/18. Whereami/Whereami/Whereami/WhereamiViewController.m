//
//  WhereamiViewController.m
//  Whereami
//
//  Created by joeconway on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WhereamiViewController.h"
#import "MapPoint.h"


NSString * const WhereamiMapTypePrefKey = @"WhereamiMapTypePrefKey";

@implementation WhereamiViewController

+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary 
                            dictionaryWithObject:[NSNumber numberWithInt:1]
                                          forKey:WhereamiMapTypePrefKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        locationManager = [[CLLocationManager alloc] init];        
        [locationManager setDelegate:self];        
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return self;
}
- (void)viewDidLoad
{
    [worldView setShowsUserLocation:YES];    
    NSInteger mapTypeValue = [[NSUserDefaults standardUserDefaults] 
                                integerForKey:WhereamiMapTypePrefKey];
    
    // Update the UI 
    [mapTypeControl setSelectedSegmentIndex:mapTypeValue];

    // Update the map 
    [self changeMapType:mapTypeControl];
}
- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    // This method isn't implemented yet - but will be soon.
    [self findLocation];
    
    [tf resignFirstResponder];
    
    return YES;
}
- (void)findLocation
{
    [locationManager startUpdatingLocation];
    [activityIndicator startAnimating];
    [locationTitleField setHidden:YES];
}

- (void)foundLocation:(CLLocation *)loc
{
    CLLocationCoordinate2D coord = [loc coordinate];
    
    // Create an instance of MapPoint with the current data
    MapPoint *mp = [[MapPoint alloc] initWithCoordinate:coord
                                                  title:[locationTitleField text]];
    // Add it to the map view 
    [worldView addAnnotation:mp];
        
    // Zoom the region to this location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 250, 250);
    [worldView setRegion:region animated:YES];
    
    [locationTitleField setText:@""];
    [activityIndicator stopAnimating];
    [locationTitleField setHidden:NO];
    [locationManager stopUpdatingLocation];
}

- (IBAction)changeMapType:(id)sender 
{    
    [[NSUserDefaults standardUserDefaults] 
                    setInteger:[sender selectedSegmentIndex]
                        forKey:WhereamiMapTypePrefKey];
    switch([sender selectedSegmentIndex])
    {
        case 0:
        { 
            [worldView setMapType:MKMapTypeStandard];
        }break;
        case 1:
        {
            [worldView setMapType:MKMapTypeSatellite];
        }break;
        case 2:
        {
            [worldView setMapType:MKMapTypeHybrid];
        }break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // How many seconds ago was this new location created?
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    
    // CLLocationManagers will return the last found location of the 
    // device first, you don't want that data in this case.
    // If this location was made more than 3 minutes ago, ignore it.
    if (t < -180) {
        // This is cached data, you don't want it, keep looking
        return;
    }
    
    [self foundLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
}

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)u
{
    CLLocationCoordinate2D loc = [u coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    [worldView setRegion:region animated:YES];
}

- (void)dealloc
{
    // Tell the location manager to stop sending us messages
    [locationManager setDelegate:nil];
}
@end
