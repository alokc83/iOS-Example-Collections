
### Stars ###

===========================================================================
DESCRIPTION:

Stars is an application project that demonstrates a how to use Core Motion's API to implement virtual reality. It contains a GLKViewController subclass, StarsViewController, that displays a live camera that points at different positions in the virtual space depending on the attitude of the device.

The project has the following classes and protocol, which (except where noted) have corresponding .h and .m file:

StarsViewController — A GLKViewController subclass that provides an virtual reality view of self-rotating cubic stars. It uses Core Motion to determine where the user is facing (i.e. the user's attitude). Depending on the attitude change, the user can see the virtual space from different angles. It starts device motion updates in viewWillAppear:, and stops device motion updates in viewDidDisappear:. It uses the pull method to receive device motion samples by examining the Motion Manager's deviceMotion property.

StarsAppDelegate — A standard implementation of the UIApplicationDelegate protocol. 

See "Motion Events" in Event Handling Guide for iPhone OS explains how to use the Core Motion API.

If you run the compiled application on a device that does not have a gyroscope, you cannot use device motion data. You cannot effectively run the application on the simulator.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0 First version.

===========================================================================
Copyright (C) 2012 Apple Inc. All rights reserved.