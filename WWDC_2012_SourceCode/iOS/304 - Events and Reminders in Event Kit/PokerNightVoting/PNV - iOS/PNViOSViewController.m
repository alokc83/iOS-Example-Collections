//     File: PNViOSViewController.m
// Abstract: View Controller for iOS
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

#import "PNViOSViewController.h"

#import <EventKitUI/EventKitUI.h>

@implementation PNViOSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.model = [[PNVModel alloc] init];
    self.title = self.model.selectedCalendar.title;
        
    // Start listening for changes
    [self.model startBroadcastingModelChangedNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:PNVModelChangedNotification object:self.model];
    
    // Fetch the poker events
    // When it is done it will send a PNVModelChangedNotification, which updates our view.
    [self.model fetchPokerEvents];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Stop listening for changes
    [self.model stopBroadcastingModelChangedNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    self.model = nil;
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
#pragma mark Helper methods

- (EKEvent *)eventAtIndexPath:(NSIndexPath*)indexPath {
    // Given an index path from our table view, figure out which event is at that path
    NSDate *date = [self.model.eventDates objectAtIndex:indexPath.section];
    NSMutableArray *eventsWithStartDate = [self.model.eventDateToEventsDictionary objectForKey:date];
    return [eventsWithStartDate objectAtIndex:indexPath.row];
}

- (void)refreshView {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark IB methods

- (IBAction)addTime:(id)sender {
    // Show the EKEventEditViewController
    EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
    controller.eventStore = self.model.eventStore;
    controller.editViewDelegate = self;
    
    EKEvent *event = [EKEvent eventWithEventStore:self.model.eventStore];
    event.title = self.model.defaultEventTitle;
    controller.event = event;
        
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)showCalendarChooser:(id)sender {
    // Show the EKCalendarChooser
    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleSingle
                                                                              displayStyle:EKCalendarChooserDisplayWritableCalendarsOnly
                                                                                eventStore:self.model.eventStore];
    calendarChooser.showsDoneButton = YES;
    calendarChooser.showsCancelButton = NO;
    calendarChooser.delegate = self;
    
    NSSet *selectedCalendars = self.model.selectedCalendar ? [NSSet setWithObject:self.model.selectedCalendar] : nil;
    calendarChooser.selectedCalendars = selectedCalendars;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calendarChooser];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)increaseVote:(UIButton *)sender {
    UITableViewCell* cell = (UITableViewCell*)sender.superview;
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    EKEvent *event = [self eventAtIndexPath:indexPath];
    
    [self.model increaseVoteOnEvent:event];
}

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.eventDates.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *date = [self.model.eventDates objectAtIndex:section];
    return [[self.model.eventDateToEventsDictionary objectForKey:date] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    static NSDateFormatter *mediumDateDateFormatter;
    if (!mediumDateDateFormatter) {
        mediumDateDateFormatter = [[NSDateFormatter alloc] init];
        mediumDateDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        mediumDateDateFormatter.timeStyle = NSDateFormatterNoStyle;
        mediumDateDateFormatter.doesRelativeDateFormatting = YES;
    }
    
    NSString *formattedDateString = [mediumDateDateFormatter stringFromDate:[self.model.eventDates objectAtIndex:section]];
    return formattedDateString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PokerNightVotingCell"];
    
    // Get the EKEvent.
    EKEvent *event = [self eventAtIndexPath:indexPath];
    
    // Configure the cell.
    cell.textLabel.text = event.startDateDescription;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    // Create the vote button
    NSString *title = [NSString stringWithFormat:@"%i +", event.numberOfVotes];
    UIButton *voteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect frame = CGRectMake(0.0, 0.0, 45, 30);
    voteButton.frame = frame;
    [voteButton setTitle:title forState:UIControlStateNormal];
    [voteButton addTarget:self action:@selector(increaseVote:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = voteButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKEventViewController* controller = [[EKEventViewController alloc] init];
    controller.event = [self eventAtIndexPath:indexPath];
    controller.allowsEditing = YES;
    controller.delegate = self;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark EKEventEditViewDelegate Protocol Methods

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (action != EKEventEditViewActionCanceled) {
        // Update our events, since we added a new event.
        [self.model fetchPokerEvents];
    }
}

- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
    return self.model.selectedCalendar;
}

#pragma mark -
#pragma mark EKEventViewDelegate Protocol Methods

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
    // Update our events, since the user may have edited the event they were viewing.
    [self.model fetchPokerEvents];
}

#pragma mark -
#pragma mark EKCalendarChooserDelegate Protocol Methods

// Called whenever the selection is changed by the user
- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    self.model.selectedCalendar = calendarChooser.selectedCalendars.anyObject;
    self.title = self.model.selectedCalendar.title;
}

// These are called when the corresponding button is pressed to dismiss the
// controller. It is up to the recipient to dismiss the chooser.
- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    // Update our events, since the selected calendar may have changed.
    [self.model fetchPokerEvents];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    // Update our events, since the selected calendar may have changed.
    [self.model fetchPokerEvents];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation EKEvent (Subtitle)

- (NSString *) startDateDescription {
    if ([self isAllDay]) {
        return @"all-day";
    }
    else {
        static NSDateFormatter *shortTimeDateFormatter;
        if (!shortTimeDateFormatter) {
            shortTimeDateFormatter = [[NSDateFormatter alloc] init];
            [shortTimeDateFormatter setDateStyle:NSDateFormatterNoStyle];
            [shortTimeDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSString *formattedDateString = [shortTimeDateFormatter stringFromDate:[self startDate]];
        
        return formattedDateString;
    }
}

@end