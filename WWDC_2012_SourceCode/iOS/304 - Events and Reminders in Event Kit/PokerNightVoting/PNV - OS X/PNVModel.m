//     File: PNVModel.m
// Abstract: Model that uses EventKit to access calendar events on both iOS and OS X
//  Version: 1.0
// 
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
// 
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a personal, non-exclusive
// license, under Apple's copyrights in this original Apple software (the
// "Apple Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
// 
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
// 
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 
// Copyright (C) 2012 Apple Inc. All Rights Reserved.
// 
// 
// WWDC 2012 License
// 
// NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
// Session. Please refer to the applicable WWDC 2012 Session for further
// information.
// 
// IMPORTANT: This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
// 
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a non-exclusive license, under
// Apple's copyrights in this original Apple software (the "Apple
// Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
// 
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
// 
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 

#import "PNVModel.h"

#import <EventKit/EKEvent.h>

#import <EventKit/EKEventStore.h>
#import <EventKit/EKCalendar.h>

NSString *const PNVModelChangedNotification = @"PNVModelChangedNotification";

@implementation PNVModel {
    Boolean _broadcastChangedNotifications;
    dispatch_queue_t _fetchPokerEventsQueue;
}

- (id)init {
    self = [super init];
    if (self) {
        _eventStore = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskEvent];
        _selectedCalendar = self.eventStore.defaultCalendarForNewEvents;
        
        // Initialize a few internal data structures to store our events
        _events = [[NSArray alloc] init];
        _eventDates = [[NSArray alloc] init];
        _eventDateToEventsDictionary = [[NSDictionary alloc] init];

        // Use GCD so our UI doesn't block while we fetch events
        _fetchPokerEventsQueue = dispatch_queue_create("fetchPokerEventsQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)startBroadcastingModelChangedNotifications {
    _broadcastChangedNotifications = YES;
    
    // We want to listen to the EKEventStoreChangedNotification on the EKEventStore,
    // so that we update our list of events if anything changes in the EKEventStore (such as events added or removed).
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchPokerEvents) name:EKEventStoreChangedNotification object:self.eventStore];
}

- (void)stopBroadcastingModelChangedNotifications {
    _broadcastChangedNotifications = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray*)calendars {
    // Return all event supporting, writable calendars
    NSArray *allEventCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *filteredCalendars = [NSMutableArray array];
    for (EKCalendar *calendar in allEventCalendars) {
        if (calendar.allowsContentModifications) {
            [filteredCalendars addObject:calendar];
        }
    }
    return filteredCalendars;
}

- (NSArray*)calendarTitles {
    NSArray *calendarTitles = [self.calendars valueForKey:@"title"];
    return [calendarTitles sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (EKCalendar*)calendarWithTitle:(NSString*)title {
    for (EKCalendar *calendar in [self calendars]) {
        if ([calendar.title isEqualToString:title]) {
            return calendar;
        }
    }
    return nil;
}

- (void)fetchPokerEvents {
    // Dispatch using GCD so we don't block the UI while fetching events
    dispatch_async(_fetchPokerEventsQueue,^{
        
        // Create NSDates to represent our fetch date range
        // Range is arbitrary, yesterday to two months from now.
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
        oneDayAgoComponents.day = -1;
        NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                                                      toDate:[NSDate date]
                                                     options:0];
        
        NSDateComponents *twoMonthsInFutureComponents = [[NSDateComponents alloc] init];
        twoMonthsInFutureComponents.month = 2;
        NSDate *twoMonthsInFuture = [calendar dateByAddingComponents:twoMonthsInFutureComponents
                                                              toDate:[NSDate date]
                                                             options:0];
        
        // Create a predicate for our date range and the selected calendar
        NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:oneDayAgo
                                                                          endDate:twoMonthsInFuture
                                                                        calendars:@[ self.selectedCalendar ]];
        NSArray *results = [self.eventStore eventsMatchingPredicate:predicate];

        // Filter the results by title
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title matches %@", self.defaultEventTitle];
        results = [results filteredArrayUsingPredicate:titlePredicate];

        // Update our internal data structures
        [self updateDataStructuresWithMatchingEvents:results];

        // Notify our listeners (the UI) on the main thread that our model has changed
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PNVModelChangedNotification object:self];
        });
    });
}

// This should only be called from updateMatchingEvents: because that uses a serial queue
// which ensures only one thread is modifying our data structures.
- (void)updateDataStructuresWithMatchingEvents:(NSArray*)matchingEvents {
    // Sort the passed in events and then store them
    self.events = [matchingEvents sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    
    // Create an array of event start dates
    // Create a dictionary mapping from event start date to events with that start date
    NSMutableArray *eventDates = [NSMutableArray new];
    NSMutableDictionary *eventDictionary = [NSMutableDictionary new];
    
    for (EKEvent *event in self.events) {
        // Create an NSDate (startDate) that only has date components and no time components.
        NSDateComponents *dayMonthYearComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:event.startDate];
        NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:dayMonthYearComponents];
        
        // Get the array of events on a given start date from the dictionary
        NSMutableArray *eventsForStartDate = [eventDictionary objectForKey:startDate];
        
        // If the dictionary doesn't already have an array for this start date
        // then create one and also add the date to our array of dates
        if (eventsForStartDate == nil) {
            eventsForStartDate = [NSMutableArray array];
            [eventDates addObject:startDate];
            [eventDictionary setObject:eventsForStartDate forKey:startDate];
        }
        
        // Finally add the event to the dictionary
        [eventsForStartDate addObject:event];
    }
    
    self.eventDates = [eventDates copy];
    self.eventDateToEventsDictionary = [eventDictionary copy];
}

- (void)addEventWithStartTime:(NSDate*)startDate {
    // Create a new EKEvent and then set the properties on it.
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = self.defaultEventTitle;
    event.timeZone = [NSTimeZone defaultTimeZone];
    event.startDate = startDate;
    event.endDate = [startDate dateByAddingTimeInterval:60*60]; // 1hr long
    event.calendar = self.selectedCalendar;
    
    // Save our new EKEvent
    NSError *err;
    BOOL success = [self.eventStore saveEvent:event
                                         span:EKSpanThisEvent
                                       commit:YES
                                        error:&err];
    if (success == NO) {
        NSLog(@"There was an error saving a new event: %@", err);
    }
}

- (void)increaseVoteOnEvent:(EKEvent*)event {
    int numVotes = [event numberOfVotes];
    [event setNumberOfVotes:numVotes+1];
    
    // Save the event since we modified the notes field.
    NSError *err;
    BOOL success = [self.eventStore saveEvent:event
                                         span:EKSpanThisEvent
                                       commit:YES
                                        error:&err];
    if (success == NO) {
        NSLog(@"There was an error updating the vote count on an event: %@", err);
    }
}

- (NSString*)defaultEventTitle {
    return @"Poker";
}

@end

@implementation EKEvent (NumberOfVoteExtension)

- (int)numberOfVotes {
    return [self.notes intValue];
}

- (void)setNumberOfVotes:(int)newVote {
    // Since vote count is stored in notes, only allow voting if the notes field is empty or only contains the vote count,
    // so that we don't accidentally delete important data in the notes field.
    if (self.notes == nil || [self.notes isEqualToString:@""] || [self.notes isEqualToString:[NSString stringWithFormat:@"%i", self.numberOfVotes]]) {
        self.notes = [NSString stringWithFormat:@"%i", newVote];
    }
}

@end
