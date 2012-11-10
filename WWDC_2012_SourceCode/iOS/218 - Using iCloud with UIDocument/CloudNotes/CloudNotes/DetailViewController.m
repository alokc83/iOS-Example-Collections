

/*
 
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

#import "DetailViewController.h"
#import "RootViewController.h"
#import "DocumentStatusView.h"
#import "NoteTableCell.h"

NSString* const DocumentFinishedClosingNotification = @"DocumentFinishedClosingNotification";

@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *popoverController;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UITableView* tableView;

- (void)showConflictButton;
- (void)hideConflictButton;

@end

@implementation DetailViewController
{
    NoteDocument* _document;
    BOOL _createFile;
    UITableView* _tableView;
    DocumentStatusView* _statusView;
    UIBarButtonItem* _conflictButton;
    NSIndexPath* _imageEditingIndexPath;
}

@synthesize popoverController;
@synthesize representedIndex;

- (id)initWithFileURL:(NSURL*)url createNewFile:(BOOL)createNewFile
{
    NSString* nibName = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"DetailViewController_iPad" : @"DetailViewController_iPhone";
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        _document = [[NoteDocument alloc] initWithFileURL:url];
        self.title = [[url lastPathComponent] stringByDeletingPathExtension];
        _document.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentStateChanged) name:UIDocumentStateChangedNotification object:_document];
        _createFile = createNewFile;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _document.delegate = nil;
    if (self.splitViewController.delegate == self) {
        self.splitViewController.delegate = nil;
    }
}

#pragma mark Document Handling Methods

- (void)documentStateChanged
{
    UIDocumentState state = _document.documentState;
    [_statusView setDocumentState:state];
    
    if (state & UIDocumentStateEditingDisabled) {
        _tableView.userInteractionEnabled = NO;
    }
    else {
        _tableView.userInteractionEnabled = YES;
    }
    
    if (state & UIDocumentStateInConflict) {
        [self showConflictButton];
    }
    else {
        [self hideConflictButton];
    }
}

- (void)noteDocumentContentsUpdated:(NoteDocument *)noteDocument
{
    [_tableView reloadData];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [_document setText:textView.text forNote:[[_tableView indexPathForRowAtPoint:[textView convertPoint:textView.bounds.origin toView:_tableView]] row]];
    [_document updateChangeCount:UIDocumentChangeDone];
}

- (void)addNote
{
    [_document addNote];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_tableView numberOfRowsInSection:0] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Note Image Editing

- (void)handleImageTapForCell:(NoteTableCell*)cell
{
    _imageEditingIndexPath = [self.tableView indexPathForCell:cell];
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [[[self.tableView cellForRowAtIndexPath:_imageEditingIndexPath] imageView] setImage:image];
    [[self.tableView cellForRowAtIndexPath:_imageEditingIndexPath] setNeedsLayout];
    [_document setImage:image forNote:_imageEditingIndexPath.row];
    [_document updateChangeCount:UIDocumentChangeDone];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    _imageEditingIndexPath = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    _imageEditingIndexPath = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Conflict Handling

- (void)showConflictButton
{
    if (![self.toolbar.items containsObject:_conflictButton]) {
        self.toolbar.items = [self.toolbar.items arrayByAddingObject:_conflictButton];
    }
}

- (void)hideConflictButton
{
    if ([self.toolbar.items containsObject:_conflictButton]) {
        NSMutableArray* barItems = [self.toolbar.items mutableCopy];
        [barItems removeObject:_conflictButton];
        self.toolbar.items = barItems;
    }
}

- (void)conflictButtonPushed
{
    // Any automatic merging logic or presentation of conflict resolution UI should go here.
    // For this sample, I'll just pick the current version and mark the conflict versions as resolved.
    
    for (NSFileVersion* conflictVersion in [NSFileVersion unresolvedConflictVersionsOfItemAtURL:_document.fileURL]) {
        conflictVersion.resolved = YES;
    }
    [NSFileVersion removeOtherVersionsOfItemAtURL:_document.fileURL error:nil];
}

#pragma mark View Controller methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup the view that shows us whether we're in a good state, error state, or conflict state.
    _statusView = [[DocumentStatusView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    UIBarButtonItem* statusItem = [[UIBarButtonItem alloc] initWithCustomView:_statusView];
    
    // Setup the button that initiates conflict resolution.
    _conflictButton = [[UIBarButtonItem alloc] initWithTitle:@"Resolve Conflicts" style:UIBarButtonItemStyleBordered target:self action:@selector(conflictButtonPushed)];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.toolbar.items = [self.toolbar.items arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:statusItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)], nil]];
    }
    else {
        self.toolbar.items = [self.toolbar.items arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:statusItem, nil]];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)];
    }
    
    [_tableView registerClass:[NoteTableCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Create the file, or open it, as appropriate.
    if (_createFile) {
        [_document saveToURL:_document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:nil];
        _createFile = NO;
    }
    else if (_document.documentState & UIDocumentStateClosed) {
        [_document openWithCompletionHandler:^(BOOL success) {
            [_tableView reloadData];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // _imageEditingIndexPath is set when we bring up the image picker to change a note's image.
    // No need to close the document if that's the case.
    // Otherwise, the user is navigating away from us and we should close the document.
    // We also post a notification when finished so that RootViewController can update its preview image if necessary.
    if (!_imageEditingIndexPath) {
        [_document closeWithCompletionHandler:^(BOOL success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DocumentFinishedClosingNotification object:self];
        }];
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_document numberOfNotes];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textView.text = [_document textForNote:indexPath.row];
    cell.textView.delegate = self;
    cell.imageView.image = [_document imageForNote:indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark UISplitViewControllerDelegate methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown : YES;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"Notes";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popoverController = nil;
}

@end
