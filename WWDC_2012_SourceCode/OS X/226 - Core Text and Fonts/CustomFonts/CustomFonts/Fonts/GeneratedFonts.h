// This header was auto-generated using:
//		GenEmbeddedFont -outputDir Fonts -code FallbackTestFont.ttf -code DigiUg.ttf -code DigiUg-Bold.ttf -plist CapVow.ttf -plist CapVow-Bold.ttf 
//
// Please see the GenEmbeddedFont target and GenerateFontData.sh for details on how this header was generated.
// This file will be used by the FontLoader class in the CustomFonts target.
// The FontLoader class will make the font data pointed by this file available in your application.
//
// Copyright (C) 2012 Apple Inc. All Rights Reserved.

#ifndef __GeneratedFonts_H__
#define __GeneratedFonts_H__

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#include <stdint.h>
#include <sys/types.h>

@interface GenFontData : NSObject {
	NSString* _postName;
	const uint8_t* _data;
	size_t _length;
	id _cgFont;
	BOOL _registered;
}

- (id)initWithName:(NSString*)postName data:(const uint8_t*)data length:(size_t)theLength;

@property (nonatomic, retain) NSString* postName;
@property (nonatomic) const uint8_t * data;
@property (nonatomic) size_t length;
@property (nonatomic, retain) id cgFont;

@property (nonatomic) BOOL registered;
@end

NSDictionary* CopyGeneratedFontDataMap(void);


#endif
