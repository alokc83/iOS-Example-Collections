

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

#import "RootViewController.h"
#import "DetailViewController.h"
#import "CloudManager.h"

@interface FileRepresentation : NSObject 

@property (nonatomic, readonly) NSString* fileName;
@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, retain) NSURL* previewURL;

- (id)initWithFileName:(NSString*)fileName url:(NSURL*)url;

@end

@implementation FileRepresentation

- (id)initWithFileName:(NSString *)fileName url:(NSURL *)url
{
    self = [super init];
    if (self) {
        _fileName = fileName;
        _url = url;
    }
    
    return self;
}

- (BOOL)isEqual:(FileRepresentation*)object
{
    return [object isKindOfClass:[FileRepresentation class]] && [_fileName isEqual:object.fileName];
}

@end

@implementation RootViewController
{
    NSMetadataQuery* _query;
    NSMetadataQuery* _previewQuery;
    NSMutableArray* _fileList;
    NSMutableDictionary* _previewLoadingOperations;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Notes";
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
        
        _fileList = [[NSMutableArray alloc] init];
        _previewLoadingOperations = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCloudEnabled) name:ICloudStateUpdatedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentFinishedClosing:) name:DocumentFinishedClosingNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateFileList
{
    // Create and start a metadata query for cloud items if enabled.
    // If using local storage, build the file list with NSFileManager APIs.
    
    [_fileList removeAllObjects];
    [_query stopQuery];
    
    if ([[CloudManager sharedManager] isCloudEnabled]) {
        if (_query) {
            [_query startQuery];
        }
        else {
            _query = [[NSMetadataQuery alloc] init];
            [_query setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, NSMetadataQueryUbiquitousDataScope, nil]];
            [_query setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*.note*'", NSMetadataItemFSNameKey]];
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:self selector:@selector(fileListReceived) name:NSMetadataQueryDidFinishGatheringNotification object:_query];
            [notificationCenter addObserver:self selector:@selector(fileListReceived) name:NSMetadataQueryDidUpdateNotification object:_query];
            [_query startQuery];
        }
    }
    else {
        NSURL* documentsDirectoryURL = [[CloudManager sharedManager] documentsDirectoryURL];
        NSArray* localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirectoryURL includingPropertiesForKeys:nil options:0 error:nil];        
        NSURL* dataDirectoryURL = [[CloudManager sharedManager] dataDirectoryURL];        
        for (NSURL* document in localDocuments) {
            if ([document.pathExtension isEqualToString:@"note"]) {
                FileRepresentation* fileRepresentation = [[FileRepresentation alloc] initWithFileName:[[document lastPathComponent] stringByDeletingPathExtension] url:document];
                NSString* previewFilePath = [[dataDirectoryURL path] stringByAppendingPathComponent:[[document lastPathComponent] stringByAppendingPathExtension:@"preview"]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:previewFilePath]) {
                    fileRepresentation.previewURL = [NSURL fileURLWithPath:previewFilePath];
                }
                [_fileList addObject:fileRepresentation];
            }
        }
    }
}

- (void)updateCloudEnabled
{
    // If the iCloud state changed, i.e. a sign out occurred, close any DetailViewControllers which are showing documents and update the file list.
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    else {
        DetailViewController* emptyDetailController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil];
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, emptyDetailController, nil];
    }
    
    [self updateFileList];    
    [self.tableView reloadData];
}

- (void)documentFinishedClosing:(NSNotification*)notification;
{
    if (![[CloudManager sharedManager] isCloudEnabled]) {
        // When using iCloud, we can rely on metadata queries to update the file list, but when using local storage, we'll use this notification to tell us to update.
        [self updateFileList];
        [self loadPreviewImageForIndexPath:[NSIndexPath indexPathForRow:[(DetailViewController*)notification.object representedIndex] inSection:0]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown : YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsSelectionDuringEditing = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"previewcell"];
    
    UIBarButtonItem* plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createFile)];
    self.navigationItem.rightBarButtonItem = plusButton;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self updateFileList];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _fileList = nil;
    [_query stopQuery];
    _query = nil;
}

- (void)createFile
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"New File" message:@"Enter file name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)selectFileAtIndexPath:(NSIndexPath*)indexPath create:(BOOL)create
{
    DetailViewController* detailViewController = [[DetailViewController alloc] initWithFileURL:[[_fileList objectAtIndex:indexPath.row] url] createNewFile:create];
    detailViewController.representedIndex = indexPath.row;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, detailViewController, nil];
    }
    else {
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString* fileName = [[alertView textFieldAtIndex:0] text];
        NSURL* fileURL = [[[CloudManager sharedManager] documentsDirectoryURL] URLByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"note"]];
        FileRepresentation* fileRepresentation = [[FileRepresentation alloc] initWithFileName:fileName url:fileURL];
        [_fileList addObject:fileRepresentation];
        [_fileList sortUsingComparator:^(FileRepresentation* firstObject, FileRepresentation* secondObject) {
            return [firstObject.fileName compare:secondObject.fileName];
        }];
        NSInteger insertionRow = [_fileList indexOfObject:fileRepresentation];
        NSIndexPath* newFileIndexPath = [NSIndexPath indexPathForRow:insertionRow inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newFileIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView selectRowAtIndexPath:newFileIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self selectFileAtIndexPath:newFileIndexPath create:YES];
    }
}

- (void)fileListReceived
{
    // Update our file list from the received metadata query.
    // When discovering preview files, initiate asynchronous loading of the images.
    
    NSIndexPath* currentSelection = [self.tableView indexPathForSelectedRow];
    NSString* selectedFileName = currentSelection ? [[_fileList objectAtIndex:currentSelection.row] fileName] : nil;
    NSInteger newSelectionRow = currentSelection ? currentSelection.row : NSNotFound;
    NSMutableArray* oldFileList = [_fileList mutableCopy];
    
    [_fileList removeAllObjects];
    NSArray* results = [[_query results] sortedArrayUsingComparator:^(NSMetadataItem* firstObject, NSMetadataItem* secondObject) {
        NSString* firstFileName = [firstObject valueForAttribute:NSMetadataItemFSNameKey];
        NSString* secondFileName = [secondObject valueForAttribute:NSMetadataItemFSNameKey];
        NSComparisonResult result = [firstFileName.pathExtension compare:secondFileName.pathExtension];
        return result == NSOrderedSame ? [firstFileName compare:secondFileName] : result;
    }];
    
    for (NSMetadataItem* result in results) {
        NSURL* fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        NSString* fileName = [result valueForAttribute:NSMetadataItemDisplayNameKey];
        
        if ([[fileURL pathExtension] isEqualToString:@"note"]) {
            if ([selectedFileName isEqualToString:fileName]) {
                newSelectionRow = [_fileList count];
            }
            
            FileRepresentation* fileRepresentation = [[FileRepresentation alloc] initWithFileName:fileName url:fileURL];
            [_fileList addObject:fileRepresentation];
        }
        else if ([[fileURL pathExtension] isEqualToString:@"preview"]) {
            [_fileList enumerateObjectsUsingBlock:^(FileRepresentation* fileRepresentation, NSUInteger index, BOOL* stop) {
                if ([[fileName stringByDeletingPathExtension] isEqualToString:fileRepresentation.fileName]) {
                    if (!fileRepresentation.previewURL) {
                        fileRepresentation.previewURL = [result valueForAttribute:NSMetadataItemURLKey];
                        [self loadPreviewImageForIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    }
                    
                    *stop = YES;
                }
            }];
        }
    }
    
    [_fileList sortUsingComparator:^(FileRepresentation* file1, FileRepresentation* file2) {
        return [file1.fileName compare:file2.fileName];
    }];
    
    NSMutableArray* insertionRows = [[NSMutableArray alloc] init];
    NSMutableArray* deletionRows = [[NSMutableArray alloc] init];
    
    [_fileList enumerateObjectsUsingBlock:^(FileRepresentation* newFile, NSUInteger newIndex, BOOL* stop) {        
        if (![oldFileList containsObject:newFile]) {
            [insertionRows addObject:[NSIndexPath indexPathForRow:newIndex inSection:0]];
        }
    }];
    
    [oldFileList enumerateObjectsUsingBlock:^(FileRepresentation* oldFile, NSUInteger oldIndex, BOOL* stop) {
        if (![_fileList containsObject:oldFile]) {
            [deletionRows addObject:[NSIndexPath indexPathForRow:oldIndex inSection:0]];
        }
    }];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deletionRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView insertRowsAtIndexPaths:insertionRows withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    if (newSelectionRow != NSNotFound) {
        NSIndexPath* selectionPath = [NSIndexPath indexPathForRow:newSelectionRow inSection:0];
        [self.tableView selectRowAtIndexPath:selectionPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)loadPreviewImageForIndexPath:(NSIndexPath*)indexPath
{
    // Initiate an asynchronous loading of a preview image which uses coordinated file access.
    // Keep a reference to the loading operation itself so that it can be cancelled if no longer needed.
    
    FileRepresentation* fileRepresentation = _fileList[indexPath.row];
    NSBlockOperation* previewLoadingOperation = [NSBlockOperation blockOperationWithBlock:^(void) {
        UITableViewCell* visibleCell = [self.tableView cellForRowAtIndexPath:indexPath];
        visibleCell.imageView.image = [UIImage imageWithContentsOfFile:[fileRepresentation.previewURL path]];
        [visibleCell setNeedsLayout];
        [_previewLoadingOperations removeObjectForKey:indexPath];
    }];
    _previewLoadingOperations[indexPath] = previewLoadingOperation;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateReadingItemAtURL:fileRepresentation.previewURL options:0 error:nil byAccessor:^(NSURL* previewURL) {
            [[NSOperationQueue mainQueue] addOperation:previewLoadingOperation];
        }];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"previewcell" forIndexPath:indexPath];

    // Configure the cell.
    FileRepresentation* fileRepresentation = _fileList[indexPath.row];
    cell.textLabel.text = fileRepresentation.fileName;
    cell.imageView.image = nil;
    [self loadPreviewImageForIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If we're done with the cell, we can cancel any outstanding loading operations.
    [_previewLoadingOperations[indexPath] cancel];
    [_previewLoadingOperations removeObjectForKey:indexPath];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[CloudManager sharedManager] isCloudEnabled] ? @"iCloud Notes" : @"Local Notes:";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectFileAtIndexPath:indexPath create:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform an asynchronous coordinated delete of the file and its preview.
    
    NSURL* fileURL = [[_fileList objectAtIndex:indexPath.row] url];
    NSURL* previewURL = [[_fileList objectAtIndex:indexPath.row] previewURL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        [fileCoordinator coordinateWritingItemAtURL:fileURL options:NSFileCoordinatorWritingForDeleting error:nil byAccessor:^(NSURL* writingURL) {
            NSFileManager* fileManager = [[NSFileManager alloc] init];
            [fileManager removeItemAtURL:writingURL error:nil];
        }];
        
        if (previewURL) {
            [fileCoordinator coordinateWritingItemAtURL:previewURL options:NSFileCoordinatorWritingForDeleting error:nil byAccessor:^(NSURL* writingURL) {
                NSFileManager* fileManager = [[NSFileManager alloc] init];
                [fileManager removeItemAtURL:writingURL error:nil];
            }];
        }
        
    });
    [_fileList removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ![indexPath isEqual:[tableView indexPathForSelectedRow]];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPad" bundle:nil], nil];
    }
    
    [super setEditing:editing animated:animated];
}

@end
