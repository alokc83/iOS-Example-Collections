
### WWDCTransit ###
 
===========================================================================
DESCRIPTION:
 
The WWDCTransit app displays all Caltrain stops on a map and allows the user to get directions to/from two locations by finding the nearest stop to those locations. It declares itself as a routing app, allowing it to be launched directly from Maps.
 
===========================================================================
PACKAGING LIST:

AppDelegate
- A basic UIApplication delegate which sets up the application.

MapViewController
- The main view controller for our app. Displays a map.

DirectionsViewController
- Contains a start and end field for specifying the start/end points for a route.

MyPlace
- A generic data structure representing a place in the world.

Route
- A data structure encompassing the necessary data to plot a route.

TransitInfo
- An interface abstracting the raw GTFS feed data into something more managable

TransitStop
- Represents a single stop along a transit line

TransitTrip
- Represents a trip/route along a transit system

TransitShape
- The coordinates which correspond to a given trip along a transit system

GTFS/
- The files from the Caltrain GTFS feed. Downloaded from http://www.caltrain.com/schedules/Mobile_Device_Schedules.html. Subject to the SMCTD Developer License Agreement (http://www.smctd.com/dla.html)
 
===========================================================================
CHANGES FROM PREVIOUS VERSIONS:
 
Version 1.0
- First version.
 
===========================================================================
Copyright (C) 2012 Apple Inc. All rights reserved.