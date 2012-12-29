//
//  TVCDetails.m
//  Dial4
//
//  Created by Bear Cahill on 12/21/09.
//  Copyright 2009 Brainwash Inc.. All rights reserved.
//

#import "TVCDetails.h"


@implementation TVCDetails

@synthesize person;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	[self setTitle:@"Details"];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)callThisNumber:(NSString*)phoneNum
{
	NSString *url = [NSString stringWithFormat:@"tel:%@", phoneNum];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
													 kABPersonPhoneProperty);
	
    int retNum = ABMultiValueGetCount(phoneNumbers)+2; // add 2 for names
	CFRelease(phoneNumbers);
	return retNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DetailsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
	
	if (indexPath.row < 2)
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	else 
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

	NSString *title;
	NSString *text;
	switch (indexPath.row)
	{
		case 0:
			title = @"First Name";
			text = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
			break;
		case 1:
			title = @"Last Name";
			text = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
			break;
		default:
			title = @"Phone";
			ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
															 kABPersonPhoneProperty);
			if (phoneNumbers && ABMultiValueGetCount(phoneNumbers) > 0)
			{
				text = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, indexPath.row-2);
				CFRelease(phoneNumbers);
			}
			
			break;
	}
	[[cell textLabel] setText:title];
	[[cell detailTextLabel] setText:text];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row > 1)
		[self callThisNumber:[[[tableView cellForRowAtIndexPath:indexPath] detailTextLabel] text]];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	CFRelease(person);
}


@end

