
/*
     File: StarsViewController.m
 Abstract: The view controller that uses GLKit to render cubic stars. It uses device motion data to control the camera.
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

#import "StarsViewController.h"
#import <CoreMotion/CoreMotion.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

static const double RadiansToDegrees = (180.0/M_PI);

static const NSUInteger kNumCubes = 11;
static const NSUInteger kNumStars = 400;
static const float kMinStarHeight = 100.0f;
static const float kNearZ = 0.1f;
static const float kFarZ = 1000.0f;

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

typedef struct{
    float x, y, z;
} Vector3;

typedef Vector3 Vertex;
Vertex star[kNumStars];
int perm[kNumStars];

const GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,

    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,

    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,

    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,

    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,

    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

const float gColorData[kNumCubes * 3] =
{
    255.0, 51.0, 51.0,
    255.0, 153.0, 51.0,
    255.0, 255.0, 51.0,
    153.0, 255.0, 51.0,
    51.0, 255.0, 51.0,
    51.0, 255.0, 153.0,
    51.0, 255.0, 255.0,
    51.0, 153.0, 255.0,
    51.0, 51.0, 255.0,
    153.0, 51.0, 255.0,
    153.0, 153.0, 255.0
};

@interface StarsViewController () {
    float _rotation;

    GLuint _vertexArray;
    GLuint _vertexBuffer;

    UILabel *rpyLabel;

    CMMotionManager *motionManager;
    BOOL isDeviceMotionAvailable;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) NSMutableArray *effects;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation StarsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    // for planet positions
    [self generateRandomPermutation];

    // for star positions
    for(int i = 0; i < kNumStars; i++)
    {
        star[i].x = ((float)rand() / RAND_MAX - .5f) * kFarZ;
        star[i].y = ((float)rand() / RAND_MAX - .5f) * kFarZ;
        star[i].z = ((float)rand() / RAND_MAX) * (kFarZ - kMinStarHeight) + kMinStarHeight;
    }

    [self setupGL];

    motionManager = [[CMMotionManager alloc] init];
    isDeviceMotionAvailable = [motionManager isDeviceMotionAvailable];

    // the label for roll, pitch and yaw reading
    rpyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    rpyLabel.backgroundColor = [UIColor clearColor];
    rpyLabel.textColor = [UIColor whiteColor];
    rpyLabel.textAlignment = NSTextAlignmentCenter;
    rpyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:rpyLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [self tearDownGL];

    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
    rpyLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isDeviceMotionAvailable == YES) {
        motionManager.deviceMotionUpdateInterval = .01;
        [motionManager startDeviceMotionUpdates];
    } else {
        NSLog(@"Device motion is not available on device");
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([motionManager isDeviceMotionActive]) {
        [motionManager stopDeviceMotionUpdates];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];

    self.effects = [[NSMutableArray alloc] initWithCapacity:kNumCubes + kNumStars];
    for (int i = 0; i < kNumCubes; i++) {
        GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
        effect.light0.enabled = GL_TRUE;
        effect.light0.diffuseColor = GLKVector4Make(gColorData[3 * i]/255.0, gColorData[3 * i + 1]/255.0, gColorData[3 * i + 2]/255.0, 1.0f);
        [self.effects addObject:effect];
    }
    for (int i = 0; i < kNumStars; i++) {
        GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
        effect.light0.enabled = GL_TRUE;
        [self.effects addObject:effect];
    }

    glEnable(GL_DEPTH_TEST);

    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);

    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));

    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];

    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);

    self.effects = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    // we need to ensure device motion is available on device to continue
    if (!isDeviceMotionAvailable) {
        return;
    }

    CMDeviceMotion *dm = motionManager.deviceMotion;

    // in case we don't have any sample yet, simply return...
    if (dm == nil) {
        return;
    }

    CMRotationMatrix r = dm.attitude.rotationMatrix;

    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, kNearZ, kFarZ);

    GLKMatrix4 baseModelViewMatrix;
    baseModelViewMatrix = GLKMatrix4Make(r.m11, r.m21, r.m31, 0.0f,
                                         r.m12, r.m22, r.m32, 0.0f,
                                         r.m13, r.m23, r.m33, 0.0f,
                                         0.0f,  0.0f,  0.0f,  1.0f);

    // Compute the model view matrix for the objects rendered with GLKit
    // the planets
    for (int i = 0; i < kNumCubes; i++) {
        GLKBaseEffect *effect = [self.effects objectAtIndex:i];
        effect.transform.projectionMatrix = projectionMatrix;
        GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, 2 * M_PI / kNumCubes * i, 0.0f, 0.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, (float)perm[i] * 5.0f + 10, (float)i, 0.0f);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);

        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

        effect.transform.modelviewMatrix = modelViewMatrix;
    }

    // ... and the stars
    for (int j = 0; j < kNumStars; j++) {
        GLKBaseEffect *effect = [self.effects objectAtIndex:(kNumCubes + j)];
        effect.transform.projectionMatrix = projectionMatrix;

        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(star[j].x, star[j].y, star[j].z);

        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

        effect.transform.modelviewMatrix = modelViewMatrix;
    }

    _rotation += self.timeSinceLastUpdate * 0.8f;

    rpyLabel.text = [NSString stringWithFormat:@"roll: %3.1f° pitch: %3.1f° yaw: %3.1f°", dm.attitude.roll * RadiansToDegrees, dm.attitude.pitch * RadiansToDegrees, dm.attitude.yaw * RadiansToDegrees];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if (!isDeviceMotionAvailable) {
        return;
    }

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glBindVertexArrayOES(_vertexArray);

    // Render the objects with GLKit
    int begin = 0, end = kNumCubes + kNumStars;
    for (int i = begin; i < end; i++) {
        GLKBaseEffect *effect = [self.effects objectAtIndex:i];
        [effect prepareToDraw];
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
}

#pragma mark - Utility methods

- (void)generateRandomPermutation
{
    for(int i = 0; i < kNumCubes; i++) {
        perm[i] = i + 1;
    }

    for(int i = 0; i < kNumCubes; i++) {
        int j = rand() % (i + 1);
        perm[i] = perm[j];
        perm[j] = i;
    }
}

@end
