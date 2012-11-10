
/*
     File: VideoSnakeViewController.m
 Abstract: View controller for camera interface
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

#import "VideoSnakeViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGLDrawable.h>

// UI
static CGFloat gLabelWidth;
static CGFloat gLabelHeight;
static CGFloat gLabelFontSize;
static CGFloat gLabelXPos;

static CGFloat gButtonWidth;
static CGFloat gButtonHeight;
static CGFloat gButtonFontSize;

static CGFloat gMaskTouchBorderWidth;
static CGFloat gMaskTouchWidth;

@interface VideoSnakeViewController ()

- (void)updateLabels;
- (void)initializeInterface;
- (void)createGestureRecognizers;

@end

@implementation VideoSnakeViewController

@synthesize videoSnakeSessionManager=_videoSnakeSessionManager;
@synthesize recordButton=_recordButton;

- (void)cleanup
{
	if (_orientationObserver) {
		[[NSNotificationCenter defaultCenter] removeObserver:_orientationObserver];
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
		_orientationObserver = nil;
	}
    
    [_recordButton release];
	_recordButton = nil;
	[_frameRateLabel release];
	_frameRateLabel = nil;
	[_dimensionsLabel release];
	_dimensionsLabel = nil;
	[_typeLabel release];  
	_typeLabel = nil;
    [_oglView release];
	_oglView = nil;
    self.videoSnakeSessionManager = nil;
}

- (void)dealloc
{

    [self cleanup];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self initializeInterface];
    [self createGestureRecognizers];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self cleanup];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI

- (UIButton *)buttonWithAction:(SEL)action text:(NSString *)text origin:(CGPoint)origin
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[button setFrame:CGRectMake(origin.x, origin.y, gButtonWidth, gButtonHeight)];
    [button setTitle:text forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	
    return button;
}

- (UILabel *)labelWithText:(NSString *)text yPosition:(CGFloat)yPosition
{	
	const CGRect layerRect = self.view.layer.bounds;
	CGFloat xPosition = layerRect.size.width - gLabelWidth - gLabelXPos;
	CGRect labelFrame = CGRectMake(xPosition, yPosition, gLabelWidth, gLabelHeight);
	UILabel *label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
	[label setFont:[UIFont systemFontOfSize:gLabelFontSize]];
	[label setLineBreakMode:NSLineBreakByWordWrapping];
	[label setTextAlignment:NSTextAlignmentRight];
	[label setTextColor:[UIColor whiteColor]];
	[label setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
	[label setText:text];
	return label;
}

double round(double r) {
	return (r > 0.0) ? floor(r + 0.5) : ceil(r - 0.5);
}

- (IBAction) toggleRenderEffect:(id)sender
{
	VideoSnakeRenderingEffect currentEffect = [[self glView] renderingEffect];
	VideoSnakeRenderingEffect newEffect = VideoSnakeRenderingEffect_Snake;
	
	if ( currentEffect == VideoSnakeRenderingEffect_Snake ) {
		newEffect = VideoSnakeRenderingEffect_Paint;
	}
	else if ( currentEffect == VideoSnakeRenderingEffect_Paint ) {
		newEffect = VideoSnakeRenderingEffect_Snake;
	}
	
	[[self glView] setRenderingEffect:newEffect];
}

- (void)updateLabels
{	
	if (_shouldShowStats) {
		NSString *frameRateString = [NSString stringWithFormat:@"%.2f FPS", _videoSnakeSessionManager.videoFrameRate];
		[_frameRateLabel setText:frameRateString];
		[_frameRateLabel setHidden:NO];
		
		NSString *dimensionsString = [NSString stringWithFormat:@"%d x %d", _videoSnakeSessionManager.videoDimensions.width, _videoSnakeSessionManager.videoDimensions.height];
		[_dimensionsLabel setText:dimensionsString];
		[_dimensionsLabel setHidden:NO];
		
		CMVideoCodecType type = _videoSnakeSessionManager.videoType;
        int32_t type4cc = OSSwapHostToBigInt32(type);
		NSString *typeString = [NSString stringWithFormat:@"%.4s", (char*)&type4cc];
		[_typeLabel setText:typeString];
		[_typeLabel setHidden:NO];
	}
	else {
		[_frameRateLabel setHidden:YES];
		[_frameRateLabel setText: @""];
		[_frameRateLabel setNeedsDisplay];
		
		[_dimensionsLabel setHidden:YES];
		[_dimensionsLabel setText: @""];
		[_dimensionsLabel setNeedsDisplay];
		
		[_typeLabel setHidden:YES];
		[_typeLabel setText: @""];
		[_typeLabel setNeedsDisplay];
	}
}

- (IBAction)record:(id)sender
{
    if ( _recording ) {
        [self.videoSnakeSessionManager stopRecording];
    }
    else {
        [self.videoSnakeSessionManager startRecording];
		_recording = YES;
		[self recordingWillStart];
    }
}

- (void)deviceOrientationDidChange
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    // Don't update the reference orientation when the device orientation is face up/down or unknown.
    if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) )
        [self.videoSnakeSessionManager setReferenceOrientation:orientation];
}

- (void)initializeInterface 
{
	const Boolean isIPad = ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone);
	gLabelWidth = (isIPad)?350.f:180.f;
	gLabelHeight = (isIPad)?40.f:20.f;
	gLabelFontSize = (isIPad)?36.f:18.f;
	gLabelXPos = (isIPad)?10.f:5.f;
	
	gButtonWidth = (isIPad)?120.f:70.f;
	gButtonFontSize = (isIPad)?20.f:14.f;
	
	gMaskTouchBorderWidth = (isIPad)?12.f:6.f;
	gMaskTouchWidth = (isIPad)?60.f:30.f;
	
    self.videoSnakeSessionManager = [[[VideoSnakeSessionManager alloc] init] autorelease];
    [self.videoSnakeSessionManager setDelegate:self callbackQueue:dispatch_get_main_queue()];
	
    // Keep track of changes to the device orientation so we can update the session manager
	_orientationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		[self deviceOrientationDidChange];
	}];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	[self.videoSnakeSessionManager setupAndStartCaptureSession];
	
    _shouldShowStats = NO;
    
	self.view.backgroundColor = [UIColor blackColor];
    
    // Set up GL view
    _oglView = [[VideoSnakeOpenGLView alloc] initWithFrame:CGRectZero];
    _oglView.transform = [self.videoSnakeSessionManager transformFromCurrentVideoOrientationToOrientation:UIInterfaceOrientationPortrait]; // Our view controller is always in portrait orientation
    [self.view addSubview:_oglView];
	[self setGlView:_oglView];
    CGRect bounds = CGRectZero;
    bounds.size = [self.view convertRect:self.view.bounds toView:_oglView].size;
    _oglView.bounds = bounds;
    _oglView.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    [_oglView release];
    
    // Set up button
	gButtonHeight = 44.0;
    const CGRect viewBounds = self.view.bounds;
    CGFloat originX = viewBounds.origin.x + viewBounds.size.width/2. - gButtonWidth/2.;
    CGFloat originY = viewBounds.size.height - gButtonHeight - 20.0;

    self.recordButton = [self buttonWithAction:@selector(record:) text:@"Record" origin:CGPointMake(originX, originY)];
    [self.view addSubview:self.recordButton];
    
	// Set up labels
	CGFloat yLabelPosition = 10.0f;
	_frameRateLabel = [[self labelWithText:@"" yPosition:yLabelPosition] retain];
	[self.view addSubview:_frameRateLabel];
	yLabelPosition += gLabelHeight;
	
	_dimensionsLabel = [[self labelWithText:@"" yPosition:yLabelPosition] retain];
	[self.view addSubview:_dimensionsLabel];
	yLabelPosition += gLabelHeight;
	
	_typeLabel = [[self labelWithText:@"" yPosition:yLabelPosition] retain];
	[self.view addSubview:_typeLabel];
//    yLabelPosition += gLabelHeight;
	
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
}

- (void)showError:(NSError *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

#pragma mark - Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the record button
    if (touch.view == self.recordButton) {
        return NO;
    }
    return YES;
}

- (void)createGestureRecognizers
{
    UITapGestureRecognizer *singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.delegate = self;
    [self.view addGestureRecognizer:singleTapRecognizer];
	
    UITapGestureRecognizer *tripleTapRecognizer;
    tripleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletripleTapFrom:)];
    tripleTapRecognizer.numberOfTapsRequired = 3;
	[singleTapRecognizer requireGestureRecognizerToFail:tripleTapRecognizer];
    tripleTapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tripleTapRecognizer];

    [singleTapRecognizer release];
    [tripleTapRecognizer release];
}

- (IBAction)handleSingleTapFrom:(UIGestureRecognizer *)sender
{
	[self toggleRenderEffect:self];
}

- (IBAction)handletripleTapFrom:(UIGestureRecognizer *)sender
{
	_shouldShowStats = !_shouldShowStats;
}

// We will only start recording based on the user touch events.
// Stopping may happen asynchronously due to an error or due to the app transitioning to the background.
- (void)recordingWillStart
{
	[[self recordButton] setEnabled:NO];
	[[self recordButton] setTitle:@"Stop" forState:UIControlStateNormal];
	
	// Disable the idle timer while we are recording
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	
	// Make sure we have time to finish saving the movie if the app is backgrounded during recording
	if ( [[UIDevice currentDevice] isMultitaskingSupported] )
		_backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
}

#pragma mark - VideoSnakeSessionManagerDelegate

- (void)setDimensions:(CMVideoDimensions)dimensions focalLenIn35mmFilm:(float)focalLenIn35mmFilm
{
    return [_oglView setDimensions:dimensions focalLenIn35mmFilm:focalLenIn35mmFilm];
}

- (OSStatus)displayAndRenderPixelBuffer:(CVImageBufferRef)srcPixelBuffer toPixelBuffer:(CVImageBufferRef)dstPixelBuffer motion:(CMDeviceMotion *)motion
{
    return [_oglView displayAndRenderPixelBuffer:srcPixelBuffer toPixelBuffer:dstPixelBuffer motion:motion];
}

- (void)finishRenderingPixelBuffer
{
    [_oglView finishRenderingPixelBuffer];
}

- (void)recordingDidStart
{
	[[self recordButton] setEnabled:YES];
}

- (void)recordingWillStop
{
	// Disable until saving to the camera roll is complete
	[[self recordButton] setEnabled:NO];
	[[self recordButton] setTitle:@"Record" forState:UIControlStateNormal];	
}

- (void)recordingDidStop
{
	_recording = NO;
	[[self recordButton] setEnabled:YES];
	[[self recordButton] setTitle:@"Record" forState:UIControlStateNormal];
	
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	
	if ( [[UIDevice currentDevice] isMultitaskingSupported] ) {
		[[UIApplication sharedApplication] endBackgroundTask:_backgroundRecordingID];
		_backgroundRecordingID = UIBackgroundTaskInvalid;
	}
}

- (void)recordingDidFailWithError:(NSError *)error
{
	[self recordingDidStop];
	[self showError:error];
}

@end
