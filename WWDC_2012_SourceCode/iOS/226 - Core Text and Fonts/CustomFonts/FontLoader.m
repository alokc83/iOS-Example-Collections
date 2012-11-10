
/*
     File: FontLoader.m
 Abstract: Class to manage fonts embedded with your application as code, plist data, or font urls inside your App's bundle.
 
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

#import <CoreText/CoreText.h>

#import "FontLoader.h"
#import "GeneratedFonts.h"

@implementation FontLoader
{
	NSMutableDictionary* _fonts;
}

static FontLoader *sharedFontLoader = nil;


- (NSMutableDictionary*)initializeFonts {
	NSMutableDictionary* fontsDict = [[NSMutableDictionary alloc] init];
	
	//Get the information for fonts that we've embedded	either as code or in a designated plist
	//The CopyGeneratedFontDataMap is auto-generated by the GendEmbeddedFont tool/target in GeneratedFonts.m
	[fontsDict setValuesForKeysWithDictionary:[CopyGeneratedFontDataMap() autorelease]];
	 
     return fontsDict;
}

- (void)addFontFiles:(NSArray*)fileNames andNames:(NSArray*)postscriptNames inDirectoryPath:(NSString*)path {
	[fileNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([_fonts objectForKey:obj] == nil) {
            NSURL* url = [NSURL fileURLWithPath:path isDirectory:YES];
			NSString* postscriptName = [postscriptNames objectAtIndex:idx];
			GenFontData* fileFontData = [[[GenFontData alloc] initWithName:postscriptName data:(const uint8_t *)[postscriptName UTF8String] length:0] autorelease];

            [_fonts setObject:[NSMutableArray arrayWithObjects:[url URLByAppendingPathComponent:obj], fileFontData, nil] forKey:postscriptName];
        }
	}];	
}

- (void)removeFontsWithNames:(NSArray*)postscriptNames {	
 	[postscriptNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self unloadFont:obj];
        [_fonts removeObjectForKey:obj];
	}];
}

- (CGFontRef)loadFont:(NSString*)postscriptName andRegister:(BOOL)registerFont {
	id fontValue = [_fonts objectForKey:postscriptName];
	if (fontValue == nil) {
		//We are not tracking this font in our class. Possibly a request for
		//an already registered font
		return nil;
	}

	CGFontRef result = nil;

	if ([fontValue isKindOfClass:[GenFontData class]]) {
		CGDataProviderRef dataProvider = NULL;
        GenFontData* embeddedFont = [_fonts objectForKey:postscriptName];
		CGFontRef cgFont = (CGFontRef)embeddedFont.cgFont;
        if (cgFont != nil) {
			if (registerFont && embeddedFont.registered == NO) {
				CFErrorRef error = NULL;
				if (CTFontManagerRegisterGraphicsFont(cgFont, &error)) {
					embeddedFont.registered = YES;
				}
				if (error) {
					NSLog(@"%@", error);
					CFRelease(error);
				}
			}
			
			result = cgFont;
        }
        else if (embeddedFont.length != 0) {
			dataProvider = CGDataProviderCreateWithData(NULL, embeddedFont.data, embeddedFont.length, NULL);
		}
		else {
			NSString* genFontsPath = [[NSBundle mainBundle] pathForResource:@"SupportingData" ofType:@"plist"];
			if (genFontsPath) {
				NSDictionary* getFontsDict = [NSDictionary dictionaryWithContentsOfFile:genFontsPath];
				if (getFontsDict) {
					NSData* fontData = [getFontsDict objectForKey:(NSString*)(embeddedFont.data)];
					if (fontData) {
						dataProvider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
					}
				}
			}
		}
		
		if (dataProvider) {
			CGFontRef cgFont = CGFontCreateWithDataProvider(dataProvider);
			if (cgFont) {
				embeddedFont.cgFont = (id)cgFont;
				if (registerFont) {
					CFErrorRef error = NULL;
					if (CTFontManagerRegisterGraphicsFont(cgFont, &error)) {
						embeddedFont.registered = YES;
					}
					if (error) {
						NSLog(@"%@", error);
						CFRelease(error);
					}
				}
				CGFontRelease(cgFont);
			}
			CGDataProviderRelease(dataProvider);
			result = (CGFontRef)embeddedFont.cgFont;
		}
    }
	else if ([fontValue isKindOfClass:[NSMutableArray class]]) {
		NSMutableArray* fontFileInfo = (NSMutableArray*)fontValue;
		CFURLRef url = (CFURLRef)[fontFileInfo objectAtIndex:0];
		GenFontData* fileFontData = [fontFileInfo objectAtIndex:1];
		if ( fileFontData.cgFont == nil) {
			CFErrorRef error = NULL;			
			if(CTFontManagerRegisterFontsForURL(url, kCTFontManagerScopeProcess, &error)) {
				CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)postscriptName);
				if (cgFont) {
					fileFontData.cgFont = (id)cgFont;
					fileFontData.registered = registerFont;
					CFRelease(cgFont);
				}
								
				if (registerFont == NO)
					CTFontManagerUnregisterFontsForURL((CFURLRef)[fontFileInfo objectAtIndex:1], kCTFontManagerScopeProcess, &error);
			}
			if (error) {
				NSLog(@"%@", error);
				CFRelease(error);
			}
		}
		result = (CGFontRef)fileFontData.cgFont;
	}
    else {
        //Unknown??
        return nil;
	}
	return result;
}

- (BOOL)unloadFont:(NSString*)postscriptName {
    BOOL result = NO;
	id fontValue = [_fonts objectForKey:postscriptName];
    if ([fontValue class] == [GenFontData class]) {
        GenFontData* embeddedFont = [_fonts objectForKey:postscriptName];
        if (embeddedFont.cgFont == nil) {
            return true;
        }
        
        result = CTFontManagerUnregisterGraphicsFont((CGFontRef)embeddedFont.cgFont, NULL);
        embeddedFont.cgFont = nil;        
    }
	else if ([fontValue class] == [NSURL class]) {
		NSMutableArray* fontFileInfo = (NSMutableArray*)fontValue;
		CFURLRef url = (CFURLRef)[fontFileInfo objectAtIndex:0];
		GenFontData* fileFontData = [fontFileInfo objectAtIndex:1];
		if ( fileFontData.cgFont != nil) {
			if (fileFontData.registered) {
				CFErrorRef error = NULL;
				CTFontManagerRegisterFontsForURL(url, kCTFontManagerScopeProcess, &error);
				if (error) {
					NSLog(@"%@", error);
					CFRelease(error);
				}
			}
			fileFontData.cgFont = nil;
			fileFontData.registered = NO;
		}

	}
	else {
        //Registered font, no need to load it
        result = YES;
    }
    return result;
}

- (NSArray*) availableFonts {
	return [[_fonts allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (UIFont*)fontWithName:(NSString*)postscriptName size:(CGFloat)size {
	(void)[self loadFont:postscriptName andRegister:YES];
	return [UIFont fontWithName:postscriptName size:size];
}

- (CTFontRef)hiddenFontWithName:(NSString*)postscriptName size:(CGFloat)size {
	CGFontRef cgFont = [self loadFont:postscriptName andRegister:NO];
	if (cgFont) {
		return CTFontCreateWithGraphicsFont(cgFont, size, NULL, NULL);
	}
	return nil;
}

+ (FontLoader*)sharedFontLoader {
	
	@synchronized(self) {
		if (sharedFontLoader == nil) {
			sharedFontLoader = [[FontLoader alloc] init];
		}
		
		return sharedFontLoader;
	}
}


- (id)init {
	if (self = [super init]) {
		_fonts = [self initializeFonts];
	}
	return self;
}

@end
