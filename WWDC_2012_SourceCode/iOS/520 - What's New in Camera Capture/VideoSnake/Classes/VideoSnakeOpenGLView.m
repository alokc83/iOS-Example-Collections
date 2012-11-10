
/*
     File: VideoSnakeOpenGLView.m
 Abstract: The OpenGL ES view, responsible for rendering the video effect.
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

#include "VideoSnakeOpenGLView.h"
#import <QuartzCore/CAEAGLLayer.h>
#include "ShaderUtilities.h"
#include "matrix.h"


static const float kWhiteUniform[4] = {1.0, 1.0, 1.0, 1.0};
static const float kBlackUniform[4] = {0.0, 0.0, 0.0, 1.0};

@interface VideoSnakeOpenGLView ()

- (BOOL)initializeBuffers;
- (void)deleteBuffers;

@end

@implementation VideoSnakeOpenGLView

@synthesize renderingBackgroundColor = _renderingBackgroundColor;
@synthesize renderingEffect = _renderingEffect;

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

- (void)setupGLES
{
    // Use 2x scale factor on Retina displays.
    self.contentScaleFactor = [[UIScreen mainScreen] scale];

    CAEAGLLayer* eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];
 	_oglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	if (!_oglContext || ![EAGLContext setCurrentContext:_oglContext] || ![self initializeBuffers]) {
		NSLog(@"Problem with OpenGL context.");
    }
}

- (void)dealloc 
{
	if (_referenceAttitude)
		[_referenceAttitude release];
	if (_lastAttitude)
		[_lastAttitude release];

    [self deleteBuffers];
	
    [super dealloc];
}

#pragma mark - OpenGL

enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,    
    NUM_ATTRIBUTES
};

- (void)present 
{
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    [_oglContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (const GLchar *)readFile:(NSString *)name
{
    NSString *path;
    const GLchar *source;
    
    path = [[NSBundle mainBundle] pathForResource:name ofType: nil];
    source = (GLchar *)[[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    return source;
}

- (BOOL)initializeBuffers
{
    glDisable(GL_DEPTH_TEST);
    
    self.renderingBackgroundColor = VideoSnakeRenderingColor_Black;

    _internalRenderingEffect = self.renderingEffect;
	
    glGenFramebuffers(1, &_frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    
    glGenRenderbuffers(1, &_colorBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    
    [_oglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
	
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);   
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failure with framebuffer generation");
		return NO;
	}   

    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _oglContext, NULL, &_videoTextureCache);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return NO;
    }
    
    glGenFramebuffers(1, &_offscreenBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
    
    err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _oglContext, NULL, &_videoWritingTextureCache);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return NO;
    }
    
    // Load vertex and fragment shaders
    GLint attribLocation[NUM_ATTRIBUTES] = {
        ATTRIB_VERTEX, ATTRIB_TEXTUREPOSITON,
    };
    GLchar *attribName[NUM_ATTRIBUTES] = {
        "position", "texturecoordinate",			
    };
    
    const GLchar *videoSnakeVertSrc = [self readFile:@"videoSnake.vsh"];
    const GLchar *videoSnakeFragSrc = [self readFile:@"videoSnake.fsh"];
    
    // videoSnake shader program
    glueCreateProgram(videoSnakeVertSrc, videoSnakeFragSrc,
                      NUM_ATTRIBUTES, (const GLchar **)&attribName[0], attribLocation,
                      0, 0, 0,
                      &_program);
    if (!_program) {
        return NO;
    }
    _frame = glueGetUniformLocation(_program, "videoframe");
    _backgroundColor = glueGetUniformLocation(_program, "backgroundcolor");
    _modelView = glueGetUniformLocation(_program, "amodelview");
    _projection = glueGetUniformLocation(_program, "aprojection");
    
    const GLchar *passThroughVertSrc = [self readFile:@"passThrough.vsh"];
    const GLchar *passThroughFragSrc = [self readFile:@"passThrough.fsh"];
    
    // passThrough shader program
    glueCreateProgram(passThroughVertSrc, passThroughFragSrc,
                      NUM_ATTRIBUTES, (const GLchar **)&attribName[0], attribLocation,
                      0, 0, 0,
                      &_passthruProgram);
    if (!_passthruProgram) {
        return NO;
    }
    _passthruFrame = glueGetUniformLocation(_passthruProgram, "videoframe");
    
    return YES;
}

- (void)deleteBuffers 
{
    if (_frameBufferHandle) {
        glDeleteFramebuffers(1, &_frameBufferHandle);
        _frameBufferHandle = 0;
    }
    if (_offscreenBufferHandle) {
        glDeleteFramebuffers(1, &_offscreenBufferHandle);
        _offscreenBufferHandle = 0;
    }    
    if (_colorBufferHandle) {
        glDeleteRenderbuffers(1, &_colorBufferHandle);
        _colorBufferHandle = 0;
    }
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    if (_passthruProgram) {
        glDeleteProgram(_passthruProgram);
        _passthruProgram = 0;
    }
    if (_backFramePixelBuffer) {
        CFRelease(_backFramePixelBuffer);
        _backFramePixelBuffer = 0;
    }
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
        _videoTextureCache = 0;
    }
    if (_videoWritingTextureCache) {
        CFRelease(_videoWritingTextureCache);
        _videoWritingTextureCache = 0;
    }    
}

- (void)setDimensions:(CMVideoDimensions)dimensions focalLenIn35mmFilm:(float)focalLenIn35mmFilm
{
     _offscreenDimensions = dimensions;
    _focalLenIn35mmFilm = focalLenIn35mmFilm;
    if (!_oglContext) {
        [self setupGLES];
    }
}

- (OSStatus)displayAndRenderPixelBuffer:(CVImageBufferRef)srcPixelBuffer toPixelBuffer:(CVImageBufferRef)dstPixelBuffer motion:(CMDeviceMotion *)motion
{
	OSStatus err = noErr;
    if (_internalRenderingEffect != _renderingEffect) {
        _internalRenderingEffect = _renderingEffect;
        if (_referenceAttitude) {
            [_referenceAttitude release];
            _referenceAttitude = nil;
        }
        if (_lastAttitude) {
            [_lastAttitude release];
            _lastAttitude = nil;
        }
        _velocityX = 0.;
        _velocityY = 0.;
        _lastMotionTime = 0;
        if (_backFramePixelBuffer) {
            CFRelease(_backFramePixelBuffer);
            _backFramePixelBuffer = 0;
        }
    }
	if ( _renderingEffect == VideoSnakeRenderingEffect_Snake ) {
		err = [self displayAndRenderPixelBuffer_Snake:srcPixelBuffer toPixelBuffer:dstPixelBuffer motion:motion];
	}
	else if ( _renderingEffect == VideoSnakeRenderingEffect_Paint ) {
		err = [self displayAndRenderPixelBuffer_Paint:srcPixelBuffer toPixelBuffer:dstPixelBuffer motion:motion];
	}
	
	return err;
}

- (OSStatus)displayAndRenderPixelBuffer_Snake:(CVImageBufferRef)srcPixelBuffer toPixelBuffer:(CVImageBufferRef)dstPixelBuffer motion:(CMDeviceMotion *)motion
{
    static const float kAmplifier = 15.0;
    static const float kDamper = 0.75;
    static const float kFrontScaleFactor = 0.25;
    static const float kBackScaleFactor = 0.85;
    
    CVReturn err = noErr;
    static const float squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
	static const float textureVertices[] = {
        0.0f, 0.0f, 
        1.0f, 0.0f,
        0.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    CVOpenGLESTextureRef srcTexture = NULL;
    CVOpenGLESTextureRef destTexture = NULL;
    CVOpenGLESTextureRef previousTexture = NULL;
    
    if (!_offscreenBufferHandle || !srcPixelBuffer || !dstPixelBuffer || !motion) {
        err = -50;
        goto bail;
    }
    
    if (NULL == _videoWritingTextureCache ||
        NULL == _videoTextureCache) {
        err = -50;
        goto bail;
    }
    
    if (!_lastMotionTime) {
        _lastMotionTime = motion.timestamp;
    }
    NSTimeInterval timeDelta = motion.timestamp - _lastMotionTime;
    _lastMotionTime = motion.timestamp;
    
    _velocityX += (motion.userAcceleration.x*timeDelta);
    _velocityX =  kDamper * _velocityX;
    
    _velocityY += (motion.userAcceleration.y*timeDelta);
    _velocityY =  kDamper * _velocityY;
    
    float transBack[3] = {-_velocityY*kAmplifier,-_velocityX*kAmplifier, 0.};
    float scaleBack[3] = {kBackScaleFactor, kBackScaleFactor, 0.};
    
	size_t srcWidth = CVPixelBufferGetWidth(srcPixelBuffer);
	size_t srcHeight = CVPixelBufferGetHeight(srcPixelBuffer);
	size_t destWidth = CVPixelBufferGetWidth(dstPixelBuffer);
	size_t destHeight = CVPixelBufferGetHeight(dstPixelBuffer);
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       srcPixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       srcWidth,
                                                       srcHeight,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &srcTexture);    
    if (!srcTexture || err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        goto bail;
    }
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoWritingTextureCache,
                                                       dstPixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       destWidth,
                                                       destHeight,
                                                       GL_BGRA, 
                                                       GL_UNSIGNED_BYTE,                                                             
                                                       0,
                                                       &destTexture);
    
    if (!destTexture || err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        goto bail;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
	glViewport(0, 0, _offscreenDimensions.width, _offscreenDimensions.height);
    glUseProgram(_program);    
 
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture), 0);
    
    float modelview[16], projection[16];
    
    // setup projection matrix (orthographic)
    const float ortho = 1.;
    mat4f_LoadOrtho(-ortho, ortho, -ortho, ortho, -ortho, ortho, projection);    
    glUniformMatrix4fv(_projection, 1, GL_FALSE, projection);
    
    if (_backFramePixelBuffer) {
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _videoWritingTextureCache,
                                                           _backFramePixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RGBA,
                                                           destWidth,
                                                           destHeight,
                                                           GL_BGRA, 
                                                           GL_UNSIGNED_BYTE,                                                             
                                                           0,
                                                           &previousTexture);
        
        if (!previousTexture || err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            goto bail;
        }
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(CVOpenGLESTextureGetTarget(previousTexture), CVOpenGLESTextureGetName(previousTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); 
        
        float translation[16];
        mat4f_LoadTranslation(transBack, translation);

        float scaling[16];
        mat4f_LoadScale(scaleBack, scaling);
        
        mat4f_MultiplyMat4f(translation, scaling, modelview);
        
        glUniformMatrix4fv(_modelView, 1, GL_FALSE, modelview);
        
        glUniform1i(_frame, 0);
        
        switch(_renderingBackgroundColor)
        {
            case VideoSnakeRenderingColor_White:
            {
                glClearColor(kWhiteUniform[0], kWhiteUniform[1], kWhiteUniform[2], kWhiteUniform[3]);
                glUniform4fv(_backgroundColor, 1, kWhiteUniform);
                break;
            }
            case VideoSnakeRenderingColor_Black:
            default:
            {
                glClearColor(kBlackUniform[0], kBlackUniform[1], kBlackUniform[2], kBlackUniform[3]);
                glUniform4fv(_backgroundColor, 1, kBlackUniform);
                break;
            }
        }    
        glClear(GL_COLOR_BUFFER_BIT);    
        
        glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
        glEnableVertexAttribArray(ATTRIB_VERTEX);
        glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
        glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glBindTexture(CVOpenGLESTextureGetTarget(previousTexture), 0);
    }
    else {
        glClear(GL_COLOR_BUFFER_BIT);  
    }
	
    glActiveTexture(GL_TEXTURE0);
	glBindTexture(CVOpenGLESTextureGetTarget(srcTexture), CVOpenGLESTextureGetName(srcTexture));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float scaleFront[3] = {kFrontScaleFactor, kFrontScaleFactor, 0.0};
    mat4f_LoadScale(scaleFront, modelview);
    
    glUniformMatrix4fv(_modelView, 1, GL_FALSE, modelview);
    
    glUniform1i(_frame, 0);
    
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
	glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindTexture(CVOpenGLESTextureGetTarget(srcTexture), 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);    
	glViewport(0, 0, _width, _height);	
    
    glActiveTexture(GL_TEXTURE1);
	glBindTexture(CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture));
    
    glUseProgram(_passthruProgram);
    
    glUniform1i(_frame, 1);
    
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
    
    // Preserve aspect ratio; fill layer bounds
    CGSize textureSamplingSize;
    CGSize cropScaleAmount = CGSizeMake(self.bounds.size.width / (float)_offscreenDimensions.width, self.bounds.size.height / (float)_offscreenDimensions.height);
    if ( cropScaleAmount.height > cropScaleAmount.width ) {
        textureSamplingSize.width = self.bounds.size.width / (_offscreenDimensions.width * cropScaleAmount.height);
        textureSamplingSize.height = 1.0;
    }
    else {
        textureSamplingSize.width = 1.0;        
        textureSamplingSize.height = self.bounds.size.height / (_offscreenDimensions.height * cropScaleAmount.width);
    }
    
    GLfloat passthruTextureVertices[] = {
        (1.0 - textureSamplingSize.width)/2.0, (1.0 + textureSamplingSize.height)/2.0,
        (1.0 + textureSamplingSize.width)/2.0, (1.0 + textureSamplingSize.height)/2.0,
        (1.0 - textureSamplingSize.width)/2.0, (1.0 - textureSamplingSize.height)/2.0,
        (1.0 + textureSamplingSize.width)/2.0, (1.0 - textureSamplingSize.height)/2.0,
    };

	glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, passthruTextureVertices);
	glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self present];
    
    glBindTexture(CVOpenGLESTextureGetTarget(destTexture), 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    if (_backFramePixelBuffer) {
        CFRelease(_backFramePixelBuffer);
        _backFramePixelBuffer = NULL;
    }
    _backFramePixelBuffer = (CVImageBufferRef)CFRetain(dstPixelBuffer);
    
bail:
    if (srcTexture) {
        CFRelease(srcTexture);
    }
    if (previousTexture) {
        CFRelease(previousTexture);
    }
    if (destTexture) {
        CFRelease(destTexture);
    }
    return err;
}

- (OSStatus)displayAndRenderPixelBuffer_Paint:(CVImageBufferRef)srcPixelBuffer toPixelBuffer:(CVImageBufferRef)dstPixelBuffer motion:(CMDeviceMotion *)motion
{
    static const float kRefreshDistance = M_PI / 16.;
    static const float kFrontScaleFactor = 0.125;
    
    CVReturn err = noErr;
    static const float squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
	static const float textureVertices[] = {
        0.0f, 0.0f, 
        1.0f, 0.0f,
        0.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    CVOpenGLESTextureRef srcTexture = NULL;
    CVOpenGLESTextureRef destTexture = NULL;
    CVOpenGLESTextureRef previousTexture = NULL;
    CMAttitude * attitude = motion.attitude;
    
    if (!_offscreenBufferHandle || !srcPixelBuffer || !dstPixelBuffer || !attitude) {
        err = -50;
        goto bail;
    }
    
    if (NULL == _videoWritingTextureCache ||
        NULL == _videoTextureCache) {
        err = -50;
        goto bail;
    }
    
    if (!_referenceAttitude) {
        _referenceAttitude = [attitude copy];
    }
    [attitude multiplyByInverseOfAttitude:_referenceAttitude];
    if (!_lastAttitude) {
        _lastAttitude = [attitude copy];
    }
    
    Boolean refreshBackFrame =  false;
    CMAttitude* copyAttitude = [attitude copy];
    [copyAttitude multiplyByInverseOfAttitude:_lastAttitude];
    if (copyAttitude.roll <= -kRefreshDistance || copyAttitude.roll >= kRefreshDistance ||
        copyAttitude.pitch <= -kRefreshDistance || copyAttitude.pitch >= kRefreshDistance) {
        refreshBackFrame = true;
        [_lastAttitude release];
        _lastAttitude = [attitude copy];
    }

    const float fov = atanf(36./(2.*_focalLenIn35mmFilm));
    const float fovFactor = 1 / sin(fov);
    const float trans[3] = {kFrontScaleFactor * sin(copyAttitude.pitch) * fovFactor, -kFrontScaleFactor * sin(copyAttitude.roll) * fovFactor, 0.};
    const float rot = copyAttitude.yaw;
    [copyAttitude release];
    
	size_t srcWidth = CVPixelBufferGetWidth(srcPixelBuffer);
	size_t srcHeight = CVPixelBufferGetHeight(srcPixelBuffer);
	size_t destWidth = CVPixelBufferGetWidth(dstPixelBuffer);
	size_t destHeight = CVPixelBufferGetHeight(dstPixelBuffer);
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       srcPixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       srcWidth,
                                                       srcHeight,
                                                       GL_BGRA,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &srcTexture);    
    if (!srcTexture || err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        goto bail;
    }
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoWritingTextureCache,
                                                       dstPixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RGBA,
                                                       destWidth,
                                                       destHeight,
                                                       GL_BGRA, 
                                                       GL_UNSIGNED_BYTE,                                                             
                                                       0,
                                                       &destTexture);
    
    if (!destTexture || err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        goto bail;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, _offscreenBufferHandle);
	glViewport(0, 0, _offscreenDimensions.width, _offscreenDimensions.height);
    glUseProgram(_program);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture), 0);    
    
    float modelview[16], projection[16];
    
    // setup projection matrix (orthographic)
    const float ortho = 1.;
    mat4f_LoadOrtho(-ortho, ortho, -ortho, ortho, -ortho, ortho, projection);
    glUniformMatrix4fv(_projection, 1, GL_FALSE, projection);    
    
    if (_backFramePixelBuffer) {
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _videoWritingTextureCache,
                                                           _backFramePixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RGBA,
                                                           destWidth,
                                                           destHeight,
                                                           GL_BGRA, 
                                                           GL_UNSIGNED_BYTE,                                                             
                                                           0,
                                                           &previousTexture);
        
        if (!previousTexture || err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            goto bail;
        }    
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(CVOpenGLESTextureGetTarget(previousTexture), CVOpenGLESTextureGetName(previousTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); 
            
        const float scaleAspect[3] = {1.0, _offscreenDimensions.width / (float)_offscreenDimensions.height, 0.0};
        float scalingAspect[16];
        mat4f_LoadScale((float *)scaleAspect, scalingAspect);
        
        const float scaleInvertAspect[3] = {1.0, _offscreenDimensions.height/(float)_offscreenDimensions.width, 0.0};
        float scalingInvertAspect[16];
        mat4f_LoadScale((float *)scaleInvertAspect, scalingInvertAspect);
        
        float rotation[16];
        mat4f_LoadZRotation(rot, rotation);
        
        float translation[16];
        mat4f_LoadTranslation((float *)trans, translation);

        float temp0[16];
        float temp1[16];
        
        mat4f_MultiplyMat4f(scalingAspect, rotation, temp0);
        mat4f_MultiplyMat4f(temp0, translation, temp1);
        mat4f_MultiplyMat4f(temp1, scalingInvertAspect, modelview);
        
        glUniformMatrix4fv(_modelView, 1, GL_FALSE, modelview);

        glUniform1i(_frame, 0);
        
        switch(_renderingBackgroundColor)
        {
            case VideoSnakeRenderingColor_White:
            {
                glClearColor(kWhiteUniform[0], kWhiteUniform[1], kWhiteUniform[2], kWhiteUniform[3]);
                glUniform4fv(_backgroundColor, 1, kWhiteUniform);
                break;
            }
            case VideoSnakeRenderingColor_Black:
            default:
            {
                glClearColor(kBlackUniform[0], kBlackUniform[1], kBlackUniform[2], kBlackUniform[3]);
                glUniform4fv(_backgroundColor, 1, kBlackUniform);
                break;
            }
        }
        glClear(GL_COLOR_BUFFER_BIT);    
        
        glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
        glEnableVertexAttribArray(ATTRIB_VERTEX);
        glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
        glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        glBindTexture(CVOpenGLESTextureGetTarget(previousTexture), 0);
    }
    else {
        glClear(GL_COLOR_BUFFER_BIT);
    }
	
    glActiveTexture(GL_TEXTURE0);
	glBindTexture(CVOpenGLESTextureGetTarget(srcTexture), CVOpenGLESTextureGetName(srcTexture));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    const float frontScale[3] = {kFrontScaleFactor, kFrontScaleFactor, 0.0};
    mat4f_LoadScale((float *)frontScale, modelview);
    
    glUniformMatrix4fv(_modelView, 1, GL_FALSE, modelview);
    
    glUniform1i(_frame, 0);
    
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
	glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindTexture(CVOpenGLESTextureGetTarget(srcTexture), 0);

    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);    
	glViewport(0, 0, _width, _height);
    
    glActiveTexture(GL_TEXTURE1);
	glBindTexture(CVOpenGLESTextureGetTarget(destTexture), CVOpenGLESTextureGetName(destTexture));
    
    glUseProgram(_passthruProgram);
    
    glUniform1i(_frame, 1);
    
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);

    // Preserve aspect ratio; fill layer bounds and zoom by a factor 2
    CGSize textureSamplingSize;
    CGSize cropScaleAmount = CGSizeMake(self.bounds.size.width / (float)_offscreenDimensions.width, self.bounds.size.height / (float)_offscreenDimensions.height);
    if ( cropScaleAmount.height > cropScaleAmount.width ) {
        textureSamplingSize.width = self.bounds.size.width / (_offscreenDimensions.width * cropScaleAmount.height);
        textureSamplingSize.height = 1.0;
    }
    else {
        textureSamplingSize.width = 1.0;        
        textureSamplingSize.height = self.bounds.size.height / (_offscreenDimensions.height * cropScaleAmount.width);
    }
    // zoom by a factor 2
    textureSamplingSize.width /= 2.;
    textureSamplingSize.height /= 2.;

    GLfloat passthruTextureVertices[] = {
        (1.0 - textureSamplingSize.width)/2.0, (1.0 + textureSamplingSize.height)/2.0,
        (1.0 + textureSamplingSize.width)/2.0, (1.0 + textureSamplingSize.height)/2.0,
        (1.0 - textureSamplingSize.width)/2.0, (1.0 - textureSamplingSize.height)/2.0,
        (1.0 + textureSamplingSize.width)/2.0, (1.0 - textureSamplingSize.height)/2.0,
    };
    
	glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, passthruTextureVertices);
	glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self present];
    
    glBindTexture(CVOpenGLESTextureGetTarget(destTexture), 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    if (refreshBackFrame || !_backFramePixelBuffer) {
        if (_backFramePixelBuffer) {
            CFRelease(_backFramePixelBuffer);
            _backFramePixelBuffer = NULL;
        }
        _backFramePixelBuffer = (CVImageBufferRef)CFRetain(dstPixelBuffer);
    }

bail:
    if (srcTexture) {
        CFRelease(srcTexture);
    }
    if (previousTexture) {
        CFRelease(previousTexture);
    }
    if (destTexture) {
        CFRelease(destTexture);
    }
    return err;
}

- (void)finishRenderingPixelBuffer
{
   glFinish();
}

@end
