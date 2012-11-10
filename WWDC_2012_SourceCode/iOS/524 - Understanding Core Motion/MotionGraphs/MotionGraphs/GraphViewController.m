
/*
     File: GraphViewController.m
 Abstract: Responsible for all UI interactions with the user and the sensors.
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

#import "GraphViewController.h"
#import "GraphView.h"
#import "MotionGraphsAppDelegate.h"

static const NSTimeInterval accelerometerMin = 0.01;
static const NSTimeInterval gyroMin = 0.01;
static const NSTimeInterval deviceMotionMin = 0.01;


@interface GraphViewController ()

@property (strong, nonatomic) IBOutlet GraphView *primaryGraph;
@property (strong, nonatomic) IBOutlet UILabel *primaryGraphLabel;
@property (weak, nonatomic) IBOutlet UILabel *xLabel;
@property (weak, nonatomic) IBOutlet UILabel *yLabel;
@property (weak, nonatomic) IBOutlet UILabel *zLabel;

@end



@implementation GraphViewController
{
    MotionDataType graphDataSource;

    NSArray *graphs;
    NSArray *graphTitles;

    CMMotionManager *mManager;

    __weak IBOutlet UISlider *updateIntervalSlider;
    __weak IBOutlet UILabel *updateIntervalLabel;
    __weak IBOutlet UISegmentedControl *segmentedControl;
}


@synthesize xLabel;
@synthesize yLabel;
@synthesize zLabel;

@synthesize primaryGraph, primaryGraphLabel;

- (id)initWithMotionDataType:(MotionDataType)type
{
    self = [self init];
    if (self) {
        graphDataSource = type;
    }
    return self;
}

- (IBAction)segmentedControlDidChanged:(UISegmentedControl *)sender
{
    GraphView *newView = [graphs objectAtIndex:sender.selectedSegmentIndex];
    [primaryGraph removeFromSuperview];
    [self.view addSubview:newView];
    primaryGraph = newView;
    primaryGraphLabel.text = [graphTitles objectAtIndex:sender.selectedSegmentIndex];
}

- (IBAction)onSliderValueChanged:(UISlider *)sender
{
    [self startUpdatesWithMotionDataType:graphDataSource andSliderValue:(int)(sender.value * 100)];
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    mManager = [(MotionGraphsAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];

    updateIntervalSlider.value = 0.0f;

    if (graphDataSource != kMotionDataTypeDeviceMotion) {
        segmentedControl.hidden = YES;
    } else {
        graphTitles = @[@"motion.attitude", @"motion.rotationRate", @"motion.gravity", @"motion.userAcceleration"];

        GraphView *attitudeGraph = primaryGraph;
        GraphView *rotationRateGraph = [[GraphView alloc] initWithFrame:primaryGraph.frame];
        GraphView *gravityGraph = [[GraphView alloc] initWithFrame:primaryGraph.frame];
        GraphView *userAccelerationGraph = [[GraphView alloc] initWithFrame:primaryGraph.frame];

        graphs = @[attitudeGraph, rotationRateGraph, gravityGraph, userAccelerationGraph];
    }
}

-(void)viewDidUnload
{
    [super viewDidUnload];

    updateIntervalSlider = nil;
    updateIntervalLabel = nil;
    segmentedControl = nil;
    graphs = nil;
    graphTitles = nil;
    mManager = nil;
    [self setXLabel:nil];
    [self setYLabel:nil];
    [self setZLabel:nil];
    self.primaryGraph = nil;
    self.primaryGraphLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startUpdatesWithMotionDataType:graphDataSource andSliderValue:(int)(updateIntervalSlider.value * 100)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopUpdatesWithMotionDataType:graphDataSource];
}

- (void)setLabelValueX:(double)x y:(double)y z:(double)z
{
    self.xLabel.text = [NSString stringWithFormat:@"x: %f", x];
    self.yLabel.text = [NSString stringWithFormat:@"y: %f", y];
    self.zLabel.text = [NSString stringWithFormat:@"z: %f", z];
}

- (void)setLabelValueRoll:(double)roll pitch:(double)pitch yaw:(double)yaw
{
    self.xLabel.text = [NSString stringWithFormat:@"roll: %f", roll];
    self.yLabel.text = [NSString stringWithFormat:@"pitch: %f", pitch];
    self.zLabel.text = [NSString stringWithFormat:@"yaw: %f", yaw];
}

- (void)startUpdatesWithMotionDataType:(MotionDataType)type andSliderValue:(int)sliderValue
{
    NSTimeInterval updateInterval;
    NSTimeInterval delta = 0.005;
    switch (graphDataSource) {
        case kMotionDataTypeAccelerometerData:
        {
            updateInterval = accelerometerMin + delta * sliderValue;

            if ([mManager isAccelerometerAvailable] == YES) {
                [mManager setAccelerometerUpdateInterval:updateInterval];
                [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                    [primaryGraph addX:accelerometerData.acceleration.x y:accelerometerData.acceleration.y z:accelerometerData.acceleration.z];
                    [self setLabelValueX:accelerometerData.acceleration.x y:accelerometerData.acceleration.y z:accelerometerData.acceleration.z];
                }];
            }
            primaryGraphLabel.text = @"accelerometerData.acceleration";
            break;
        }
        case kMotionDataTypeGyroData:
        {
            updateInterval = gyroMin + delta * sliderValue;

            if ([mManager isGyroAvailable] == YES) {
                [mManager setGyroUpdateInterval:updateInterval];
                [mManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
                    [primaryGraph addX:gyroData.rotationRate.x y:gyroData.rotationRate.y z:gyroData.rotationRate.z];
                    [self setLabelValueX:gyroData.rotationRate.x y:gyroData.rotationRate.y z:gyroData.rotationRate.z];
                }];
            }
            primaryGraphLabel.text = @"gyroData.rotationRate";
            break;
        }
        case kMotionDataTypeDeviceMotion:
        {
            updateInterval = deviceMotionMin + delta * sliderValue;

            if ([mManager isDeviceMotionAvailable] == YES) {
                [mManager setDeviceMotionUpdateInterval:updateInterval];
                [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
                    // attitude
                    [[graphs objectAtIndex:DeviceMotionGraphTypeAttitude] addX:motion.attitude.roll y:motion.attitude.pitch z:motion.attitude.yaw];
                    //rotationRate
                    [[graphs objectAtIndex:DeviceMotionGraphTypeRotationRate] addX:motion.rotationRate.x y:motion.rotationRate.y z:motion.rotationRate.z];
                    // gravity
                    [[graphs objectAtIndex:DeviceMotionGraphTypeGravity] addX:motion.gravity.x y:motion.gravity.y z:motion.gravity.z];
                    // userAcceleration
                    [[graphs objectAtIndex:DeviceMotionGraphTypeUserAcceleration] addX:motion.userAcceleration.x y:motion.userAcceleration.y z:motion.userAcceleration.z];

                    switch (segmentedControl.selectedSegmentIndex) {
                        case DeviceMotionGraphTypeAttitude:
                            [self setLabelValueRoll:motion.attitude.roll pitch:motion.attitude.pitch yaw:motion.attitude.yaw];
                            break;
                        case DeviceMotionGraphTypeRotationRate:
                            [self setLabelValueX:motion.rotationRate.x y:motion.rotationRate.y z:motion.rotationRate.z];
                            break;
                        case DeviceMotionGraphTypeGravity:
                            [self setLabelValueX:motion.gravity.x y:motion.gravity.y z:motion.gravity.z];
                            break;
                        case DeviceMotionGraphTypeUserAcceleration:
                            [self setLabelValueX:motion.userAcceleration.x y:motion.userAcceleration.y z:motion.userAcceleration.z];
                            break;
                        default:
                            break;
                    }
                }];
            }
            primaryGraphLabel.text = [graphTitles objectAtIndex:[segmentedControl selectedSegmentIndex]];
            break;
        }
        default:
            break;
    }
    updateIntervalLabel.text = [NSString stringWithFormat:@"%f", updateInterval];
}

- (void)stopUpdatesWithMotionDataType:(MotionDataType)type
{
    switch (graphDataSource) {
        case kMotionDataTypeAccelerometerData:
            if ([mManager isAccelerometerActive] == YES) {
                [mManager stopAccelerometerUpdates];
            }
            break;
        case kMotionDataTypeGyroData:
            if ([mManager isGyroActive] == YES) {
                [mManager stopGyroUpdates];
            }
            break;
        case kMotionDataTypeDeviceMotion:
            if ([mManager isDeviceMotionActive] == YES) {
                [mManager stopDeviceMotionUpdates];
            }
            break;
        default:
            break;
    }
}

@end
