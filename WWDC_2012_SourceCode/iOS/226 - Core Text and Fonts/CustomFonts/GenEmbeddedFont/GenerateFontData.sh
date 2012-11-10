#!/bin/sh

#  GenerateFontData.sh
#  GenEmbeddedFont
#
#  Copyright (c) 2012 Apple. All rights reserved.
#
#  This script gets called from the script build phase at the end of the GenEmbeddedFont target
#  This will generate the files needed by the CustomFonts target to build our final product
#
$BUILT_PRODUCTS_DIR/GenEmbeddedFont -outputDir $SRCROOT/CustomFonts/Fonts -code $SRCROOT/CustomFonts/Fonts/FallbackTestFont.ttf -code $SRCROOT/CustomFonts/Fonts/DigiUg.ttf -code $SRCROOT/CustomFonts/Fonts/DigiUg-Bold.ttf -plist $SRCROOT/CustomFonts/Fonts/CapVow.ttf -plist $SRCROOT/CustomFonts/Fonts/CapVow-Bold.ttf