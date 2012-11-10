CustomFont

The sample project demonstrates most of the different techniques that can be used
to make fonts available to your applications:

 - UIAppFonts in the applications Info.plist
 - Fonts embedded in code
 - Font data embedded in a plist
 - Font files present in your bundle
 
Placing fonts in code or in a plist provides you with a means to hide fonts from users
that look inside your application's bundle. This may be important for licensing reasons.
Note, the sample code only shows you techniques to hide the font within your app. No 
attempt is made to encrypt or produce a form or
DRM for the font.
 
A class called FontLoader keeps track of fonts that get embeeded directly in your
code, in a plist, or URLs that you ask the class to keep track of. You can then
instantiate fonts that are readily usable by all font APIs. The class also illustrates
how you can instantiate fonts in a private manner (that is, the font is not available
to Font APIs that search font by names).

The FontLoader class acts on font data that is formatted in a specific way. Included
in the sample app is a tool that generates this data from font files directly. The
GenEmbeddedFont target contains the code and is actually run every time you build the
sample App. The GenerateFontData.sh script contains the invocation sequence for the tool.

The sample contains 9 custom fonts. These fonts are made available to the application
using the techniques outlined above. When the application launches, you will see a list
of all the embedded fonts and some hand-picked fonts that ship with the OS. The custom
fonts have a very limited repertoire. They only have either lowercased vowels, uppercased
vowels, or digits. One of the custom fonts is a test fallback font. Then when you display
one of the custom fonts, if the font does not have a needed glyph, the custom fallback
font kicks in. This custom fallback font is one that gets loaded privately so it is not
available to any of the font APIs in the system. It is only available in CoreText 
fallbacks. The CTLabel class illustrates the custom font fallback functionality.
 