//
//  ViewController.h
//  Hello World Standard Location
//
//  Created by Giacomo Andreucci on 20/10/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;    
}

@end
