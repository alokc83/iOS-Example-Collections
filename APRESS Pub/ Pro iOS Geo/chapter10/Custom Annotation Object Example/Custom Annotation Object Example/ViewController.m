//
//  ViewController.m
//  Custom Annotation Object Example
//
//  Created by Giacomo Andreucci on 19/11/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import "ViewController.h"
#import "CustomAnnotation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_mapView setDelegate:self];
	CLLocationCoordinate2D regionCenter;
    regionCenter.latitude = 40.664167;
    regionCenter.longitude = -73.938611;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(regionCenter, 10000, 10000);
    [_mapView setRegion:region animated:TRUE];
    
    CLLocationCoordinate2D randomCoord;
    
    for(int i = 0; i < 10; i++) {

        CGFloat latDelta = (arc4random() % 10)  * 0.01;
        CGFloat longDelta = (arc4random() % 10) * 0.01;
        randomCoord.latitude = regionCenter.latitude + latDelta;
        randomCoord.longitude = regionCenter.longitude + longDelta;
              
        CustomAnnotation *annotation = [[CustomAnnotation alloc]initWithLocation: randomCoord
                                                                           title: @"Custom annotation object"
                                                                     andSubtitle:@"You just clicked on the annotation"];
        
        [_mapView addAnnotation:annotation];           
        
    }
    
    /*CustomAnnotation *annotation = [[CustomAnnotation alloc]initWithLocation: regionCenter
                                                   title: @"Custom annotation object"
                                             andSubtitle:@"You just clicked on the annotation"];
    
	[_mapView addAnnotation:annotation];*/
    
}



-(MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ViewIdentifier"];
    
    aView.image = [UIImage imageNamed:@"starIcon.png"];
    
    aView.centerOffset = CGPointMake(0, -19);
    
    aView.canShowCallout = YES;
    
    return aView;
    
    /*
    // Try to dequeue an existing pin annotation view first.
    MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"ViewIdentifier"];
    
    // If an existing pin view annotation is not available create one and set its properties.
    if (pinView==NULL){
   
    MKPinAnnotationView*    pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ViewIdentifier"];
    
    pinView.pinColor = MKPinAnnotationColorGreen;
    
    pinView.animatesDrop = YES;
    
    pinView.canShowCallout = YES;
    
    return pinView;
     
    
        
    }
    
    //If an existing pin annotation view is available associate it to the annotation object and then return it
    else {     
    pinView.annotation = annotation;    
    return pinView;}*/
    
    
}

  /*  CustomAnnotation *anotacion1 = (CustomAnnotation*)annotation;
    
    
    
    MKAnnotationView *aView = [[MKAnnotationView alloc] initWithAnnotation:anotacion1 reuseIdentifier:@"pinView"];
    
    
    //\\-------------------------------------------------------------------------------///
    // Creo el nombre de la imagen
    //\\-------------------------------------------------------------------------------///
    NSString *icoName = @"MKAnnotation.png";
    
    
    //\\-------------------------------------------------------------------------------///
    // Configuramos la vista del mapa
    //\\-------------------------------------------------------------------------------///
    aView.canShowCallout = YES;
    aView.enabled = YES;
    aView.centerOffset = CGPointMake(0, -20);
    
    aView.draggable = YES;
    
    
    UIImage *imagen = [UIImage imageNamed:icoName];
    
    aView.image = imagen;
    
    
    
    //\\-------------------------------------------------------------------------------///
    // Establecemos el tamaño óptimo para el Pin
    //\\-------------------------------------------------------------------------------///
    CGRect frame = aView.frame;
    frame.size.width = 47;
    frame.size.height = 55;
    aView.frame = frame;
    
    
    return aView;*/
    
  
    
    // Try to dequeue an existing pin view first.
    
   /* MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[theMapView
                                                             dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    
    
    
    if (!pinView)
        
    {
        
        // If an existing pin view was not available, create one.
        
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                    
                                                  reuseIdentifier:@"CustomPinAnnotationView"];
        
                 
        
        pinView.pinColor = MKPinAnnotationColorGreen;
        
        pinView.animatesDrop = YES;
        
        pinView.canShowCallout = YES;
        
        
        
        // Add a detail disclosure button to the callout.
        
      UIButton* rightButton = [UIButton buttonWithType:
                                 
                                 UIButtonTypeDetailDisclosure];
        
        [rightButton addTarget:self action:@selector(myShowDetailsMethod:)
         
              forControlEvents:UIControlEventTouchUpInside];
        
        pinView.rightCalloutAccessoryView = rightButton; 
        
    }
    
    else
        
        pinView.annotation = annotation;
    
    
    
    return pinView; 
    
}*/

@end
