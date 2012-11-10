### Scene Kit Document Viewer ###

===========================================================================
DESCRIPTION:

Demonstrates how to use Scene Kit to load and play a 3D scene with animations. It also shows how to pick objects and change their materials.

===========================================================================
BUILD REQUIREMENTS:

Xcode 4.4 or later, OS X 10.8 or later

===========================================================================
RUNTIME REQUIREMENTS:

OS X 10.8 or later

===========================================================================
PACKAGING LIST:

AppController.h/m
This is the main controller for the application and handles the setup of the view and the loading of an initial scene. An instance of this class resides in MainMenu.xib and uses an IBOutlet reference for the view (which has been wired up through Interface Builder).

MyView.h/m
A subclass of SCNView on which the user can drop .dae files. It handles mouse events to pick 3D objects and change their materials.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

===========================================================================
Copyright (C) 2012 Apple Inc. All rights reserved.
