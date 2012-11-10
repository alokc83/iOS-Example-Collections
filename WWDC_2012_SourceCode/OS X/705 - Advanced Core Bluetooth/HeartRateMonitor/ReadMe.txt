### CoreBluetooth: Heart Rate Monitor ###

===========================================================================
DESCRIPTION:

Heart Rate Monitor is a sample app which uses Bluetooth Low Energy Heart Rate Service. This app demonstrates how to use the CoreBluetooth APIs for LE devices. It is designed to show how to use various CoreBluetooth APIs such as discover devices with specific services, connect to device, discover services, discover characteristics for a service, how to read value for given characteristic, set notification for the characteristic, etc.

Requires a Bluetooth 4.0 capable device supporting the Heart Rate Service. Contact a Bluetooth hardware supplier for availability.

For more information about Bluetooth 4.0 and the AssignedNumbers used in the sample for the Generic Attribute Profile (GATT) Descriptors, Services, and Characteristics, please go to the Bluetooth site.
<http://bluetooth.org>

===========================================================================
BUILD REQUIREMENTS:

Xcode 4.2 or later, Mac OS X 10.7.2 Lion or later.

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X 10.7.2 Lion or later on a Mac OS X System with Bluetooth 4.0 support.

===========================================================================
PACKAGING LIST:

ReadMe.txt -- This file

HeartRateMonitor-Prefix.pch -- Prefix header for all sources in the Heart Rate Monitor sample code.

HeartRateMonitorAppDelegate.[hm] -- Source code for the Heart Rate Monitor sample code.

HeartRateMonitor-Info.plist -- The application Info.plist file.

HeartRateMonitor.xcodeproj -- the Xcode project for the Heart Rate Monitor sample code.

main.m -- standard Cocoa application main entry function.

AppIcon.icns -- Application icon file.

Heart.png -- Graphic art file for heart beat animation.

Human.png -- Graphic art file for application window.


===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

===========================================================================
Copyright (C) 2011 Apple Inc. All rights reserved.
