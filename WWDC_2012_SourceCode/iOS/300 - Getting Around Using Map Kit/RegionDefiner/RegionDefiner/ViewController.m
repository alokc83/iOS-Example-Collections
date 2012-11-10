
/*
     File: ViewController.m
 Abstract: A UIViewController subclass which shows a map
 
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

#import "ViewController.h"
#import "MyAnnotation.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mainMapView = [[MKMapView alloc] init];
    
    self.mainMapView.delegate = self;
    [self.mainMapView setUserInteractionEnabled: YES];
    [self.mainMapView setScrollEnabled: YES];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [toolbar sizeToFit];
    
    CGSize containerSize = self.view.bounds.size;
    CGSize toolbarSize = toolbar.bounds.size;
    
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset"
                                                                          style: UIBarButtonItemStyleBordered
                                                                         target: self
                                                                         action: @selector(removePins)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle: @"Log"
                                                                  style: UIBarButtonItemStyleBordered
                                                                 target: self
                                                                 action: @selector(tappedShare)];

    toolbar.frame = CGRectMake(0, containerSize.height - toolbarSize.height, containerSize.width, toolbarSize.height);
    self.mainMapView.frame = CGRectMake(0, 0, containerSize.width, containerSize.height - toolbarSize.height);
    [self.view addSubview:self.mainMapView];
    [self.view addSubview:toolbar];
    
    [toolbar setItems:@[ resetButton, flexibleSpace, share ]];
    
    [self setUpGesture];
        
    self.itemsArray = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [self setMainMapView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Dropping pins

- (void)setUpGesture
{
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                   action: @selector(handleLongPress:)];
    self.longPress.delegate = self;
    [self.view addGestureRecognizer:self.longPress];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint longPressPoint = [recognizer locationInView:self.view];
        [self dropPinAtPoint:longPressPoint];
    }
}

- (void)updatePolygon
{
    CLLocationCoordinate2D *points = malloc(sizeof(CLLocationCoordinate2D) * self.itemsArray.count);
    NSUInteger i = 0;
    for (MyAnnotation *pin in self.itemsArray) {
        points[i] = pin.coordinate;
        i++;
    }
    
    [self.mainMapView removeOverlay:self.polygon];
    self.polygon = [MKPolygon polygonWithCoordinates:points count:self.itemsArray.count];
    [self.mainMapView addOverlay:self.polygon];
}

- (void) dropPinAtPoint: (CGPoint) pointToConvert
{
    CLLocationCoordinate2D convertedPoint = [self.mainMapView convertPoint: pointToConvert
                                                      toCoordinateFromView: self.view];
    
    NSString *pinTitle = [NSString stringWithFormat: @"Pin number %i", self.itemsArray.count];
    NSString *subCoordinates = [NSString stringWithFormat: @"%f, %f", convertedPoint.latitude, convertedPoint.longitude];
    
    MyAnnotation *droppedPin = [[MyAnnotation alloc] initWithCoordinate: convertedPoint
                                                                  title: pinTitle
                                                               subtitle: subCoordinates];
    
    [self.mainMapView addAnnotation:droppedPin];
    [self.itemsArray addObject:droppedPin];
    
    [self updatePolygon];
}

- (void)removePins
{
    [self.mainMapView removeAnnotations:self.mainMapView.annotations];
    [self.itemsArray removeAllObjects];
    [self.mainMapView removeOverlay:self.polygon];
    [self updatePolygon];
}

#pragma mark - Output

- (void)tappedShare
{
    NSLog(@"%@", [self coordinates]);
}

- (NSString *)coordinates
{
    if (self.itemsArray.count < 3) {
        return @"Minimum of 3 vertices requried to make polygon.";
    }
    
    NSString *masterString = @"\n{ \"type\": \"MultiPolygon\",\n \"coordinates\": [\n[[";
    for (MyAnnotation *pin in self.itemsArray) {
        masterString = [masterString stringByAppendingFormat: @"[%f, %f],\n", pin.coordinate.longitude, pin.coordinate.latitude];
    }
    
    // GeoJSON requires that the first and last vertices be identical
    MyAnnotation *firstPin = [self.itemsArray objectAtIndex:0];
    masterString = [masterString stringByAppendingFormat: @"[%f, %f],\n", firstPin.coordinate.longitude, firstPin.coordinate.latitude];
    
    masterString = [masterString stringByAppendingString: @"]]\n]\n}\n"];
    masterString = [masterString stringByReplacingOccurrencesOfString: @"],\n]]" withString: @"]]]"];
   
    return masterString;
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if (self.polygonView && self.polygonView.polygon == self.polygon)
        return self.polygonView;
    
    self.polygonView = [[MKPolygonView alloc] initWithPolygon:self.polygon];
    self.polygonView.fillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3f];
    self.polygonView.strokeColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.9f];
    self.polygonView.lineWidth = 1.0f;

    return self.polygonView;
}

@end
