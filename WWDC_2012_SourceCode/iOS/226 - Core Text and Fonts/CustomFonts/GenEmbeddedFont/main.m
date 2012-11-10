/*
 
 File: main.m
 
 Target: GenEmbeddedFont
 
 Abstract: Tool that streams out font data either as C code or in
 a binary plist form. This generated code/data can later be used
 with the FontLoader class in the CustomsFont target
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
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
 
 */

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

static void PrintHelpAndExit(const char* procName, int exitValue)
{
	printf("%s [-outputDir outputfileprefixpath] [-code |-plist] fontInputFile1...[-code |-plist] fontInputFileN\n", procName);
	printf("\tThis tool will take one or more font files and re-package them either as code or in a dictionary plist.\n");
    printf("\t-code\tgenerates data for the font file specified to be compiled with code. This is the default if -code or -plist is not specified\n");
	printf("\t-plist\tgenerates plist data for the font file specified\n");
	printf("\t-outputDir\tPath where files will be generated\n");
	printf("\n\tVersion 1.0\n");
	exit(exitValue);
}

enum {
	//When storing font data into our internal dictionaries, we use the argument index as a key to serialize the data
	//Data that we wish to serialize as code will have its argument index increased by kCodeArgumentIndexSpread.
	kCodeArgumentIndexSpread = 1000
};


static void PrintHeader(FILE* where, const char* codeOrHeader, int argc, const char* argv[])
{
	fprintf(where, "// This %s was auto-generated using:\n//\t\t", codeOrHeader);

	NSString* procName = [[NSString stringWithUTF8String:argv[0]] lastPathComponent];
	fprintf(where, "%s ", [procName UTF8String]);
	int i;
	for (i=1; i<argc; i++) {
		NSURL* url = [[[NSURL alloc] initFileURLWithPath:[NSString stringWithUTF8String:argv[i]]] autorelease];
		if (url && [url isFileURL]) {
			fprintf(where, "%s ", [[url lastPathComponent] UTF8String]);
		}
		else
			fprintf(where, "%s ", argv[i]);
	}
	fprintf(where, "\n//\n// Please see the GenEmbeddedFont target and GenerateFontData.sh for details on how this %s was generated.", codeOrHeader);
	fprintf(where, "\n// This file will be used by the FontLoader class in the CustomFonts target.");
	fprintf(where, "\n// The FontLoader class will make the font data pointed by this file available in your application.");
	fprintf(where, "\n//\n// Copyright (C) 2012 Apple Inc. All Rights Reserved.\n\n");
}

static void AbsorbFontFile(const char* fontFilePath, NSMutableDictionary* fontsDict, NSMutableDictionary* fontNames, NSMutableDictionary* plistMapping, int curArg)
{
	BOOL argIsValid = FALSE;
	NSData* data = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:fontFilePath]];
	if (data) {
		CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFDataRef)data);
		if (dataProvider) {
			CGFontRef cgFont = CGFontCreateWithDataProvider(dataProvider);
			if (cgFont) {
				CFStringRef postName = CGFontCopyPostScriptName(cgFont);
				if (postName) {
					[fontNames setObject:data forKey:(NSString*)postName];
					[fontsDict setObject:data forKey:[[NSNumber numberWithInt:curArg] stringValue]];
					[plistMapping setObject:[[NSNumber numberWithInt:curArg] stringValue] forKey:(NSString*)postName];
					argIsValid = TRUE;
					CFRelease(postName);
				}
				CFRelease(cgFont);
			}
			CGDataProviderRelease(dataProvider);
		}
	}
	if (argIsValid == FALSE) {
		NSLog(@"%s was ignored - not a valid font file", fontFilePath);
	}
}

int main (int argc, const char * argv[])
{

	@autoreleasepool {
	    
        NSString* procName = [[NSString stringWithUTF8String:argv[0]] lastPathComponent];
		if (argc < 2) {
			PrintHelpAndExit([procName UTF8String], -1);
		}
		
		NSString* outputFilePrefix = @"GeneratedFonts";
		NSString* outputPlistPrefix = @"SupportingData";
		NSString* outputPath = @"./";
		BOOL havePlistEntries = NO;
		
	    NSMutableDictionary* fontsDict = [[NSMutableDictionary alloc] init ];
		NSMutableDictionary* fontNames = [[NSMutableDictionary alloc] init];
		NSMutableDictionary* plistMapping = [[NSMutableDictionary alloc] init];
		
		int curArg;
		for (curArg=1; curArg<argc; curArg++) {			
			if (strncmp(argv[curArg], "-code", strlen(argv[curArg])) == 0) {
                if (curArg+1 == argc) {
					PrintHelpAndExit([procName UTF8String], -1);
				}
				AbsorbFontFile(argv[++curArg], fontsDict, fontNames, plistMapping,  curArg + kCodeArgumentIndexSpread);
			}
			else if (strncmp(argv[curArg], "-plist", strlen(argv[curArg])) == 0) {
                if (curArg+1 == argc) {
					PrintHelpAndExit([procName UTF8String], -1);
				}
				AbsorbFontFile(argv[++curArg], fontsDict, fontNames, plistMapping,  curArg);
				havePlistEntries = YES;
			}
            else if (strncmp(argv[curArg], "-outputDir", strlen(argv[curArg])) == 0) {
                if (curArg+1 == argc) {
					PrintHelpAndExit([procName UTF8String], -1);
				}
				outputPath = [NSString stringWithUTF8String:argv[++curArg]];
            }
			else
				AbsorbFontFile(argv[curArg], fontsDict, fontNames, plistMapping,  curArg + kCodeArgumentIndexSpread);
		}
		
		if ([fontsDict count]) {
            
            NSString* theCodeFileName = [outputFilePrefix stringByAppendingPathExtension:@"m"];
            NSString* outputFile = [outputPath stringByAppendingPathComponent:theCodeFileName];

            const char* theCodeFileNameStr = [outputFilePrefix UTF8String];
            const char* outputFileStr = [outputFile UTF8String];
            FILE* codeFile = fopen(outputFileStr, "w");
            if (codeFile) {
                FILE* headerFile = fopen([[NSString stringWithFormat:@"%@.h", [outputFile stringByDeletingPathExtension]] UTF8String], "w");
                if (headerFile) {
					PrintHeader(headerFile, "header", argc, argv);
                    fprintf(headerFile, "#ifndef __%s_H__\n#define __%s_H__\n\n", theCodeFileNameStr, theCodeFileNameStr );
                    fprintf(headerFile, "#import <Foundation/Foundation.h>\n#import <CoreGraphics/CoreGraphics.h>\n#include <stdint.h>\n#include <sys/types.h>\n\n");
					PrintHeader(codeFile, "code", argc, argv);
                    fprintf(codeFile, "#import \"%s.h\"\n\n", theCodeFileNameStr);
                    
                    
                    fprintf(headerFile, "@interface GenFontData : NSObject {\n");
                    fprintf(headerFile, "\tNSString* _postName;\n");
                    fprintf(headerFile, "\tconst uint8_t* _data;\n");
                    fprintf(headerFile, "\tsize_t _length;\n");
                    fprintf(headerFile, "\tid _cgFont;\n");
                    fprintf(headerFile, "\tBOOL _registered;\n");
                    fprintf(headerFile, "}\n\n");
                    
                    fprintf(headerFile, "- (id)initWithName:(NSString*)postName data:(const uint8_t*)data length:(size_t)theLength;\n\n");
                    
                    fprintf(headerFile, "@property (nonatomic, retain) NSString* postName;\n");
                    fprintf(headerFile, "@property (nonatomic) const uint8_t * data;\n");
                    fprintf(headerFile, "@property (nonatomic) size_t length;\n");
                    fprintf(headerFile, "@property (nonatomic, retain) id cgFont;\n\n");
                    fprintf(headerFile, "@property (nonatomic) BOOL registered;\n");
                    
                    fprintf(headerFile, "@end\n\n");
                    

                    
                    fprintf(headerFile, "NSDictionary* CopyGeneratedFontDataMap(void);\n\n");
                    
                    fprintf(codeFile, "@implementation GenFontData\n\n");
                    
                    fprintf(codeFile, "@synthesize postName = _postName;\n");
                    fprintf(codeFile, "@synthesize data = _data;\n");
                    fprintf(codeFile, "@synthesize length = _length;\n");
                    fprintf(codeFile, "@synthesize cgFont = _cgFont;\n");
                    fprintf(codeFile, "@synthesize registered = _registered;\n\n");
                    
                    fprintf(codeFile, "- (id)initWithName:(NSString*)thePostName data:(const uint8_t*)theData length:(size_t)theLength {\n");
                    fprintf(codeFile, "\tself = [super init];\n\n");
                    fprintf(codeFile, "\tif (self) {\n");
                        
                    fprintf(codeFile, "\t\tself.postName = [thePostName retain];\n");
                    fprintf(codeFile, "\t\tself.data = theData;\n");
                    fprintf(codeFile, "\t\tself.length = theLength;\n");
                    fprintf(codeFile, "\t\tself.cgFont = nil;\n");
                    fprintf(codeFile, "\t\tself.registered = NO;\n");
                    fprintf(codeFile, "\t}\n");
                        
                    fprintf(codeFile, "\treturn self;\n");
                    fprintf(codeFile, "}\n\n");
                    
					
					fprintf(codeFile, "- (void)dealloc {\n");
					fprintf(codeFile, "\t[_cgFont release];\n");
					fprintf(codeFile, "\t[super dealloc];\n");
					fprintf(codeFile, "}\n\n");

                    fprintf(codeFile, "@end\n\n");


					[fontNames enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
						NSNumber* argIndex = [plistMapping objectForKey:key];
						if ([argIndex integerValue] >= kCodeArgumentIndexSpread) {
							//const char* postName = [[(NSString*)key stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]] UTF8String];
							const char* postName = [[(NSString*)key stringByReplacingOccurrencesOfString:@"-" withString:@"_"] UTF8String];
							fprintf(codeFile, "static const uint8_t k%s[] = {\n\t", postName);
							NSData* dataObj = (NSData*)obj;
							const uint8_t *dataPtr = [(NSData*)dataObj bytes];
							NSUInteger dataLength = [(NSData*)dataObj length];
							NSUInteger index;
							for (index=0; index<dataLength; index++) {
								fprintf(codeFile, "0x%2.2X", dataPtr[index]);
								if (index+1 < dataLength) {
									fprintf(codeFile, ", ");
								}
								if (((index+1) % 16) == 0)
									fprintf(codeFile, "\n\t");
								
							} 
							fprintf(codeFile, "\n};\n");
						}
					}];
                    fprintf(headerFile, "\n#endif\n");
                    fclose(headerFile);
                }
				
			
                
                fprintf(codeFile, "NSDictionary* CopyGeneratedFontDataMap(void) {\n");
                
                fprintf(codeFile, "\tNSMutableDictionary* dict = [[NSMutableDictionary alloc] init ];\n");
                
                [fontNames enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					NSNumber* argIndex = [plistMapping objectForKey:key];
					if ([argIndex integerValue] >= kCodeArgumentIndexSpread) {
                        fprintf(codeFile, "\t[dict setObject:[[GenFontData alloc] initWithName:@\"%s\" data:(const uint8_t*)k%s length:%lu]  forKey:@\"%s\"];\n", [key UTF8String], [[(NSString*)key stringByReplacingOccurrencesOfString:@"-" withString:@"_"] UTF8String], [(NSData*)obj length], [key UTF8String]);
                    }
                    else {
                        fprintf(codeFile, "\t[dict setObject:[[GenFontData alloc] initWithName:@\"%s\" data:(const uint8_t*)@\"%s\" length:0]  forKey:@\"%s\"];\n",  [key UTF8String], [(NSString*)[plistMapping objectForKey:key] UTF8String] , [key UTF8String]);
                    }
                }];
                
                
                
                fprintf(codeFile, "\treturn (NSDictionary*)dict;\n}\n");
                fclose(codeFile);
				
				if (havePlistEntries) {
					[plistMapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
						NSNumber* argIndex = (NSNumber*)obj;
						if ([argIndex integerValue] >= kCodeArgumentIndexSpread) {
							[fontsDict removeObjectForKey:argIndex];
						}
					}];
					
                    NSString *error;
                    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:fontsDict format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
                    if(plistData)
                    {
                        NSString* thePLISTFileName = [outputPlistPrefix stringByAppendingPathExtension:@"plist"];
                        [plistData writeToFile:[outputPath stringByAppendingPathComponent:thePLISTFileName] atomically:YES];
                    }
                    else
                    {
                        NSLog(@"%@", error);
                        [error release];
                    }	    
                }

            }

		}
	}
    return 0;
}

