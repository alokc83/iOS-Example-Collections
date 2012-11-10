
/*
     File: DetailViewController.m
 Abstract: 
 
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

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "Person.h"
#import "StateLocation.h"
#import "CoreDataController.h"
#import <UIKit/UIKit.h>

#define kTextFieldTag 99

@implementation DetailViewController
{
    Person *person;
	NSUndoManager *undoManager;
    __block NSMutableDictionary *isoCodeToState;
    __block NSUInteger numStates;
    __block NSArray *allStates;
    UIPickerView *pickerView;
    UITextField *_editingField;
}

@synthesize person, undoManager;


#pragma mark -
#pragma mark View lifecycle

- (void)updateView:(NSNotification *)notification
{
    // an iCloud merge or update has occurred, update our view content (if applicable)
    //
    NSDictionary *ui = [notification userInfo];
    
    NSManagedObjectID *personID = [person objectID];
    if (personID != nil)
    {
        BOOL shouldReload = ([ui objectForKey:NSInvalidatedAllObjectsKey] != nil);
        BOOL wasInvalidated = ([ui objectForKey:NSInvalidatedAllObjectsKey] != nil);
        
        NSArray *interestingKeys = [NSArray arrayWithObjects:
                                        NSUpdatedObjectsKey,
                                        NSRefreshedObjectsKey,
                                        NSInvalidatedObjectsKey,
                                    nil];
        
        // check if any of the keys we care about will constitute a view update
        for (NSString *key in interestingKeys)
        {
            NSSet *collection = [ui objectForKey:key];
            for (NSManagedObject *managedObject in collection)
            {
                if ([managedObject.objectID isEqual:personID])
                {
                    if ([key isEqual:NSInvalidatedObjectsKey])
                    {
                        wasInvalidated = YES;
                    }
                    shouldReload = YES;
                    break;
                }
            }
            if (shouldReload)
            {
                break;
            }
        }
        
        if (shouldReload)
        {
            if (wasInvalidated)
            {
                // if the object was invalidated, it is no longer a part of our MOC
                // we need a new MO for the objectID we care about
                // this generally only happens if the object was released to rc 0,
                // the persistent store removed, or the MOC reset
                //
                NSManagedObjectContext *moc = self.person.managedObjectContext;
                self.person = (Person *)[moc objectWithID:personID];
            }
            
            // finally, reload our table with the updated managed object
            [self.tableView reloadData];
        }
    }
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    CGRect tableViewFrame = self.view.frame;
    tableViewFrame.origin.y = 0;
    _tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [self.view bringSubviewToFront:_tableView];
	
	// configure the title, title bar, and table view
	self.title = @"Info";
    
    // place our own edit button to the right of the nav bar
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                   target:self
                                                   action:@selector(edit:)];
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateView:)
                                                 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                               object:appDelegate.coreDataController.psc];
    
    NSManagedObjectContext *moc = appDelegate.coreDataController.mainThreadContext;
    [moc performBlockAndWait:^{
        isoCodeToState = [[NSMutableDictionary alloc] init];
        NSFetchRequest *stateFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"StateLocation"];
        NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        [stateFetchRequest setSortDescriptors:[NSArray arrayWithObject:nameSort]];
        NSError *error = nil;
        NSArray *stateLocations = [moc executeFetchRequest:stateFetchRequest error:&error];
        if (error) {
            NSLog(@"Error fetching states for picker view: %@", error);
        }
        
        allStates = stateLocations;
        numStates = [stateLocations count];
        for (StateLocation *state in stateLocations) {
            [isoCodeToState setObject:state forKey:state.isoCode];
        }
    }];
    
    //show the picker view
    pickerView = [[UIPickerView alloc] init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
}

// called when the "Edit" button on the right of the navigation bar is tapped
- (void)edit:(id)sender {
    if (_isEditing) {
        //save
        _isEditing = NO;
        
        [UIView beginAnimations:@"PickerOut" context:NULL];
        CGRect newFrame = pickerView.frame;
        newFrame.origin.y = self.view.frame.size.height;
        pickerView.frame = newFrame;
        [UIView commitAnimations];
        
        [_editingField resignFirstResponder];
        _editingField = nil;
        
        [pickerView removeFromSuperview];
        
        [person.managedObjectContext performBlock:^{
            if ([person.managedObjectContext hasChanges]) {
                NSError *error = nil;
                if (NO == [person.managedObjectContext save:&error]) {
                    NSLog(@"Error saving changes: %@", error);
                }
                
            }
        }];
        
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                      target:self
                                                      action:@selector(edit:)];
    } else {
        _isEditing = YES;
        
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                      target:self
                                                      action:@selector(edit:)];
    
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UITextField *editField = (UITextField *)[cell viewWithTag:99];
        [editField becomeFirstResponder];
        
        CGRect newFrame = pickerView.frame;
        newFrame.origin.y = self.view.frame.size.height;
        pickerView.frame = newFrame;
        [self.view addSubview:pickerView];
        [self.view bringSubviewToFront:pickerView];
        
        [UIView beginAnimations:@"PickerIn" context:NULL];
        newFrame.origin.y = self.view.frame.size.height - pickerView.frame.size.height;
        pickerView.frame = newFrame;
        [UIView commitAnimations];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // redisplay the data
    [self.tableView reloadData];
    
	[self updateRightBarButtonItemState];
}

- (void)updateRightBarButtonItemState
{
	// enable the right bar button item for save only if the fields are valid, and the managed object is ready
    BOOL fieldsRequired = (person.lastName.length > 0 && person.firstName.length > 0 && person.emailAddress.length > 0);
    self.navigationItem.rightBarButtonItem.enabled = fieldsRequired && [person validateForUpdate:nil];
}	


#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = nil;
    if (indexPath.row == 3) {
        cell = [_tableView dequeueReusableCellWithIdentifier:@"PickerCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"PickerCell"];
        }

    } else {
        cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            
            CGRect cellFrame = cell.contentView.frame;
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(cellFrame.origin.x + 85.0,
                                                                                   cellFrame.origin.y + 10.0,
                                                                                   cellFrame.size.width - 90.0,
                                                                                   25.0)];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            textField.delegate = self;
            textField.returnKeyType = UIReturnKeyDone;
            textField.tag = kTextFieldTag;
            [cell.contentView addSubview:textField];
        }

    }

	switch (indexPath.row)
    {
        case 0: 
        {
            cell.textLabel.text = @"First Name";
            UITextField *textField = (UITextField *)[cell.contentView viewWithTag:kTextFieldTag];
            textField.text = person.firstName;
			break;
        }
        case 1: 
		{
            cell.textLabel.text = @"Last Name";
            UITextField *textField = (UITextField *)[cell.contentView viewWithTag:kTextFieldTag];
            textField.text = person.lastName;
            break;
        }
        case 2:
        {
            cell.textLabel.text = @"Email Address";
            UITextField *textField = (UITextField *)[cell.contentView viewWithTag:kTextFieldTag];
            textField.text = person.emailAddress;
            break;
        }
        case 3:
        {
            cell.textLabel.text = @"State";
            cell.detailTextLabel.text = ((StateLocation *)[isoCodeToState objectForKey:person.stateISOCode]).name;
            break;
        }
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isEditing) {
        if (indexPath.row == 3) {
            //add the picker view and make the tableview smaller
            CGRect tableViewFrame = _tableView.frame;
            tableViewFrame.size.height -= pickerView.frame.size.height;
            CGRect pickerViewFrame = pickerView.frame;
            pickerViewFrame.origin.y = tableViewFrame.size.height;
            pickerView.frame = pickerViewFrame;
            
            [_editingField resignFirstResponder];
            _editingField = nil;
            
            [self.view addSubview:pickerView];
            [self.view bringSubviewToFront:pickerView];
        }
    }
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


#pragma mark -
#pragma mark Undo support

- (void)setUpUndoManager
{
	/*
	 If the person's managed object context doesn't already have an undo manager,
     then create one and set it for the context and self.
	 The view controller needs to keep a reference to the undo manager it creates
     so that it can determine whether to remove the undo manager when editing finishes.
	 */
	if (person.managedObjectContext.undoManager == nil)
    {
		NSUndoManager *anUndoManager = [[NSUndoManager alloc] init];
		[anUndoManager setLevelsOfUndo:3];
		self.undoManager = anUndoManager;
		
		person.managedObjectContext.undoManager = undoManager;
	}
	
	// register as an observer of the person's context's undo manager
	NSUndoManager *personUndoManager = person.managedObjectContext.undoManager;
	
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	[dnc addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:personUndoManager];
	[dnc addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:personUndoManager];
}

- (void)cleanUpUndoManager
{
	// remove ourselves as an observer
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// reset our undo stack
    if (person.managedObjectContext.undoManager == undoManager)
    {
		person.managedObjectContext.undoManager = nil;
		self.undoManager = nil;
	}		
}

- (NSUndoManager *)undoManager
{
	return person.managedObjectContext.undoManager;
}

- (void)undoManagerDidUndo:(NSNotification *)notification
{
	[self.tableView reloadData];
	[self updateRightBarButtonItemState];
}

- (void)undoManagerDidRedo:(NSNotification *)notification
{
	[self.tableView reloadData];
	[self updateRightBarButtonItemState];
}

// The view controller must be first responder in order to be able to receive
// shake events for undo. It should resign first responder status when it disappears.
//
- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	[self becomeFirstResponder];
    
    //cache the states information
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
	[self resignFirstResponder];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *editField = (UITextField *)[cell viewWithTag:99];
    person.firstName = editField.text;
    
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    editField = (UITextField *)[cell viewWithTag:99];
    person.lastName = editField.text;
    
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    editField = (UITextField *)[cell viewWithTag:99];
    person.emailAddress = editField.text;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self updateRightBarButtonItemState];

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setUpUndoManager];
    _editingField = textField;
}

#pragma mark - UIPickerView Datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return numStates;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return ((StateLocation *)[allStates objectAtIndex:row]).name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    person.stateISOCode = ((StateLocation *)[allStates objectAtIndex:row]).isoCode;
    
    //update the table cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end

