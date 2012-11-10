
### 'StacheCam ###

===========================================================================
DESCRIPTION:

'StacheCam demonstrates the introduction of AVCaptureMetadataOutput in iOS 6, providing instances of AVMetadataObject.  The sample highlights:
 - Discovering and requesting available metadata (AVMetadataFaceObject)
 - Receiving metadata via AVCaptureMetadataOutputObjectsDelegate
 - Converting metadata coordinates to match image outputs such as 
   AVCaptureVideoPreviewLayer or AVCaptureStillImageOutput
 - Displaying overlay graphics where faces are detected
 - Pausing the preview layer when a still image is taken

'StacheCam also demonstrates features introduced in iOS 5:
 - Detecting still image capture by KVO of the "capturingStillImage" property
 - Use of setVideoScaleAndCropFactor: to achieve a "digital zoom" effect
 - Switching between front and back cameras while showing a real-time preview
 - Integrating with CoreImage's CIFaceDetector to find faces in a pixel buffer

===========================================================================
RUNTIME REQUIREMENTS:

iOS 6.0 or later. This app will not deliver any camera output on the iOS simulator.

===========================================================================
APIs USED:

ALAssetsLibrary - to write to the photos library
AVFoundation
	AVCaptureMetadataOutput
	AVCaptureConnection
	AVCaptureDevice
	AVCaptureDeviceInput
	AVCaptureSession
	AVCaptureStillImageOutput
	AVCaptureVideoDataOutput
	AVCaptureVideoPreviewLayer
	AVMetadataObject
CoreImage
	CIFaceDetector

===========================================================================
Copyright (C) 2012 Apple Inc. All rights reserved.
