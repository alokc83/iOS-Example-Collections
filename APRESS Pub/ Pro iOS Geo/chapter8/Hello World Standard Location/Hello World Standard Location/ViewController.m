//
//  ViewController.m
//  Hello World Standard Location
//
//  Created by Giacomo Andreucci on 20/10/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *latitudeField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeField;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;

- (IBAction)getLocation:(id)sender;

@end

@implementation ViewController
@synthesize latitudeField;
@synthesize longitudeField;
@synthesize onOffSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 3;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)getLocation:(id)sender {
    
    if(onOffSwitch.on) {
        [locationManager startUpdatingLocation];
    }
    
    else {

        [locationManager stopUpdatingLocation];
        latitudeField.text = @"";
        longitudeField.text = @"";
    }
    
}

- (void)locationManager:(CLLocationManager *)manager

    didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    
    NSDate* eventDate = location.timestamp;
    
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 5.0) {
        
    // If the event is less than 5 seconds older display the coordinates             
    NSString *latitudeFieldData = [[NSString alloc]initWithFormat:@"%g", location.coordinate.latitude];
    NSString *longitudeFieldData = [[NSString alloc]initWithFormat:@"%g", location.coordinate.longitude];  
    latitudeField.text = latitudeFieldData;
    longitudeField.text = longitudeFieldData;
        
   }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

    switch([error code])
    {   
        case kCLErrorLocationUnknown://The location manager was unable to obtain a location value right now.
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location error" message:@"It is not possible to obtain current location" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
            break;
            
        case kCLErrorDenied://Access to the location service was denied by the user.
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error: permission denied" message:@"User has denied permission to use location services. Go to Settings > Privacy > Location and enable Location Services for the app." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [locationManager stopUpdatingLocation];
            onOffSwitch.on = NO;
            
        }
            break;
            
        case kCLErrorNetwork: //The network was unavailable or a network error occurred.
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error" message:@"Make sure your network connection is activated or that you are not in Airplane Mode" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
            break;

    }

}


@end
