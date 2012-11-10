### Hikes Lite ###

================================================================================
DESCRIPTION:

Xcode can use Python scripts to create custom data formatters for classes LLDB does not have information for. This sample explores how that works, and guides the developer in creating, importing, and exploring custom data formatters.

To initialize the custom formatter, do the following:

1.) Find the file "CustomHikesSummaries.py" in this project.
2.) In the Xcode console type:

command script import <file path to CustomHikesSummaries.py>

Note that you could add this import command to ~/.lldbinit file so it will be picked up automatically each time LLDB was launched.

================================================================================
CHANGES FROM PREVIOUS VERSIONS:

1.0 - First Version

================================================================================
Copyright (C) 2011-2012 Apple Inc. All rights reserved.
