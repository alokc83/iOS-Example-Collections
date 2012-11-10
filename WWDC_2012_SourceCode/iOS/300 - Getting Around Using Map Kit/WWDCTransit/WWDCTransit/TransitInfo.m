
/*
     File: TransitInfo.m
 Abstract: An interface abstracting the raw GTFS feed data into something
 more managable.
 
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

#import "TransitInfo.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "TransitStop.h"
#import "TransitTrip.h"
#import "TransitShape.h"
#import "Route.h"

static NSString * const StopIDKey = @"stop_id";
static NSString * const StopNameKey = @"stop_name";
static NSString * const StopLatitudeKey = @"stop_lat";
static NSString * const StopLongitudeKey = @"stop_lon";

static NSString * const TripIDKey = @"trip_id";
static NSString * const TripRouteIDKey = @"route_id";
static NSString * const TripHeadsignKey = @"trip_headsign";

static NSString * const ArrivalTimeKey = @"arrival_time";
static NSString * const DepartureTimeKey = @"departure_time";

static NSString * const ServiceIDKey = @"service_id";

static NSString * const MondayKey = @"monday";
static NSString * const TuesdayKey = @"tuesday";
static NSString * const WednesdayKey = @"wednesday";
static NSString * const ThursdayKey = @"thursday";
static NSString * const FridayKey = @"friday";
static NSString * const SaturdayKey = @"saturday";
static NSString * const SundayKey = @"sunday";

static NSString * const TimeZoneKey = @"agency_timezone";

static NSString * const ShapeIDKey = @"shape_id";
static NSString * const ShapePointLatKey = @"shape_pt_lat";
static NSString * const ShapePointLngKey = @"shape_pt_lon";

@interface TransitInfo ()
@property (nonatomic, strong) NSMutableDictionary *shapes;
@property (nonatomic, strong) NSMutableArray *trips;
@property (readwrite) NSTimeZone *timeZone;
@end

@implementation TransitInfo {
    NSMutableArray *_stops;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self buildAgency];
        [self buildStops];
        [self buildShapes];
        [self buildTrips];
    }
    return self;
}

// Parses a CSV file matching the specifications of GTFS
// This is not designed to be a general purpose CSV parser, nor is it designed
// to handle the entire GTFS specification. It is for illustration purposes only
//
// It calls the handler once for each row in the file, passing a dictionary mapping
// the column names to the corresponding value for that line
- (void)parseFile:(NSString *)fileName handler:(void (^)(NSDictionary *))handler
{
    if (!handler)
        return;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString *file = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!file) {
        NSLog(@"Error reading %@ file", fileName);
        return;
    }
    
    NSArray *lines = [file componentsSeparatedByString:@"\n"];
    NSArray *keys = nil;
    for (NSString *line in lines) {
        if ([line length] == 0)
            continue;
        
        NSCharacterSet *interestingCharacters = [NSMutableCharacterSet characterSetWithCharactersInString:@",\"\n\r"];
        NSScanner *scanner = [NSScanner scannerWithString:line];
        scanner.charactersToBeSkipped = nil;
        
        NSMutableArray *values = [[NSMutableArray alloc] init];
        NSString *tempString;
        NSMutableString *currentColumn = [[NSMutableString alloc] init];
        BOOL insideQuotes = NO;
        while (![scanner isAtEnd]) {
            if ([scanner scanUpToCharactersFromSet:interestingCharacters intoString:&tempString]) {
                [currentColumn appendString:tempString];
            }
            
            [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
            
            // Scan all characters in the current column (where a column is terminated by a comma
            if ([scanner isAtEnd]) {
                [values addObject:currentColumn];
            } else if ([scanner scanString:@"\"" intoString:nil]) {
                if (insideQuotes && [scanner scanString:@"\"" intoString:nil]) {
                    // Double quotes become single quotes
                    [currentColumn appendString:@"\""];
                } else {
                    insideQuotes = !insideQuotes;
                }
            } else if ([scanner scanString:@"," intoString:nil]) {
                if (insideQuotes) {
                    [currentColumn appendString:@","];
                } else {
                    [values addObject:currentColumn];
                    currentColumn = [[NSMutableString alloc] init];
                }
            }
        }
        
        // The first time through, we're reading the field names
        if (!keys) {
            keys = values;
            continue;
        }
        
        if ([values count] > [keys count]) {
            NSLog(@"Error parsing %@ file", fileName);
            continue;
        } else if ([values count] < [keys count]) {
            // If there's any keys which don't have a value, assume empty values
            while ([values count] < [keys count]) {
                [values addObject:@""];
            }
        }
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        handler(dict);
    }
}

- (void)buildAgency
{
    NSString *agencyPath = [[NSBundle mainBundle] pathForResource:@"agency" ofType:@"txt"];
    NSString *agencyFile = [NSString stringWithContentsOfFile:agencyPath encoding:NSUTF8StringEncoding error:nil];
    if (!agencyFile) {
        NSLog(@"Error reading agency file");
        return;
    }
    
    NSArray *agencyLines = [agencyFile componentsSeparatedByString:@"\n"];
    if ([agencyLines count] != 2)
        return;
    
    NSArray *keys = [[agencyLines objectAtIndex:0] componentsSeparatedByString:@","];
    NSUInteger timeZoneIndex = [keys indexOfObject:TimeZoneKey];
    
    NSString *valueLine = [agencyLines objectAtIndex:1];
    NSString *lineIgnoringFirstAndLastQuote = [valueLine substringWithRange:NSMakeRange(1, [valueLine length] - 2)];
    NSArray *values = [lineIgnoringFirstAndLastQuote componentsSeparatedByString:@"\",\""];
    NSString *timeZoneName = [values objectAtIndex:timeZoneIndex];
    self.timeZone = [[NSTimeZone alloc] initWithName:timeZoneName];
}

- (void)buildShapes
{
    if (self.shapes)
        return;
    
    self.shapes = [[NSMutableDictionary alloc] init];
    
    [self parseFile:@"shapes" handler:^(NSDictionary *values) {
        NSString *shapeID = [values objectForKey:ShapeIDKey];
        TransitShape *shape = [self.shapes objectForKey:shapeID];
        if (!shape) {
            shape = [[TransitShape alloc] init];
            [self.shapes setObject:shape forKey:shapeID];
        }
        
        NSString *latString = [values objectForKey:ShapePointLatKey];
        NSString *lngString = [values objectForKey:ShapePointLngKey];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latString doubleValue], [lngString doubleValue]);
        [shape addCoordinate:coordinate];
    }];
}

- (void)buildStops
{
    if (_stops)
        return;
    
    _stops = [[NSMutableArray alloc] init];
    
    [self parseFile:@"stops" handler:^(NSDictionary *values) {
        NSString *stopName = [values objectForKey:StopNameKey];
        CLLocationCoordinate2D stopCoordinate = CLLocationCoordinate2DMake([[values objectForKey:StopLatitudeKey] doubleValue], [[values objectForKey:StopLongitudeKey] doubleValue]);
        NSString *stopID = [values objectForKey:StopIDKey];
        
        TransitStop *stop = [[TransitStop alloc] initWithTitle:stopName coordinate:stopCoordinate stopID:stopID];
        [_stops addObject:stop];
    }];
}

- (NSDictionary *)timesForTripIDs
{
    NSMutableDictionary *tripIDToTimes = [[NSMutableDictionary alloc] init];
    
    [self parseFile:@"stop_times" handler:^(NSDictionary *values) {
        NSString *tripID = [values objectForKey:TripIDKey];
        NSMutableDictionary *timesForTripID = [tripIDToTimes objectForKey:tripID];
        if (!timesForTripID) {
            timesForTripID = [[NSMutableDictionary alloc] init];
            [tripIDToTimes setObject:timesForTripID forKey:tripID];
        }
        
        NSString *arrivalTimeString = [values objectForKey:ArrivalTimeKey];
        NSArray *arrivalTimeComponents = [arrivalTimeString componentsSeparatedByString:@":"];
        if ([arrivalTimeComponents count] != 3)
            return;
        
        CFTimeInterval arrivalTimeOfDay = [[arrivalTimeComponents objectAtIndex:0] integerValue] * 3600 + [[arrivalTimeComponents objectAtIndex:1] integerValue] * 60 + [[arrivalTimeComponents objectAtIndex:2] integerValue];
        
        NSString *departureTimeString = [values objectForKey:ArrivalTimeKey];
        NSArray *departureTimeComponents = [departureTimeString componentsSeparatedByString:@":"];
        if ([departureTimeComponents count] != 3)
            return;
        
        CFTimeInterval departureTimeOfDay = [[departureTimeComponents objectAtIndex:0] integerValue] * 3600 + [[departureTimeComponents objectAtIndex:1] integerValue] * 60 + [[departureTimeComponents objectAtIndex:2] integerValue];
        
        NSDictionary *timeInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:arrivalTimeOfDay], ArrivalTimeKey, [NSNumber numberWithDouble:departureTimeOfDay], DepartureTimeKey, nil];
        [timesForTripID setObject:timeInfo forKey:[values objectForKey:StopIDKey]];
    }];
    return tripIDToTimes;
}

- (TransitTripDays)activeDaysForServiceID:(NSString *)serviceID
{
    __block TransitTripDays days = 0;
    [self parseFile:@"calendar" handler:^(NSDictionary *values) {
        if (![serviceID isEqualToString:[values objectForKey:ServiceIDKey]])
            return;
                
        if ([[values objectForKey:MondayKey] boolValue])
            days |= TransitTripDayMonday;
        if ([[values objectForKey:TuesdayKey] boolValue])
            days |= TransitTripDayTuesday;
        if ([[values objectForKey:WednesdayKey] boolValue])
            days |= TransitTripDayWednesday;
        if ([[values objectForKey:ThursdayKey] boolValue])
            days |= TransitTripDayThursday;
        if ([[values objectForKey:FridayKey] boolValue])
            days |= TransitTripDayFriday;
        if ([[values objectForKey:SaturdayKey] boolValue])
            days |= TransitTripDaySaturday;
        if ([[values objectForKey:SundayKey] boolValue])
            days |= TransitTripDaySunday;
    }];
    return days;
}

- (void)buildTrips
{
    if (self.trips)
        return;
    
    NSDictionary *timesForTripIDs = [self timesForTripIDs];
    
    self.trips = [[NSMutableArray alloc] init];
    
    [self parseFile:@"trips" handler:^(NSDictionary *values) {
        NSString *tripID = [values objectForKey:TripIDKey];
        NSString *routeID = [values objectForKey:TripRouteIDKey];
        NSString *headsign = [values objectForKey:TripHeadsignKey];
        NSString *serviceID = [values objectForKey:ServiceIDKey];
        
        NSDictionary *timeInfo = [timesForTripIDs objectForKey:tripID];
        
        TransitTripDays activeDays = [self activeDaysForServiceID:serviceID];
        
        NSString *shapeID = [values objectForKey:ShapeIDKey];
        TransitShape *shape = [self.shapes objectForKey:shapeID];
        
        TransitTrip *trip = [[TransitTrip alloc] initWithTripID:tripID routeID:routeID headsign:headsign times:timeInfo activeDays:activeDays shape:shape];
        [self.trips addObject:trip];
    }];
}

- (TransitStop *)closestStopToCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    
    CLLocationDistance closestDistance = INFINITY;
    TransitStop *closestStop = nil;
    
    for (TransitStop *stop in _stops) {
        MKMapPoint stopMapPoint = MKMapPointForCoordinate(stop.coordinate);
        CLLocationDistance distance = MKMetersBetweenMapPoints(stopMapPoint, mapPoint);
        if (distance < closestDistance) {
            closestDistance = distance;
            closestStop = stop;
        }
    }
    
    return closestStop;
}

- (Route *)nextRouteFromStop:(TransitStop *)startStop toStop:(TransitStop *)endStop afterDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:self.timeZone];
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    TransitTripDays dayOfWeek = 1 << ([weekdayComponents weekday] - 1);
    
    CFTimeInterval timeOfDay = ([weekdayComponents hour] * 3600 + [weekdayComponents minute] * 60 + [weekdayComponents second]);
    
    TransitTrip *soonestTrip = nil;
    CFTimeInterval soonestTripDepartureTimeOfDay = INFINITY;
    CFTimeInterval soonestTripArrivalTimeOfDay = INFINITY;
    for (TransitTrip *trip in self.trips) {
        // Ignore trips which don't run on the specified day
        if (!(trip.activeDays & dayOfWeek))
            continue;
        
        NSDictionary *timesForStartStop = [trip.times objectForKey:startStop.stopID];
        if (!timesForStartStop)
            continue;
        
        NSDictionary *timesForEndStop = [trip.times objectForKey:endStop.stopID];
        if (!timesForEndStop)
            continue;
        
        NSNumber *departureTimeNumber = [timesForStartStop objectForKey:DepartureTimeKey];
        if (!departureTimeNumber)
            continue;
        
        CFTimeInterval departureTimeOfDay = [departureTimeNumber doubleValue];
        if (departureTimeOfDay < timeOfDay)
            continue;
        
        NSNumber *arrivalTimeNumber = [timesForEndStop objectForKey:ArrivalTimeKey];
        if (!arrivalTimeNumber)
            continue;
        
        CFTimeInterval arrivalTimeOfDay = [arrivalTimeNumber doubleValue];
        if (arrivalTimeOfDay <= departureTimeOfDay)
            continue;
        
        if (departureTimeOfDay < soonestTripDepartureTimeOfDay) {
            soonestTripDepartureTimeOfDay = departureTimeOfDay;
            soonestTripArrivalTimeOfDay = arrivalTimeOfDay;
            soonestTrip = trip;
        }
    }
    
    Route *route = nil;
    if (soonestTrip) {
        NSDate *startDate = [date dateByAddingTimeInterval:(soonestTripDepartureTimeOfDay - timeOfDay)];
        NSDate *endDate = [date dateByAddingTimeInterval:(soonestTripArrivalTimeOfDay - timeOfDay)];
        route = [[Route alloc] initWithStartStop:startStop startDate:startDate endStop:endStop endDate:endDate trip:soonestTrip];
    }
    return route;
}

@end
