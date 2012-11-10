
MonitorAddress

====================================================

ABSTRACT:

MonitorAddress demonstrates the use of region monitoring API on OS X as well as the primary use case for the CLGeocoder class, converting between coordinates and address strings. Developers should read the class reference documentation for CLLocationManager, CLLocationManagerDelegate, CLRegion, CLPlacemark and CLGeocoder for detailed information related to geocoding and region monitoring. 

What to Look For in this Project: 

The important geocoding and region monitoring code is in LocationController.m and denoted with "#pragma mark geocoding" and "#pragma mark region monitoring". 

=====================================================

PACKAGING LIST:

* AppDelegate

This application delegate has a minimal role in this sample. It simply connects the ui to the location controller.

* LocationController

The location controller manages the geocoding results to serve as the data source for the NSComboBox. The location controller also monitors the address chosen by the user and shows an NSAlert when the user arrives home.

* NSComboBox+MyExpansionAPI

This is a category file to allow programmatic expansion of the NSComboBox. It contains no location code.
