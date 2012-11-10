### FileCards ###

===========================================================================
DESCRIPTION:

Demonstrates the use of NSPageController.

Summary:
"File Cards" are displayed for the contents of the user's Documents folder.
You can swipe, click the arrow buttons or click on the entry in the table to switch between cards.

AppDelegate:
Implements the NSPageControllerDelegate methods.
There are 3 interesting advanced techniques shown in this file:

1. How to programmatically change the pageController.selectedIndex.
2. The use of more than 1 identifier so that we can have 2 card styles.
3. Use of an optional NSPageControllerDelegate to control the layout of the card inside its parent view.

FileObject:
Simple wrapper around NSURL to make binding to file properties in IB easier.

CardBackgroundView:
Draws the rounded edge background of the file cards.

===========================================================================
BUILD REQUIREMENTS:

OS X Mountain Lion, Xcode 4.4

===========================================================================
RUNTIME REQUIREMENTS:

OS X Mountain Lion

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

1.0 - First version.

===========================================================================
Copyright (C) 2012 Apple Inc. All rights reserved.
