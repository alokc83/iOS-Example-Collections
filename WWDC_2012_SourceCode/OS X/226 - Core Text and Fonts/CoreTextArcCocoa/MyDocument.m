/*
     File: MyDocument.m 
 Abstract: Defines the MyDocument custom NSDocument subclass to control
 document window and interact with Font panel. 
  Version: 1.1 
  
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
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "MyDocument.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@interface NSFont (FontStyleAdditions) 
- (BOOL)isBold;
- (BOOL)isItalic;
- (BOOL)canToggleTrait:(NSFontTraitMask)trait;
@end

@implementation MyDocument

@synthesize arcView;

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

- (NSString *)displayName {
	return self.arcView.string;
}

- (void)updateDisplay {
	[self.arcView setNeedsDisplay:YES];

	// Update the bold button
	[boldButton setState:[self.arcView.font isBold] ? NSOnState : NSOffState];
	[boldButton setEnabled:[self.arcView.font canToggleTrait:NSFontBoldTrait]];

	// Update the italic button
	[italicButton setState:[self.arcView.font isItalic] ? NSOnState : NSOffState];
	[italicButton setEnabled:[self.arcView.font canToggleTrait:NSFontItalicTrait]];

	// Update the window title
	for (NSWindowController *controller in [self windowControllers]) {
		[[controller window] setTitle:[self displayName]];
	}
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
	SEL action = [item action];
	
	if (sel_isEqual(action, @selector(toggleBold:))) {
		// Set the state based on the presence of the trait
		if ([(id)item respondsToSelector:@selector(setState:)]) {
			[(id)item setState:[self.arcView.font isBold] ? NSOnState : NSOffState];
		}
		
		// Test whether we can convert the traits to enable or disable the control
		return [self.arcView.font canToggleTrait:NSFontBoldTrait];
	}
	else if (sel_isEqual(action, @selector(toggleItalic:))) {
		// Set the state based on the presence of the trait
		if ([(id)item respondsToSelector:@selector(setState:)]) {
			[(id)item setState:[self.arcView.font isItalic] ? NSOnState : NSOffState];
		}
		
		// Test whether we can convert the traits to enable or disable the control
		return [self.arcView.font canToggleTrait:NSFontItalicTrait];
	}
	return YES;
}



- (void)windowDidBecomeKey:(NSNotification *)notification {
	[[NSFontManager sharedFontManager] setTarget:self];
	[[NSFontPanel sharedFontPanel] setPanelFont:self.arcView.font isMultiple:NO];
}



- (void)controlTextDidChange:(NSNotification *)notification {
	[self setString:[notification object]];
}

- (void)changeFont:(id)sender {
	self.arcView.font = [sender convertFont:self.arcView.font];
	[self updateDisplay];
}

- (IBAction)setString:(id)sender {
	self.arcView.string = [sender stringValue];
	[self updateDisplay];
}

- (IBAction)toggleBold:(id)sender {
	NSFont *newFont = nil;
	if ([sender state] == NSOnState) {
		newFont = [[NSFontManager sharedFontManager] convertFont:self.arcView.font toHaveTrait:NSFontBoldTrait];
	} 
	else {
		newFont = [[NSFontManager sharedFontManager] convertFont:self.arcView.font toNotHaveTrait:NSFontBoldTrait];
	}
	
	if (newFont != nil) {
		self.arcView.font = newFont;
		[self updateDisplay];
		[[NSFontPanel sharedFontPanel] setPanelFont:self.arcView.font isMultiple:NO];
	}
}

- (IBAction)toggleItalic:(id)sender {
	NSFont *newFont = nil;
	if ([sender state] == NSOnState) {
		newFont = [[NSFontManager sharedFontManager] convertFont:self.arcView.font toHaveTrait:NSFontItalicTrait];
	} 
	else {
		newFont = [[NSFontManager sharedFontManager] convertFont:self.arcView.font toNotHaveTrait:NSFontItalicTrait];
	}
	
	if (newFont != nil) {
		self.arcView.font = newFont;
		[self updateDisplay];
		[[NSFontPanel sharedFontPanel] setPanelFont:self.arcView.font isMultiple:NO];
	}
}

- (IBAction)setShowsGlyphOutlines:(id)sender {
	self.arcView.showsGlyphBounds = ([sender state] == NSOnState);
	[self updateDisplay];
}

- (IBAction)setShowsLineMetrics:(id)sender {
	self.arcView.showsLineMetrics = ([sender state] == NSOnState);
	[self updateDisplay];
}

- (IBAction)setDimsSubstitutedGlyphs:(id)sender {
	self.arcView.dimsSubstitutedGlyphs = ([sender state] == NSOnState);
	[self updateDisplay];
}

@end


	/* category for returning information about the font in a format that's
	more easly used in this particular application.  */
@implementation NSFont (FontStyleAdditions) 
- (BOOL)isBold {
	return ([[self fontDescriptor] symbolicTraits] & NSFontBoldTrait);
}

- (BOOL)isItalic {
	return ([[self fontDescriptor] symbolicTraits] & NSFontItalicTrait);
}

- (BOOL)canToggleTrait:(NSFontTraitMask)trait {
	NSFont *testFont = nil;
	if ([[self fontDescriptor] symbolicTraits] & trait) {
		testFont = [[NSFontManager sharedFontManager] convertFont:self toNotHaveTrait:trait];
	}
	else {
		testFont = [[NSFontManager sharedFontManager] convertFont:self toHaveTrait:trait];
	}

	if (testFont != nil) {
		if (([[testFont fontDescriptor] symbolicTraits] ^ [[self fontDescriptor] symbolicTraits]) == trait) {
			return YES;
		}
	}
	return NO;
}
@end

