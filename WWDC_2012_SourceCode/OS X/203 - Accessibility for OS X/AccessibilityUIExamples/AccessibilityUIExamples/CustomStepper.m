/*
 
     File: CustomStepper.m
 Abstract: Custom view that behaves like a stepper.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 
 */

#import "CustomStepper.h"
#import <OpenGL/gl.h>
#import <OpenGL/OpenGL.h>

#import "CustomStepperAccessibility.h"

#define CUSTOM_STEPPER_MAX_VALUE        (100.0f)
#define CUSTOM_STEPPER_MIN_VALUE        (0.0f)
#define CUSTOM_STEPPER_VALUE_CHANGE     (5.0f)

typedef enum {
    kCustomStepperShaderTypeFragment = 0,
    kCustomStepperShaderTypeVector = 1
} CustomStepperShaderType;

// IMPORTANT: This is not a template for developing a custom stepper. This sample is
// intended to demonstrate how to add accessibility to UI that may not have been
// ideally designed. For information on how to create custom controls please visit
// http://developer.apple.com

@implementation CustomStepper

@synthesize currentValue = mCurrentValue;

+ (NSOpenGLPixelFormat *)defaultPixelFormat
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAStencilSize, 8,
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)32,
        NSOpenGLPFAMultisample,
        NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)1,
        NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)9, 0
    };
    
    return [[NSOpenGLPixelFormat alloc]initWithAttributes:attrs];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        GLint swapInterval = 1;
        [[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
        
        mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(animate:) userInfo:nil repeats:YES];

        // Register for mouse events that affect drawing.
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveWhenFirstResponder |  NSTrackingEnabledDuringMouseDrag
                                                                      owner:self
                                                                   userInfo:nil];
        [self addTrackingArea:trackingArea];
        
        [self initOpenGLStates];
    }
    
    return self;
}

- (void)drawRect:(NSRect) bounds
{   
    [self drawAnObject];
    [[self openGLContext] flushBuffer];
}

-(void)animate:(NSTimer *)timer
{
    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)drawFocusRingMask
{
    NSRectFill([self bounds]);
}

- (NSRect)focusRingMaskBounds
{
    return [self bounds];
}

- (void)sendAction
{
    [[self target] performSelectorOnMainThread:[self action] withObject:self waitUntilDone:YES];
}

- (NSRect)upButtonRect
{
    NSRect returnValue = [self bounds];
    returnValue.origin.y = NSMidY(returnValue);
    returnValue.size.height /= 2.0f;
    return returnValue;
}

- (NSRect)downButtonRect
{
    NSRect returnValue = [self bounds];
    returnValue.size.height /= 2.0f;
    return returnValue;
}

- (void)performIncrementButtonPress
{
    mUpButtonState.showDepressed = YES;
    mDownButtonState.showDepressed = NO;
    [self setNeedsDisplay:YES];
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mUpButtonState.showDepressed = NO;
        mDownButtonState.showDepressed = NO;
        [self setNeedsDisplay:YES];
        [self increment];
    });
}

- (void)performDecrementButtonPress
{
    mUpButtonState.showDepressed = NO;
    mDownButtonState.showDepressed = YES;
    [self setNeedsDisplay:YES];
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        mUpButtonState.showDepressed = NO;
        mDownButtonState.showDepressed = NO;
        [self setNeedsDisplay:YES];
        [self decrement];
    });
}

- (void)increment
{
    mCurrentValue += CUSTOM_STEPPER_VALUE_CHANGE;
    if ( mCurrentValue > CUSTOM_STEPPER_MAX_VALUE )
    {
        mCurrentValue = CUSTOM_STEPPER_MAX_VALUE;
    }
    [self sendAction];
}

- (void)decrement
{
    mCurrentValue -= CUSTOM_STEPPER_VALUE_CHANGE;
    if ( mCurrentValue < CUSTOM_STEPPER_MIN_VALUE )
    {
        mCurrentValue = CUSTOM_STEPPER_MIN_VALUE;
    }
    [self sendAction];
}

#pragma mark Mouse events
- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if ( NSPointInRect(localPoint, [self upButtonRect]) )
    {
        mUpButtonState.mouseDown = YES;
        mUpButtonState.showDepressed = YES;
        mDownButtonState.mouseDown = NO;
        mDownButtonState.showDepressed = NO;
    }
    else if ( NSPointInRect(localPoint, [self downButtonRect]) )
    {
        mUpButtonState.mouseDown = NO;
        mUpButtonState.showDepressed = NO;
        mDownButtonState.mouseDown = YES;
        mDownButtonState.showDepressed = YES;
    }

    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    
    NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if ( mUpButtonState.mouseDown &&
         mUpButtonState.showDepressed &&
         NSPointInRect(localPoint, [self upButtonRect]) )
    {
        [self increment];
    }
    else if ( mDownButtonState.mouseDown &&
              mDownButtonState.showDepressed &&
              NSPointInRect(localPoint, [self downButtonRect]) )
    {
        [self decrement];
    }
    
    mUpButtonState.mouseDown = NO;
    mUpButtonState.showDepressed = NO;
    mDownButtonState.mouseDown = NO;
    mDownButtonState.showDepressed = NO;

    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];
    
    NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    if ( NSPointInRect(localPoint, [self upButtonRect]))
    {
        mUpButtonState.showDepressed = mUpButtonState.mouseDown;
    }
    else if ( NSPointInRect(localPoint, [self downButtonRect]) )
    {
        mDownButtonState.showDepressed = mDownButtonState.mouseDown;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];

    mUpButtonState.showDepressed = NO;
    mDownButtonState.showDepressed = NO;
    
    [self setNeedsDisplay:YES];
}


#pragma mark Keyboard events

- (void)keyDown:(NSEvent *)theEvent
{
    // Increment value on spacebar.
    if ( [[theEvent characters] isEqualToString:@" "] )
    {
        [self performIncrementButtonPress];
    }
    
    // Arrow keys are associated with the numeric keypad
    if ( [theEvent modifierFlags] & NSNumericPadKeyMask )
    {
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    } else
    {
        [super keyDown:theEvent];
    }
}

- (IBAction)moveUp:(id)sender
{
    [self performIncrementButtonPress];
}

- (IBAction)moveDown:(id)sender
{
    [self performDecrementButtonPress];
}

- (NSArray *)imageNames
{
    return @[@"StepperBackground"];
}

-(void)loadTextures
{   
    if ( mTextures != nil )
    {
        return;
    }
    
    NSArray *imageNames = [self imageNames];
    
    GLsizei imageCount = (GLsizei)[imageNames count];
    mTextures = calloc(imageCount, sizeof(GLuint));
    mTextureSizes = calloc(imageCount, sizeof(CGSize));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    glGenTextures(imageCount, mTextures);
    glEnable(GL_TEXTURE_RECTANGLE_EXT);

    GLsizei i = 0;
    for ( i = 0; i < imageCount; i++ )
    {
        NSString *imageName = [imageNames objectAtIndex:i];
        glBindTexture(GL_TEXTURE_RECTANGLE_EXT, mTextures[i]);
        glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
        glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:imageName];
        if ( [imagePath length] > 0 )
        {
            CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename([imagePath fileSystemRepresentation]);
            if ( dataProvider != nil )
            {
                CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
                if ( image != nil )
                {
                    GLuint width = (GLuint)CGImageGetWidth(image);
                    GLuint height = (GLuint)CGImageGetHeight(image);    
                    
                    mTextureSizes[i] = CGSizeMake(width, height);
                    size_t bytesPerRow = width * 4;
                    void *imageData = malloc( height * bytesPerRow );
                    
                    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
                    
                    if ( context != nil )
                    {
                        CGContextClearRect(context, CGRectMake( 0, 0, width, height ));
                        CGContextTranslateCTM( context, 0, height - height);
                        CGContextDrawImage(context, CGRectMake( 0, 0, width, height ), image);
                        
                        glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
                        
                        CGContextRelease(context);
                    }
                    free(imageData);
                    CFRelease(image);
                }
                CFRelease(dataProvider);
            }
        }
    }
    
    CGColorSpaceRelease(colorSpace );
}

#pragma mark -
#pragma mark OpenGL drawing below this point
#pragma mark -

- (void)drawAnObject
{
    // clear everything
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glClearColor(0.0, 0.0, 0.0, 0.0);
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    
    // generate some colors
    CGFloat r, g, b;
    static float hue = 0;
    if ( hue >= 1.0 )
    {
        hue=0;
    }
    hue+=0.003;
    
    // Obviously in a real app we would probably want to cache these calculations
    NSColor *colorObject = [NSColor colorWithCalibratedHue:hue saturation:0.7 brightness:0.5 alpha:1.0];
    [colorObject getRed:&r green:&g blue:&b alpha:NULL];
    GLfloat diffusedColor[] = {r, g, b};
    
    colorObject = [NSColor colorWithCalibratedHue:hue saturation:0.5 brightness:0.3 alpha:1.0];
    [colorObject getRed:&r green:&g blue:&b alpha:NULL];
    GLfloat ambientColor[] = {r, g, b};

    [NSColor colorWithCalibratedHue:hue saturation:0.5 brightness:0.3 alpha:1.0];
    [colorObject getRed:&r green:&g blue:&b alpha:NULL];
    
    GLfloat whiteColor[] = {1.0, 1.0, 1.0, 1.0};
    GLfloat pinkDiffusedColor[] = {1.0, 0.0, 1.0, 1.0};
    GLfloat pinkAmbientColor[] = {0.713, 0.294, 0.713, 1.0};
    
    // Let there be light!
    glEnable(GL_LIGHT0);
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, whiteColor);
    GLfloat lightPosition[] = {1.0, 0.5, 1.0, 1.0};
    glLightfv(GL_LIGHT0, GL_POSITION, lightPosition);

    // position corretly to draw
    glTranslatef(0.0, 0.0, -1.0);

//    static float rotate = 0.0f;
//    glRotatef(rotate+=0.8,0.0, 1.0, 0.0);
    
    glMaterialfv(GL_FRONT, GL_SPECULAR, whiteColor);
    GLfloat shininess[] = {50};
    glMaterialfv(GL_FRONT, GL_SHININESS, shininess);

    // iterate over all 4 sides
    int i = 0;
    for ( i = 0; i < 4; i ++ )
    {
        glColor3f(0.873f, 0.873f, 0.873f);
        glRotatef(90.0, 0.0f, 1.0f, 0.0);
        
        glBindTexture(GL_TEXTURE_RECTANGLE_EXT, mTextures[0]);
        glBegin(GL_QUADS);
        {
            glTexCoord2f (0.0, mTextureSizes[0].height);
            glVertex3f(-1.0, -1.0, 1.0);
            glTexCoord2f(0.0, 0.0);
            glVertex3f(-1.0, 1.0, 1.0);
            glTexCoord2f (mTextureSizes[0].width, 0.0);
            glVertex3f( 1.0, 1.0, 1.0);
            glTexCoord2f (mTextureSizes[0].width, mTextureSizes[0].height);
            glVertex3f( 1.0, -1.0, 1.0);
        }
        glEnd();
        glBindTexture(GL_TEXTURE_RECTANGLE_EXT, 0);
        
        if ( mUpButtonState.showDepressed )
        {
            glMaterialfv(GL_FRONT, GL_DIFFUSE, pinkDiffusedColor);
            glMaterialfv(GL_FRONT, GL_AMBIENT, pinkAmbientColor);
        }
        else
        {
            glMaterialfv(GL_FRONT, GL_DIFFUSE, diffusedColor);
            glMaterialfv(GL_FRONT, GL_AMBIENT, ambientColor);
        }
        
        glBegin(GL_TRIANGLES);
        {
            glVertex3f(  0.0,  0.9, 1.002);
            glVertex3f( -0.75,  0.1, 1.002);
            glVertex3f(  0.75,  0.1 ,1.002);
        }
        glEnd();
        
        if ( mDownButtonState.showDepressed )
        {
            glMaterialfv(GL_FRONT, GL_DIFFUSE, pinkDiffusedColor);
            glMaterialfv(GL_FRONT, GL_AMBIENT, pinkAmbientColor);
        }
        else
        {
            glMaterialfv(GL_FRONT, GL_DIFFUSE, diffusedColor);
            glMaterialfv(GL_FRONT, GL_AMBIENT, ambientColor);
        }
        
        glBegin(GL_TRIANGLES);
        {
            glVertex3f(  0.0,  -0.9, 1.002);
            glVertex3f( -0.75,  -0.1, 1.002);
            glVertex3f(  0.75,  -0.1 ,1.002);
        }
        glEnd();
        
        glMaterialfv(GL_FRONT, GL_DIFFUSE, whiteColor);
        glMaterialfv(GL_FRONT, GL_AMBIENT, whiteColor);
        glBegin(GL_TRIANGLES);
        {
            glVertex3f(  0.0,  0.95, 1.001);
            glVertex3f( -0.85,  0.075, 1.001);
            glVertex3f(  0.85,  0.075,1.001);
            
            glVertex3f(  0.0,  -0.95, 1.001);
            glVertex3f( -0.85,  -0.075, 1.001);
            glVertex3f(  0.85,  -0.075,1.001);
        }
        glEnd();
    }
    
    glPopMatrix();
}


- (void) initOpenGLStates
{
    [[self openGLContext] makeCurrentContext];
    
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-0.5, 0.5, -0.5, 0.5, 1.0, 8.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.0, 0.0, -2.0);
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glEnable(GL_LIGHTING);

    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

    glEnable(GL_MULTISAMPLE);   
    glEnable(GL_TEXTURE_RECTANGLE_EXT);
    
   
    [self loadTextures];
}

@end
