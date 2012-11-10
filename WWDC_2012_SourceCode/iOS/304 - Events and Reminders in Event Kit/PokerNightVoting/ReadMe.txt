### PokerNightVoting ###

===========================================================================
DESCRIPTION:

This application allows users to suggest times for a poker night with friends, view times suggested by others, and vote on which time works best for them.  It uses the EventKit API to create events to represent the possible times.  The same model and EventKit code powers both the iOS and OS X apps, showing how easy it is to create a cross-platform app using EventKit.

===========================================================================
BUILD REQUIREMENTS:

Xcode 4.5 or later, Mac OS X v10.8 or later, iOS 6 or later.

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.8 or later, iOS 6 or later.

===========================================================================
PACKAGING LIST:

PNVModel.h - The model for both iOS and OS X that uses EventKit.

PNVOSXViewController.h - The view controller for the OS X version.
MainView.xib - The view for the OS X version.

PNViOSViewController.h - The view controller for the iOS version.
MainStoryboard_iPhone.storyboard - The storyboard/view for the iOS version.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

===========================================================================
Copyright (C) 2012 Apple Inc. All rights reserved.
