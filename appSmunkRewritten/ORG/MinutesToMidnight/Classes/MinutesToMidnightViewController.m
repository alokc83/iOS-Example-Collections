//
//  MinutesToMidnightAppDelegate.m
//  MinutesToMidnight
//
//  Created by apple on 10/1/08.
//  Copyright Amuck LLC 2008. All rights reserved.
//

#import "MinutesToMidnightViewController.h"

@implementation MinutesToMidnightViewController

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


- (void)viewDidLoad {
	[countdownLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:128.0]];
	countdownLabel.text = @"I0A0IN6";
	[super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

-(void)updateLabel {
	NSDate* now = [NSDate date];
	int hour = 23 - [[now dateWithCalendarFormat:nil timeZone:nil] hourOfDay];
	int min = 59 - [[now dateWithCalendarFormat:nil timeZone:nil] minuteOfHour];
	int sec = 59 - [[now dateWithCalendarFormat:nil timeZone:nil] secondOfMinute];
	countdownLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min,sec];
}  

@end
