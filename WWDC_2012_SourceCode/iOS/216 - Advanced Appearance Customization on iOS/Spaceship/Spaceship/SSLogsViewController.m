/*
     File: SSLogsViewController.m
 Abstract: The controller for the Logs view.
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

#import "SSLogsViewController.h"

#import "SSLog.h"
#import "SSLogViewController.h"
#import "SSSpaceship.h"

@interface SSLogsViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteItem;
@end

@implementation SSLogsViewController

#pragma mark - View Controller

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setLogItemsEnabled:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setLogItemsEnabled:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Accessors

- (SSLog *)currentLog
{
    id controller = [[self navigationController] topViewController];
    if (controller == self) {
        return nil;
    } else {
        return [controller log];
    }
}

- (void)setLogItemsEnabled:(BOOL)enabled
{
    [[self leftItem] setEnabled:(enabled && [self canChangeLog:[self leftItem]])];
    [[self rightItem] setEnabled:(enabled && [self canChangeLog:[self rightItem]])];
    [[self deleteItem] setEnabled:enabled];
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLog"]) {
        UITableView *tableView = ([[[self tableView] visibleCells] containsObject:sender] ? [self tableView] : [[self searchDisplayController] searchResultsTableView]);
        NSIndexPath *indexPath = [tableView indexPathForCell:sender];
        NSArray *logs = [self logsForTableView:tableView];
        NSInteger row = [indexPath row];
        SSLog *log = [logs objectAtIndex:row];
        SSLogViewController *controller = [segue destinationViewController];
        [controller setLog:log];
        [controller setToolbarItems:[self toolbarItems]];
    }
}

- (IBAction)done:(UIBarButtonItem *)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)addLog:(UIBarButtonItem *)sender
{
    SSLog *newLog = [[SSLog alloc] init];
    NSMutableArray *logs = [[[self spaceship] logs] mutableCopy];
    [logs addObject:newLog];
    [[self spaceship] setLogs:logs];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[logs count] - 1 inSection:0];
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self tableView] selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
    id controller = [[self navigationController] topViewController];
    if (controller == self) {
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"showLog" sender:cell];
    } else {
        [controller setLog:newLog];
        [self setLogItemsEnabled:YES];
    }
}

- (IBAction)deleteLog:(UIBarButtonItem *)sender
{
    SSLog *currentLog = [self currentLog];
    NSMutableArray *logs = [[[self spaceship] logs] mutableCopy];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[logs indexOfObject:currentLog] inSection:0];
    [logs removeObject:currentLog];
    [[self spaceship] setLogs:logs];
    [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL)canChangeLog:(UIBarButtonItem *)sender
{
    SSLog *currentLog = [self currentLog];
    NSInteger index = [[[self spaceship] logs] indexOfObject:currentLog];
    index += [sender tag];
    return ((index >= 0) && (index < [[[self spaceship] logs] count]));
}

- (IBAction)changeLog:(UIBarButtonItem *)sender
{
    if ([self canChangeLog:sender]) {
        SSLog *currentLog = [self currentLog];
        NSInteger index = [[[self spaceship] logs] indexOfObject:currentLog];
        index += [sender tag];
        SSLog *newLog = [[[self spaceship] logs] objectAtIndex:index];
        id controller = [[self navigationController] topViewController];
        [controller setLog:newLog];
        [self setLogItemsEnabled:YES];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [[self tableView] selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

#pragma mark - Table View

- (NSArray *)logsForTableView:(UITableView *)tableView
{
    NSArray *logs = [[self spaceship] logs];
    if (tableView == [self tableView]) {
    } else {
        UISearchBar *searchBar = [[self searchDisplayController] searchBar];
        NSString *searchString = [searchBar text];
        NSInteger selectedScope = [searchBar selectedScopeButtonIndex];
        if (selectedScope == 0) {
            logs = [logs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"attributedText.string CONTAINS[cd] %@", searchString]];
        } else if (selectedScope == 1) {
            logs = [logs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"dateDescription CONTAINS[cd] %@", searchString]];
        } else {
            logs = [logs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"attributedText.string CONTAINS[cd] %@ OR dateDescription CONTAINS[cd] %@", searchString, searchString]];
        }
    }
    return logs;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self logsForTableView:tableView] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell"];
    if (!cell) {
        cell = [[self tableView] dequeueReusableCellWithIdentifier:@"LogCell"];
    }
    
    NSArray *logs = [self logsForTableView:tableView];
    NSInteger row = [indexPath row];
    SSLog *log = [logs objectAtIndex:row];
    cell.textLabel.text = [log dateDescription];
    return cell;
}

@end
