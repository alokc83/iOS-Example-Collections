//
//  CustomAnnotation.h
//  Polyline Example
//
//  Created by Giacomo Andreucci on 22/11/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

// The class must conform to the MKAnnotation protocol
@interface CustomAnnotation : NSObject <MKAnnotation> {
    
    // Declare the coordinate variable
    CLLocationCoordinate2D coordinate;
    // Declare the variable for the title
    NSString *title;
    // Declare the variable for the subtitle
    NSString *subtitle;
    
}
// Define the properties for the declared variables
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


//Declare the initialization method
- (id)initWithLocation:(CLLocationCoordinate2D)coords title:(NSString *)aTitle andSubtitle:(NSString*)aSubtitle;


@end