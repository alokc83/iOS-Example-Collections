Spaceship

Spaceship is a sample application that shows how you can customize the appearance of your iOS application. 

It uses a theme system to encapsulate the appearance customizations. A theme class only needs to conform to the SSTheme protocol. This applications contains two themes: SSDefaultTheme, a theme that uses the default system appearance; SSTintedTheme, a tinted version of the default theme; and SSMetalTheme, a theme that customizes the appearance of all controls in the application. 
To change between themes, just change what is returned from +[SSThemeManager sharedTheme] in SSTheme.m.


Build Requirements
iOS 6.0 SDK

Runtime Requirements
iOS 6.0 or later


Copyright (C) 2012 Apple Inc. All rights reserved.
