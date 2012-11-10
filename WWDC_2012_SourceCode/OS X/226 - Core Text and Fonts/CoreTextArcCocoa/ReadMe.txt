CoreTextArcCocoa
================

ABOUT:

Illustrates how to use CoreText to draw text along an arc in a Cocoa application.  

The main drawing functionality demonstrated in this application is implemented in a custom NSView called CoreTextArcView.  And, all of the interesting functionality in that view is encapsulated in the  -drawRect: method in the CoreTextArcView.m file.  There, CoreText is used to layout and draw glyphs along a curve.

This sample also makes use of the NSFontPanel to allow user configuration of the text being displayed in the custom view.  This functionality can be found in the file MyDocument.m.  Key points to make note of in that file are:

1. The font panel is synchronized with the current font settings for the custom view in the -windowDidBecomeKey: method.  The Font Panel is a shared resource that stays on screen and calls methods on the first responder to communicate changes in the font selection.  By placing the synchronization code inside of the -windowDidBecomeKey: method, the application is able to make sure the font panel settings are accurately reflected for the state of the document whenever the it becomes the first responder.

2. The -changeFont: method on the MyDocument class is called by the font panel whenever the user selects and new font setting.  This method receives the new font settings and changes the font settings for the custom view.

3. The methods -toggleBold: and -toggleItalic: are called in response to user clicks in the italic and bold checkboxes.  In these methods, the respective font attributes are changed and then the current settings are synchronized to the font pane and to the custom view.



USING THE SAMPLE:

Build and run this sample.  When launched, the application will display a string drawn along an curve.  Click in the checkboxes in the window to change some font settings.  Choose the "Show Fonts" menu item from the "Format" menu to open the font panel so you can change additional font settings.


===========================================================================
BUILD REQUIREMENTS

Xcode 3.2, Mac OS X 10.6 Snow Leopard or later.

===========================================================================
RUNTIME REQUIREMENTS

Mac OS X 10.6 Snow Leopard or later.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS

Version 1.1
- Project updated for Xcode 4.
Version 1.0
- Initial Version

===========================================================================
Copyright (C) 2008-2011 Apple Inc. All rights reserved.