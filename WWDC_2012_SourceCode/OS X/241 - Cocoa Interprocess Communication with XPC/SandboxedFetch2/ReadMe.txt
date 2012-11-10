SandboxedFetch2 Read Me

================================================================================

DESCRIPTION:

Sample code showing how the security concept of least privilege separation can be implemented using App Sandboxing and XPC interprocess communication (IPC).  The goal of least privilege separation is to reduce the amount of code that runs with special privileges.  This is achieve in this sample code by splitting the application into separate processes, each with the least amount of privilege necessary to complete its job.

App Sandbox is a Mac OS X security mechanism that controls a process' ability to acquire shared system resources including, but not limited to, shared files, network sockets, hardware devices, and address and calendar information.  An application opts into the App Sandbox by
specifying, in its code signature, a list of entitlements.  These entitle the application to a set of privileges, such as using the camera device or communicating on the network.  The idea is to used the minimum set of entitlements for the application to do its job.

SandboxedFetch is a simple remote file downloader and, optionally, file compressor.  Given a URL to a file it will download the file, compress using the GZIP file format[1] if the compress option is selected, and then prompt the user on the location the file is to be saved.  The application is split into three separate processes: the downloader service ("com.apple.SandboxedFetch.fetch-service.xpc"), the compressor service ("com.apple.SandboxedFetch.zip-service.xpc"), and the user interface component.  All three components run in app sandboxes with different sets of entitlements. fetch-service.xpc uses the "com.apple.security.network.client" entitlement since it needs to communicate with a remote server to transfer the contents of the file.  The user interface uses the "com.apple.security.files.user-selected.read-write" entitlement to allow to write to file path selected by the user using the save panel dialog. Finally, the zip-service.xpc service doesn't need any entitlements to do its job of compressing the file data.  All of these components are packaged together into a single application bundle and communicate using the XPC IPC mechanism.

For more information on application sandboxing please see the Code Signing and Application Sandboxing Guide.

Version 2 of this sample project has been updated to use the NSXPCConnection feature in Mountain Lion, which allows you to use your own objects and interfaces when communicating between processes in your application. Some of the other functionality has been updated to use other Cocoa level API (like NSFileHandle and NSURLConnection), and some features have been simplified to increase the focus on the IPC functionality of the sample code.

[1] RFC 1952, "GZIP file format specification version 4.3".

================================================================================

BUILD REQUIREMENTS:

OS X Version 10.8 Mountain Lion

libz (included with Mac OS X 10.8 and used by zip-service.xpc)

The code signing certificate with the identity of "3rd Party Mac Developer Application".  To create this certificate do the following:

(1) Launch the Keychain Access utility.
(2) Select Keychain Access->Certificate Assistant->Create a Certificate... in the pull-down menu.
(3) For the Name field enter "3rd Party Mac Developer Application".  For the Certificate Type field select "Code Signing".  The Identity Type should be "Self Signed Root".  Click on "Continue" and "Done" after the certificate has been successfully created.

For more information on application code signing please see the Code Signing and Application Sandboxing Guide.

================================================================================

RUNTIME REQUIREMENTS:

OS X Version 10.8 Mountain Lion

libz.dylib (included with OS X 10.8 and used by zip-service.xpc)

================================================================================

PACKAGING LIST:

SandboxedFetch.xcodeproj              Xcode project file

SandboxedFetch/
  main.m
  SandboxedFetch-Info.plist		  
  SandboxedFetch-Prefix.pch           
  SandboxedFetchAppDelegate.h
  SandboxedFetchAppDelegate.m         User interface code

  SandboxedFetch-Entitlements.plist   UI sandbox entitlements

  en.lproj/				       Localized resources

fetch-service/
  fetch-service-Info.plist
  fetch-service-Prefix.pch           
  main.m                    		  Main code and NSXPCListener delegate for fetch service

  Fetcher.h					  Interface for Fetcher service and FetchProgress reporting
  Fetcher.m					  Implementation of Fetcher service

  fetch-service.entitlements   	  Entitlements for the fetch service

  en.lproj/					  Localized resources

zip-service/
  fetch_service-Info.plist
  fetch_service-Prefix.pch           
  main.m		                       Main code for zip service

  Zipper.h						  Interface for Zipper service and associated object
  Zipper.m						  Implementation of Zipper object

  zip-service.entitlements   	       Entitlements for the zip service

  en.lproj/					  Localized resources

================================================================================

CHANGES FROM PREVIOUS VERSIONS:

Version 2.0
 - Updated to use the new NSXPCConnection feature in OS X 10.8 Mountain Lion.

Version 1.1
- Minor change for shipping version of Mac OS X v10.7.

Version 1.0
- First version

================================================================================

Copyright (C) 2011-2012 Apple Inc. All rights reserved.
