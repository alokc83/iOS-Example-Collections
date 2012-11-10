
/*
     File: CubeView.m
 Abstract: 
 
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

#import "CubeView.h"

#define NUMBER_OF_LITTLE_CUBES  20
#define LITTLE_CUBE_WIDTH      (320.f / 3.f)
#define SCROLLER_HEIGHT        LITTLE_CUBE_WIDTH

typedef struct {
    float red;   float green; float blue;
    float xAxis; float yAxis; float zAxis;
    float speed;   // in full rotations per second
    float rotationRadians;
} CubeInfo;


@interface CubeView () {
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLKBaseEffect *_effect;
    
    CubeInfo _littleCube[NUMBER_OF_LITTLE_CUBES];
    CubeInfo _bigCube;
    CubeInfo _bigCubeDirections;
    CFTimeInterval _timeOfLastRenderedFrame;
}

@end

@implementation CubeView

- (CGRect)scrollableFrame
{
    return CGRectMake(0, 30, 320, SCROLLER_HEIGHT);
}

- (CGSize)scrollableContentSize
{
    CGFloat width = NUMBER_OF_LITTLE_CUBES * LITTLE_CUBE_WIDTH;
    return CGSizeMake(ceilf(width), SCROLLER_HEIGHT);
}

- (CGPoint)scrollOffsetForProposedOffset:(CGPoint)offset
{
    CGFloat fractionalPart = fmodf(offset.x, LITTLE_CUBE_WIDTH);
    BOOL roundDown = fractionalPart < (LITTLE_CUBE_WIDTH / 2.f);
    if (roundDown) {
        offset.x -= fractionalPart;
    } else {
        offset.x += (LITTLE_CUBE_WIDTH - fractionalPart);
    }
    
    return offset;
}

#pragma mark - Warning: Inexpert OpenGL Code Below This Point

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupGL];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    float aspect = fabsf(self.bounds.size.width / self.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);    
    _effect.transform.projectionMatrix = projectionMatrix;
}

#pragma mark GLKViewControllerDelegate

#define UNIT_LITTLE_CUBE_WIDTH 2.f

- (void)drawRect:(CGRect)rect
{
    [self updateCubes];
    
    glClearColor(0.15f, 0.15f, 0.15f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.f, 0.f, 0.f);
    
    for (int i = 0; i < NUMBER_OF_LITTLE_CUBES; i++) {
        CubeInfo cube = _littleCube[i];
        
        float translationX = ((i - 1) * UNIT_LITTLE_CUBE_WIDTH) - (self.scrollOffset.x * UNIT_LITTLE_CUBE_WIDTH / LITTLE_CUBE_WIDTH);
        GLKMatrix4 cubeMatrix = GLKMatrix4MakeTranslation(translationX, 2.8f, -7.f);
        cubeMatrix = GLKMatrix4Rotate(cubeMatrix, cube.rotationRadians, cube.xAxis, cube.yAxis, cube.zAxis);
        
        _effect.light0.diffuseColor = GLKVector4Make(cube.red, cube.green, cube.blue, 1.f);
        _effect.transform.modelviewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, cubeMatrix);
        [_effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    
    GLKMatrix4 bigCubeMatrix = GLKMatrix4MakeTranslation(0.f, -0.5f, -3.f);
    bigCubeMatrix = GLKMatrix4Rotate(bigCubeMatrix, _bigCube.rotationRadians, _bigCube.xAxis, _bigCube.yAxis, _bigCube.zAxis);
    
    _effect.light0.diffuseColor = GLKVector4Make(_bigCube.red, _bigCube.green, _bigCube.blue, 1.f);
    _effect.transform.modelviewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, bigCubeMatrix);
    [_effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 1) {
        [self handleTapAtPoint:[touch locationInView:self]];
    }
}

- (void)handleTapAtPoint:(CGPoint)point
{
    CGRect bigCubeRect = CGRectMake(70, 210, 180, 180);
    CGRect scrollViewRect = [self scrollableFrame];
    
    if (CGRectContainsPoint(bigCubeRect, point)) {
        [self handleBigCubeTap];
    } else if (CGRectContainsPoint(scrollViewRect, point)) {
        CGFloat adjustedX = point.x + self.scrollOffset.x;
        int cubeIndex = floorf(adjustedX / LITTLE_CUBE_WIDTH);
        [self handleLittleCubeTap:cubeIndex];
    }
}

- (void)handleBigCubeTap
{
    [self randomizeBigCube];
}

- (void)handleLittleCubeTap:(int)index
{
    _littleCube[index] = _bigCube;
}


#pragma mark -

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

GLfloat gCubeVertexData[216] = 
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

- (void)setupGL
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    _effect = [[GLKBaseEffect alloc] init];
    _effect.light0.enabled = GL_TRUE;
    
    [EAGLContext setCurrentContext:self.context];
    
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
    
    [self randomizeBigCube];
    for (int i = 0; i < NUMBER_OF_LITTLE_CUBES; i++) {
        _littleCube[i] = _bigCube;
    }
    _timeOfLastRenderedFrame = CACurrentMediaTime();
}

static const CubeInfo _minimums = { 0.1f,  0.1f,   0.1f,  -1.f,  -1.f,  -1.f,   -0.5f,  0.f };
static const CubeInfo _maximums = { 1.0f,  1.0f,   1.0f,   1.f,   1.f,   1.f,    0.5f,  M_PI * 2 };
static const CubeInfo _deltas   = { 0.02f, 0.018f, 0.016f, 0.01f, 0.02f, 0.03f,  0.01f, 0.f }; // change rate per second

#define RANDOM_FLOAT(min, max)   (min + (((arc4random_uniform(1000) / 1000.0) * (max - min))))
#define RANDOM_BOOL()            ((BOOL)(arc4random_uniform(2)))
#define POSITIVE_OR_NEGATIVE_F() (RANDOM_BOOL() ? 1.f : -1.f)

static float UpdatedRotationRadians(float radians, float speed, CFTimeInterval elapsedTime);

- (void)randomizeBigCube
{
    _bigCube.red   = RANDOM_FLOAT(_minimums.red,   _maximums.red);
    _bigCube.green = RANDOM_FLOAT(_minimums.green, _maximums.green);
    _bigCube.blue  = RANDOM_FLOAT(_minimums.blue,  _maximums.blue);
    _bigCube.xAxis = RANDOM_FLOAT(_minimums.xAxis, _maximums.xAxis);
    _bigCube.yAxis = RANDOM_FLOAT(_minimums.yAxis, _maximums.yAxis);
    _bigCube.zAxis = RANDOM_FLOAT(_minimums.zAxis, _maximums.zAxis);
    _bigCube.speed = RANDOM_FLOAT(_minimums.speed, _maximums.speed);
    _bigCube.rotationRadians = RANDOM_FLOAT(_minimums.rotationRadians, _maximums.rotationRadians);
    
    _bigCubeDirections.red   = POSITIVE_OR_NEGATIVE_F();
    _bigCubeDirections.green = POSITIVE_OR_NEGATIVE_F();
    _bigCubeDirections.blue  = POSITIVE_OR_NEGATIVE_F();
    _bigCubeDirections.xAxis = POSITIVE_OR_NEGATIVE_F();
    _bigCubeDirections.yAxis = POSITIVE_OR_NEGATIVE_F();
    _bigCubeDirections.zAxis = POSITIVE_OR_NEGATIVE_F();
    _bigCubeDirections.speed = POSITIVE_OR_NEGATIVE_F();
    _bigCubeDirections.rotationRadians = 0;
}

- (void)updateCubes
{
    CFTimeInterval elapsedTime = CACurrentMediaTime() - _timeOfLastRenderedFrame;
    
    _bigCube.red = _bigCube.red + (_bigCubeDirections.red * _deltas.red * elapsedTime);
    if (_bigCube.red < _minimums.red || _bigCube.red > _maximums.red) {
        _bigCube.red = MAX(_minimums.red, MIN(_maximums.red, _bigCube.red));
        _bigCubeDirections.red *= -1;
    }
    
    _bigCube.green = _bigCube.green + (_bigCubeDirections.green * _deltas.green * elapsedTime);
    if (_bigCube.green < _minimums.green || _bigCube.green > _maximums.green) {
        _bigCube.green = MAX(_minimums.green, MIN(_maximums.green, _bigCube.green));
        _bigCubeDirections.green *= -1;
    }
    
    _bigCube.blue = _bigCube.blue + (_bigCubeDirections.blue * _deltas.blue * elapsedTime);
    if (_bigCube.blue < _minimums.blue || _bigCube.blue > _maximums.blue) {
        _bigCube.blue = MAX(_minimums.blue, MIN(_maximums.blue, _bigCube.blue));
        _bigCubeDirections.blue *= -1;
    }
    
    _bigCube.xAxis = _bigCube.xAxis + (_bigCubeDirections.xAxis * _deltas.xAxis * elapsedTime);
    if (_bigCube.xAxis < _minimums.xAxis || _bigCube.xAxis > _maximums.xAxis) {
        _bigCube.xAxis = MAX(_minimums.xAxis, MIN(_maximums.xAxis, _bigCube.xAxis));
        _bigCubeDirections.xAxis *= -1;
    }
    
    _bigCube.yAxis = _bigCube.yAxis + (_bigCubeDirections.yAxis * _deltas.yAxis * elapsedTime);
    if (_bigCube.yAxis < _minimums.yAxis || _bigCube.yAxis > _maximums.yAxis) {
        _bigCube.yAxis = MAX(_minimums.yAxis, MIN(_maximums.yAxis, _bigCube.yAxis));
        _bigCubeDirections.yAxis *= -1;
    }
    
    _bigCube.zAxis = _bigCube.zAxis + (_bigCubeDirections.zAxis * _deltas.zAxis * elapsedTime);
    if (_bigCube.zAxis < _minimums.zAxis || _bigCube.zAxis > _maximums.zAxis) {
        _bigCube.zAxis = MAX(_minimums.zAxis, MIN(_maximums.zAxis, _bigCube.zAxis));
        _bigCubeDirections.zAxis *= -1;
    }
    
    _bigCube.speed = _bigCube.speed + (_bigCubeDirections.speed * _deltas.speed * elapsedTime);
    if (_bigCube.speed < _minimums.speed || _bigCube.speed > _maximums.speed) {
        _bigCube.speed = MAX(_minimums.speed, MIN(_maximums.speed, _bigCube.speed));
        _bigCubeDirections.speed *= -1;
    }
    
    _bigCube.rotationRadians = UpdatedRotationRadians(_bigCube.rotationRadians, _bigCube.speed, elapsedTime);
    
    for (int i = 0; i < NUMBER_OF_LITTLE_CUBES; i++) {
        _littleCube[i].rotationRadians = UpdatedRotationRadians(_littleCube[i].rotationRadians, _littleCube[i].speed, elapsedTime);
    }
    
    _timeOfLastRenderedFrame = CACurrentMediaTime();
}

@end

static float UpdatedRotationRadians(float radians, float speed, CFTimeInterval elapsedTime)
{
    float speedInRadians = speed * M_PI * 2;
    float radiansDelta = speedInRadians * elapsedTime;
    return fmodf(radians + radiansDelta, M_PI * 2);
}

