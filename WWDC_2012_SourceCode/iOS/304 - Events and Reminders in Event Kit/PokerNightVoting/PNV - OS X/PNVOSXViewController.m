//     File: PNVOSXViewController.m
// Abstract: View Controller for OS X
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

#import "PNVOSXViewController.h"

#import "PNVModel.h"
#import <EventKit/EventKit.h>

@implementation PNVOSXViewController

- (id)init {
    self = [super init];
    if (self) {
        _model = [[PNVModel alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Stop listening for changes
    [self.model stopBroadcastingModelChangedNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    // Update the calendar list and update the selected calendar based on the model's selected calendar value
    [self.calendarList removeAllItems];
    [self.calendarList addItemsWithTitles:self.model.calendarTitles];
    [self.calendarList selectItemWithTitle:self.model.selectedCalendar.title];
           
    // Set the content for the array controller to our model's event array
    self.arrayController.content = self.model.events;
    
    // Set the date picker to the next hour
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger dayFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
	NSDateComponents *components = [calendar components:dayFlags fromDate:[NSDate date]];
    if (components.hour < 23) {
        [components setHour:components.hour + 1];
    }
    [self.datePicker setDateValue:[calendar dateFromComponents:components]];
    
    // Sort the table view baesd on startDate
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    [self.eventTableView setSortDescriptors:@[ sortDescriptor ]];
    
    // Start listening for changes
    [self.model startBroadcastingModelChangedNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:PNVModelChangedNotification object:self.model];
    
    // Fetch the poker events
    // When it is done it will send a PNVModelChangedNotification, which updates our view.
    [self.model fetchPokerEvents];
}

- (void)refreshView {
    // Update the array that backs our table of events
    self.arrayController.content = self.model.events;
    [self.eventTableView deselectAll:self];
}

- (IBAction)addTime:(id)sender {
    [self.model addEventWithStartTime:self.datePicker.dateValue];
}

- (void)increaseVote:(id)sender {
    // Figure out which row was clicked, get that event, and then increase its vote count.
    if ([sender isKindOfClass:[NSTableView class]]) {
        NSTableView *table = (NSTableView*)sender;
        NSInteger clickedRow = [table clickedRow];
        EKEvent *event = self.arrayController.arrangedObjects[clickedRow];
        [self.model increaseVoteOnEvent:event];
    }
}

- (IBAction)selectedCalendarChanged:(id)sender {
    // When the selected calendar in the drop down is changed,
    // we should update the model's selected calendar property.
    NSString *selectedTitle = self.calendarList.selectedItem.title;
    self.model.selectedCalendar = [self.model calendarWithTitle:selectedTitle];
    
    // We should refetch the poker events with our new selected calendar
    [self.model fetchPokerEvents];
}

@end
