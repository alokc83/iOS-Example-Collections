
/*
     File: MapViewController.m
 Abstract: The main view controller for our app. Displays a map.
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "MapViewController.h"
#import "TransitInfo.h"
#import "DirectionsViewController.h"
#import "MyPlace.h"
#import <CoreLocation/CoreLocation.h>
#import "TransitStop.h"
#import "Route.h"

typedef void (^PerformAfterAcquiringLocationSuccess)(CLLocationCoordinate2D);
typedef void (^PerformAfterAcquiringLocationError)(NSError *);

typedef NS_ENUM(NSInteger, MapViewControllerMode) {
    MapViewControllerModeStations = 0,
    MapViewControllerModeLoading,
    MapViewControllerModeDirections,
};

@interface MapViewController () <DirectionsViewControllerDelegate>
@property (nonatomic) MapViewControllerMode mode;
@property (nonatomic, strong) TransitInfo *transitInfo;
@property (nonatomic, strong) Route *route;
@end

@implementation MapViewController {
    PerformAfterAcquiringLocationSuccess _afterLocationSuccess;
    PerformAfterAcquiringLocationError _afterLocationError;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.transitInfo = [[TransitInfo alloc] init];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Start out looking at the SF Bay Area
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(37.501364, -122.182817);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.906448, 0.878906);
    self.mapView.region = MKCoordinateRegionMake(centerCoordinate, span);
    
    self.mode = MapViewControllerModeStations;
}

- (void)setMode:(MapViewControllerMode)newMode
{
    _mode = newMode;
    switch (_mode) {
        case MapViewControllerModeStations: {
            self.title = @"Stops";
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Directions" style:UIBarButtonItemStyleBordered target:self action:@selector(showDirectionsSheet:)];
            if (self.route) {
                self.route.startStop.subtitle = nil;
                self.route.endStop.subtitle = nil;
                [self.mapView removeAnnotation:self.route.startStop];
                [self.mapView removeAnnotation:self.route.endStop];
                [self.mapView removeOverlay:self.route.polyline];
                self.route = nil;
            }
            
            [self.mapView addAnnotations:self.transitInfo.stops];
            break;
        } case MapViewControllerModeLoading: {
            self.title = @"Loading…";
            self.navigationItem.rightBarButtonItem = nil;
            if (self.route) {
                self.route.startStop.subtitle = nil;
                self.route.endStop.subtitle = nil;
                [self.mapView removeAnnotation:self.route.startStop];
                [self.mapView removeAnnotation:self.route.endStop];
                [self.mapView removeOverlay:self.route.polyline];
                self.route = nil;
            }
            
            [self.mapView removeAnnotations:self.transitInfo.stops];
            break;
        } case MapViewControllerModeDirections: {
            self.title = @"Route";
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearDirections:)];
            [self.mapView addAnnotation:self.route.startStop];
            [self.mapView addAnnotation:self.route.endStop];
            [self.mapView addOverlay:self.route.polyline];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:self.transitInfo.timeZone];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            self.route.startStop.subtitle = [NSString stringWithFormat:@"Departs %@", [dateFormatter stringFromDate:self.route.startDate]];
            self.route.endStop.subtitle = [NSString stringWithFormat:@"Arrives %@", [dateFormatter stringFromDate:self.route.endDate]];
            
            break;
        }
    }
}

- (void)clearDirections:(id)sender
{
    self.mode = MapViewControllerModeStations;
}

- (void)showDirectionsSheet:(id)sender
{
    DirectionsViewController *directionsController = [[DirectionsViewController alloc] initWithNibName:@"DirectionsViewController" bundle:nil];
    directionsController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:directionsController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)handleDirectionsError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Loading Directions" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    self.mode = MapViewControllerModeStations;
}

- (void)routeFromStop:(TransitStop *)startStop toStop:(TransitStop *)endStop departingAtDate:(NSDate *)departureDate
{
    Route *route = [self.transitInfo nextRouteFromStop:startStop toStop:endStop afterDate:departureDate];
    if (!route) {
        [self handleDirectionsError:nil];
        return;
    }
    
    self.route = route;
    self.mode = MapViewControllerModeDirections;
}

- (void)routeFromPlace:(MyPlace *)startPlace toPlace:(MyPlace *)endPlace
{
    self.mode = MapViewControllerModeLoading;
    
    // Find the station closest to the start
    TransitStop *startStop = [self.transitInfo closestStopToCoordinate:startPlace.coordinate];
    TransitStop *endStop = [self.transitInfo closestStopToCoordinate:endPlace.coordinate];
    
    [self routeFromStop:startStop toStop:endStop departingAtDate:[NSDate date]];
}

- (void)routeFromCurrentLocationToPlace:(MyPlace *)endPlace
{
    self.mode = MapViewControllerModeLoading;
    [self performAfterAcquiringLocation:^(CLLocationCoordinate2D coordinate) {
        MyPlace *currentLocationPlace = [[MyPlace alloc] initWithName:@"Current Location" coordinate:coordinate];
        [self routeFromPlace:currentLocationPlace toPlace:endPlace];
    } error:^(NSError *error) {
        [self handleDirectionsError:error];
    }];
}

- (void)routeFromPlaceToCurrentLocation:(MyPlace *)startPlace
{
    self.mode = MapViewControllerModeLoading;
    [self performAfterAcquiringLocation:^(CLLocationCoordinate2D coordinate) {
        MyPlace *currentLocationPlace = [[MyPlace alloc] initWithName:@"Current Location" coordinate:coordinate];
        [self routeFromPlace:startPlace toPlace:currentLocationPlace];
    } error:^(NSError *error) {
        [self handleDirectionsError:error];
    }];
}

- (void)performAfterAcquiringLocation:(PerformAfterAcquiringLocationSuccess)success error:(PerformAfterAcquiringLocationError)error
{
    if (self.mapView.userLocation != nil) {
        if (success)
            success(self.mapView.userLocation.coordinate);
        return;
    }
    
    _afterLocationSuccess = [success copy];
    _afterLocationError = [error copy];
}

#pragma mark -
#pragma mark DirectionsViewControllerDelegate

- (void)directionsViewControllerDidCancel:(DirectionsViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)directionsViewController:(DirectionsViewController *)viewController routeFromAddress:(NSString *)startAddress toAddress:(NSString *)endAddress
{    
    self.mode = MapViewControllerModeLoading;
    
    [self dismissViewControllerAnimated:YES completion:^{
        CLGeocoder *startAddressGeocoder = [[CLGeocoder alloc] init];
        [startAddressGeocoder geocodeAddressString:startAddress completionHandler:^(NSArray *startPlacemarks, NSError *startError) {
            if (startError) {
                [self handleDirectionsError:startError];
                return;
            }
            
            CLPlacemark *startPlacemark = [startPlacemarks objectAtIndex:0];
            MyPlace *startPlace = [[MyPlace alloc] initWithName:startPlacemark.name coordinate:startPlacemark.location.coordinate];
            
            CLGeocoder *endAddressGeocoder = [[CLGeocoder alloc] init];
            [endAddressGeocoder geocodeAddressString:endAddress completionHandler:^(NSArray *endPlacemarks, NSError *endError) {
                if (endError) {
                    [self handleDirectionsError:endError];
                    return;
                }
                
                CLPlacemark *endPlacemark = [endPlacemarks objectAtIndex:0];
                MyPlace *endPlace = [[MyPlace alloc] initWithName:endPlacemark.name coordinate:endPlacemark.location.coordinate];
                
                [self routeFromPlace:startPlace toPlace:endPlace];
            }];
        }];
    }];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[TransitStop class]])
        return nil;
    
    BOOL isRouteAnnotation = (annotation == self.route.startStop || annotation == self.route.endStop);
    if (isRouteAnnotation) {
        // Start/end points get a standard green/red pin
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (!pinAnnotationView)
            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        pinAnnotationView.canShowCallout = YES;
        pinAnnotationView.animatesDrop = YES;
        pinAnnotationView.pinColor = (annotation == self.route.startStop ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed);
        return pinAnnotationView;
    } else {
        // Use a custom "dot" to represent stations
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Station"];
        if (!annotationView)
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Station"];
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"station.png"];
        return annotationView;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if (overlay == self.route.polyline) {
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)overlay];
        polylineView.lineWidth = 0;
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        return polylineView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // If we are waiting on a user location, call the block
    PerformAfterAcquiringLocationSuccess callback = _afterLocationSuccess;
    _afterLocationError = nil;
    _afterLocationSuccess = nil;
    
    if (callback)
        callback(userLocation.coordinate);
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    // If we are waiting on a user location, inform the block of the error
    PerformAfterAcquiringLocationError callback = _afterLocationError;
    _afterLocationError = nil;
    _afterLocationSuccess = nil;
    
    if (callback)
        callback(error);
}

@end
