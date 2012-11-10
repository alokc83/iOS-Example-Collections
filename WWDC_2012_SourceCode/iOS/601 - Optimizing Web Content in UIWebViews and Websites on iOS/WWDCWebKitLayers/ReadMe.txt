Project Description:

This is a sample iOS app used in "Session 601: Optimizing Web Content in
UIWebViews and Websites on iOS" at WWDC 2012. It employs NSUserDefaults to
enable and disable WebKit debug borders, a developer tool that provides details
about web page element rendering. This user default should only be enabled for
development purposes.


WebKit Debug Borders:

To enable or disable WebKit debug borders modify the defaults key in your
application's standard user defaults, then restart the application. The default
key is @"WebKitShowDebugBorders". Set a BOOL value.
