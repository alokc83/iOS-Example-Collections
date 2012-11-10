

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

#import "NoteDocument.h"
#import "CloudManager.h"

enum {
    NoteDocumentContentTypeText,
    NoteDocumentContentTypeImage
};
typedef NSUInteger NoteDocumentContentType;

@implementation NoteDocument
{
    NSString* _text;
    id <NoteDocumentDelegate> __weak _delegate;
    NSFileWrapper* _fileWrapper;
    NSMutableArray* _index;
}

@synthesize delegate = _delegate;

#pragma mark Basic Reading and Writing

- (void)setupEmptyDocument
{
    // Create the master file wrapper and populate it with one sub file wrapper, which is our index file.
    
    _index = [NSMutableArray array];
    NSFileWrapper* indexFile = [[NSFileWrapper alloc] initRegularFileWithContents:[NSKeyedArchiver archivedDataWithRootObject:_index]];
    indexFile.preferredFilename = @"index";
    _fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:@{@"index" : indexFile}];
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    // Make these contents our new master file wrapper and load the index file.
    
    if (contents) {
        _fileWrapper = contents;
        _index = [[NSKeyedUnarchiver unarchiveObjectWithData:[[[_fileWrapper fileWrappers] valueForKey:@"index"] regularFileContents]] mutableCopy];
        if (!_index) {
            _index = [NSMutableArray array];
        }
    }
    else {
        [self setupEmptyDocument];
    }
    
    if ([_delegate respondsToSelector:@selector(noteDocumentContentsUpdated:)]) {
        [_delegate noteDocumentContentsUpdated:self];
    }
    
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    // Snapshot our master file wrapper and return that.
    
    if (!_fileWrapper) {
        [self setupEmptyDocument];
    }
    return [[NSFileWrapper alloc] initDirectoryWithFileWrappers:_fileWrapper.fileWrappers];
}

#pragma Document Editing

- (NSFileWrapper*)textFileWrapperForNote:(NSInteger)noteIndex
{
    return [[_fileWrapper fileWrappers] valueForKey:[NSString stringWithFormat:@"%@.txt", _index[noteIndex]]];
}

- (NSFileWrapper*)imageFileWrapperForNote:(NSInteger)noteIndex
{
    return [[_fileWrapper fileWrappers] valueForKey:[NSString stringWithFormat:@"%@.jpg", _index[noteIndex]]];
}

- (void)setFileWrapper:(NSFileWrapper*)fileWrapper forNote:(NSInteger)noteIndex forContentType:(NoteDocumentContentType)type
{
    NSFileWrapper* existingFileWrapper = type == NoteDocumentContentTypeText ? [self textFileWrapperForNote:noteIndex] : [self imageFileWrapperForNote:noteIndex];
    fileWrapper.preferredFilename = existingFileWrapper.preferredFilename;
    [_fileWrapper removeFileWrapper:existingFileWrapper];    
    [_fileWrapper addFileWrapper:fileWrapper];
}

- (NSString*)textForNote:(NSInteger)noteIndex
{
    NSData* fileData = [[self textFileWrapperForNote:noteIndex] regularFileContents];
    return [fileData length] > 0 ? [NSString stringWithUTF8String:[fileData bytes]] : @"";
}

- (void)setText:(NSString*)text forNote:(NSInteger)noteIndex
{
    NSFileWrapper* newFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[NSData dataWithBytes:[text UTF8String] length:[text length]]];
    [self setFileWrapper:newFileWrapper forNote:noteIndex forContentType:NoteDocumentContentTypeText];
}

- (UIImage*)imageForNote:(NSInteger)noteIndex
{
    NSData* fileData = [[self imageFileWrapperForNote:noteIndex] regularFileContents];
    return [UIImage imageWithData:fileData];
}

- (void)setImage:(UIImage*)image forNote:(NSInteger)noteIndex
{
    NSFileWrapper* newFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:UIImageJPEGRepresentation(image, 1)];
    [self setFileWrapper:newFileWrapper forNote:noteIndex forContentType:NoteDocumentContentTypeImage];
}

- (NSInteger)numberOfNotes
{
    return [_index count];
}

- (void)addNote
{
    NSUUID  *UUID = [NSUUID UUID];
    NSString* noteUUID = [UUID UUIDString];
    [_index addObject:noteUUID];
    
    NSFileWrapper* textFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[NSData dataWithBytes:"" length:0]];
    textFileWrapper.preferredFilename = [noteUUID stringByAppendingPathExtension:@"txt"];
    [_fileWrapper addFileWrapper:textFileWrapper];
    
    NSFileWrapper* imageFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:UIImageJPEGRepresentation([UIImage imageNamed:@"pencil-icon.jpg"], 1)];
    imageFileWrapper.preferredFilename = [noteUUID stringByAppendingPathExtension:@"jpg"];
    [_fileWrapper addFileWrapper:imageFileWrapper];
    
    [_fileWrapper removeFileWrapper:[[_fileWrapper fileWrappers] valueForKey:@"index"]];
    NSFileWrapper* newIndexWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[NSKeyedArchiver archivedDataWithRootObject:_index]];
    newIndexWrapper.preferredFilename = @"index";
    [_fileWrapper addFileWrapper:newIndexWrapper];
}

#pragma Preview Support

- (NSData*)previewJPEG
{
    return [self numberOfNotes] > 0 ? UIImageJPEGRepresentation([self imageForNote:0], 0.5) : nil;
}

- (BOOL)writeContents:(id)contents andAttributes:(NSDictionary *)additionalFileAttributes safelyToURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation error:(NSError *__autoreleasing *)outError
{
    // If the superclass succeeds in writing out the document, we can write our preview out here as well.
    // This method is invoked on a background queue inside a file coordination block, so writing is safe.
    
    BOOL success = [super writeContents:contents andAttributes:additionalFileAttributes safelyToURL:url forSaveOperation:saveOperation error:outError];
    
    if (success) {
        NSString* previewFileName = [[self.fileURL lastPathComponent] stringByAppendingPathExtension:@"preview"];
        NSURL* previewFileURL = [[[CloudManager sharedManager] dataDirectoryURL] URLByAppendingPathComponent:previewFileName];
        [[[NSFileCoordinator alloc] initWithFilePresenter:nil] coordinateWritingItemAtURL:previewFileURL options:0 error:nil byAccessor:^(NSURL* writingURL) {
            [[self previewJPEG] writeToURL:previewFileURL atomically:YES];
        }];
    }
    
    return success;
}

@end
