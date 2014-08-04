//
//  WPFaceDetectionViewControolerViewController.m
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import "WPFaceDetectionViewControolerViewController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MBProgressHUD.h"
#import "WPInnovaServer.h"
#import "WPRecognizedGuestViewController.h"
#import "NSObject+Block.h"

#define kMaxPictures 3
#pragma mark-

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@interface WPFaceDetectionViewControolerViewController (InternalMethods)
- (void)setupAVCapture;
- (void)teardownAVCapture;
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation;
@end

@implementation WPFaceDetectionViewControolerViewController

#pragma mark - Life cylce
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self teardownAVCapture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    view = [[UIView alloc]init];
    
    backgroundView = [[WPFloatingView alloc]initWithFrame:previewView.bounds];
    backgroundView.opaque = NO;
    backgroundView.backgroundColor = [UIColor clearColor];
    
    //backgroundView.backgroundColor = [UIColor blackColor];
    //backgroundView.alpha = 0.7;
    
    images = [NSMutableArray array];
	square = [UIImage imageNamed:@"squarePNG"];
    
    [self setupAVCapture];
    
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
    faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    titleLabel.text = @"Ready ?";
    //numberLabel.text = @"";
    //numberLabel.frame.size = CGSizeMake(0, 0);
}

- (void)showAnimation
{
    static int number = 1;
    numberLabel.text = [NSString stringWithFormat:@"%d",number];
    
    [UIView animateWithDuration:1.0 animations:^{
        // Scale down 50%
        numberLabel.transform = CGAffineTransformScale(numberLabel.transform, 0.5, 0.5);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.0 animations:^{
            // Scale up 50%
            numberLabel.transform = CGAffineTransformScale(numberLabel.transform, 2, 2);
            //numberLabel.hidden = YES;
        } completion:^(BOOL finished) {
            numberLabel.transform = CGAffineTransformIdentity;
            if (number != 3) {
                number ++;
                [self showAnimation];
            }
            else
            {
                numberLabel.hidden = YES;
                [self faceDetection:YES];
            }
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self showAnimation];
    
    [self performBlock:^{
        
        
        titleLabel.text = @"Set !";
    } afterDelay:1.0 complitionBlock:^{
        
        [self performBlock:^{
            titleLabel.text = @"smile :)";
            //            numberLabel.text = @"2";
            //            numberLabel.hidden = NO;
            //            [UIView animateWithDuration:1.0 animations:^{
            //                // Scale down 50%
            //                numberLabel.transform = CGAffineTransformScale(numberLabel.transform, 0.5, 0.5);
            //            } completion:^(BOOL finished) {
            //                [UIView animateWithDuration:1.0 animations:^{
            //                    // Scale up 50%
            //                    numberLabel.transform = CGAffineTransformScale(numberLabel.transform, 2, 2);
            //                    numberLabel.hidden = YES;
            //                }];
            //            }];
            
        } afterDelay:1.0 complitionBlock:^{
            
            [self performBlock:^{
                //[self faceDetection:YES];
            } afterDelay:3.0];
        }];
    }];
}

- (void)setupAVCapture
{
	NSError *error = nil;
	
	AVCaptureSession *session = [AVCaptureSession new];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
    }
	else
    {
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
	
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	//require( error == nil, bail );
	
    isUsingFrontFacingCamera = NO;
	if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
    
    // Make a still image output
	stillImageOutput = [AVCaptureStillImageOutput new];
	[stillImageOutput addObserver:self forKeyPath:@"capturingStillImage"
                          options:NSKeyValueObservingOptionNew
                          context:(__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)];
	if ( [session canAddOutput:stillImageOutput] )
		[session addOutput:stillImageOutput];
	
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
	
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	effectiveScale = 1.0;
	previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
	CALayer *rootLayer = [previewView layer];
	[rootLayer setMasksToBounds:YES];
	[previewLayer setFrame:[rootLayer bounds]];
	[rootLayer addSublayer:previewLayer];
    [session startRunning];
    
  
    
bail:
	if (error) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
		[self teardownAVCapture];
	}
   
    [self switchCameras:nil];
}

// clean up capture setup
- (void)teardownAVCapture
{
	//[stillImageOutput removeObserver:self forKeyPath:@"isCapturingStillImage"];
	[previewLayer removeFromSuperlayer];
}

// perform a flash bulb animation using KVO to monitor the value of the capturingStillImage property of the AVCaptureStillImageOutput class
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//	if ( context == (__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext) ) {
//		BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		
//		if ( isCapturingStillImage )
//        {
//			// do flash bulb like animation
//			flashView = [[UIView alloc] initWithFrame:[previewView frame]];
//			[flashView setBackgroundColor:[UIColor whiteColor]];
//			[flashView setAlpha:0.f];
//			[[[self view] window] addSubview:flashView];
//			
//			[UIView animateWithDuration:.4f
//							 animations:^{
//								 [flashView setAlpha:1.f];
//							 }
//			 ];
//		}
//		else
//        {
//			[UIView animateWithDuration:.4f
//							 animations:^{
//								 [flashView setAlpha:0.f];
//							 }
//							 completion:^(BOOL finished){
//								 [flashView removeFromSuperview];
//								 flashView = nil;
//							 }
//			 ];
//		}
//	}
}

// utility routing used during image capture to set up capture orientation
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = (int)deviceOrientation;
	
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}
// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil
												  cancelButtonTitle:@"Dismiss"
												  otherButtonTitles:nil];
		[alertView show];
	});
}

// main action method to take a still image -- if face detection has been turned on and a face has been detected
// the square overlay will be composited on top of the captured image and saved to the camera roll
- (IBAction)takePicture:(id)sender
{
    // Find out the current orientation and tell the still image output.
	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
	[stillImageConnection setVideoOrientation:avcaptureOrientation];
	[stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
	
    BOOL doingFaceDetection = detectFaces && (effectiveScale == 1.0);
	
    // set the appropriate pixel format / image type output setting depending on if we'll need an uncompressed image for
    // the possiblity of drawing the red square over top or if we're just writing a jpeg to the camera roll which is the trival case
        if (doingFaceDetection)
        {
            [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        }
        else
        {
            [stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG
																		forKey:AVVideoCodecKey]];
        }
	
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
      completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
          if (error)
          {
              [self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
          }
          else
          {
              if (doingFaceDetection && isReady)
              {
                  [self faceDetection:NO];
                  
                  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
                  CVPixelBufferLockBaseAddress(imageBuffer, 0);
                  void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
                  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
                  size_t width = CVPixelBufferGetWidth(imageBuffer);
                  size_t height = CVPixelBufferGetHeight(imageBuffer);
                  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                  CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
                  CGImageRef quartzImage = CGBitmapContextCreateImage(context);
                  
                  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
                  CGContextRelease(context);
                  CGColorSpaceRelease(colorSpace);
                  NSLog(@"%@",quartzImage);
                  
                  UIImage* uiImage = [[UIImage alloc] initWithCGImage:quartzImage];
                  //NSString * base64 = [self imageBase64String:uiImage];
                  
                 
                  
//                  CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
//                  CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
//                  CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
//                                                                    options:(__bridge NSDictionary *)attachments];
//                
//                
//                  CIVector *cropRect =[CIVector vectorWithX:backgroundView.transparentRectangleRect.origin.x + 100
//                                                          Y:backgroundView.transparentRectangleRect.origin.y
//                                                          Z:backgroundView.transparentRectangleRect.size.width * 3
//                                                          W:backgroundView.transparentRectangleRect.size.height * 3];
//                  
//                  CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
//                  
//                  [cropFilter setValue:ciImage forKey:@"inputImage"];
//                  [cropFilter setValue:cropRect forKey:@"inputRectangle"];
//                  
//                  CIImage *croppedImage = [cropFilter valueForKey:@"outputImage"];
//                  
//                  UIImage *uiImage = [[UIImage alloc] initWithCIImage:croppedImage];
                  CGSize imgSize = uiImage.size;
                  
                  
                  [images addObject:uiImage];
                  
                  UIImageView *imageView = imageViews[images.count - 1];
                  
                  //UIImageView *imageView = imageViews[0];
                  
                  imageView.contentMode = UIViewContentModeScaleAspectFit;
                  imageView.image = [self scaleToSize:CGSizeMake(imgSize.width / 3, imgSize.height / 3) image:uiImage];
                  imageView.frame = CGRectMake(imageView.frame.origin.x,
                                               imageView.frame.origin.y,
                                               imgSize.width / 3,
                                               imgSize.height / 3);
                  
                  imageView.transform = CGAffineTransformMakeRotation(1.58);
                  
                  if (images.count >= kMaxPictures )
                  {
                      [self performBlock:^{
                          //[self faceDetection:YES];
                          [self checkIfTheGuestIsRecognized];
                      } afterDelay:0.0];
                      
                  }
                  else
                  {
                      [self performBlock:^{
                          [self faceDetection:YES];
                      } afterDelay:2.0];
                  }
              }
          }
      }
	 ];
}

-(UIImage*)scaleToSize:(CGSize)size image:(UIImage *)image
{
    // Create a bitmap graphics context
    // This will also set it as the current context
    UIGraphicsBeginImageContext(size);
    
    // Draw the scaled image in the current context
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    
    // Return our new scaled image
    return scaledImage;
}

- (NSString *)imageBase64String:(UIImage *)image
{
//    return        [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSData * data = [UIImagePNGRepresentation(image) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:[data bytes]];
    
}

// turn on/off face detection
- (IBAction)toggleFaceDetection:(id)sender
{
	//detectFaces = [(UISwitch *)sender isOn];
    
	[self faceDetection:[(UISwitch *)sender isOn]];
}

- (void)faceDetection:(BOOL)detectFace
{
    detectFaces = detectFace;
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:detectFaces];
    
	if (!detectFaces)
    {
		dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           // clear out any squares currently displaying.
                           [self drawFaceBoxesForFeatures:[NSArray array] forVideoBox:CGRectZero orientation:UIDeviceOrientationPortrait];
                       });
	}
    if (detectFace == YES) {
        [self performBlock:^{
            isReady = YES;
        } afterDelay:2.0];
    }
    else
    {
        isReady = NO;
    }
}

// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
	NSLog(@"drawFaceBoxesForFeatures");
    NSArray *sublayers = [NSArray arrayWithArray:[previewLayer sublayers]];
	NSInteger sublayersCount = [sublayers count], currentSublayer = 0;
	NSInteger featuresCount = [features count], currentFeature = 0;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for ( CALayer *layer in sublayers ) {
		if ( [[layer name] isEqualToString:@"FaceLayer"] )
			[layer setHidden:YES];
	}
	
	if ( featuresCount == 0 || !detectFaces ) {
		[CATransaction commit];
		return; // early bail.
	}
    
	CGSize parentFrameSize = [previewView frame].size;
	NSString *gravity = [previewLayer videoGravity];
	BOOL isMirrored = previewLayer.connection.isVideoMirrored;
    
	CGRect previewBox = [WPFaceDetectionViewControolerViewController videoPreviewBoxForGravity:gravity
                                                                                     frameSize:parentFrameSize
                                                                                  apertureSize:clap.size];
	for ( CIFaceFeature *ff in features ) {
		
        [self takePicture:nil];
        // find the correct position for the square layer within the previewLayer
		// the feature box originates in the bottom left of the video frame.
		// (Bottom right if mirroring is turned on)
		CGRect faceRect = [ff bounds];
        
		// flip preview width and height
		CGFloat temp = faceRect.size.width;
		faceRect.size.width = faceRect.size.height;
		faceRect.size.height = temp;
		temp = faceRect.origin.x;
		faceRect.origin.x = faceRect.origin.y;
		faceRect.origin.y = temp;
		// scale coordinates so they fit in the preview box, which may be scaled
		CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
		CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
		faceRect.size.width *= widthScaleBy;
		faceRect.size.height *= heightScaleBy;
		faceRect.origin.x *= widthScaleBy;
		faceRect.origin.y *= heightScaleBy;
        
		if ( isMirrored )
			faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
		else
			faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
		
		CALayer *featureLayer = nil;
		
		// re-use an existing layer if possible
		while ( !featureLayer && (currentSublayer < sublayersCount) ) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ( [[currentLayer name] isEqualToString:@"FaceLayer"] ) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}
		
		// create a new one if necessary
		if ( !featureLayer ) {
			featureLayer = [CALayer new];
			[featureLayer setContents:(id)[square CGImage]];
			[featureLayer setName:@"FaceLayer"];
			[previewLayer addSublayer:featureLayer];
		}
		[featureLayer setFrame:faceRect];
		[self addViewWithFaceRect:faceRect];

        
		switch (orientation) {
			case UIDeviceOrientationPortrait:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(0.))];
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(180.))];
				break;
			case UIDeviceOrientationLandscapeLeft:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
				break;
			case UIDeviceOrientationLandscapeRight:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-90.))];
				break;
			case UIDeviceOrientationFaceUp:
			case UIDeviceOrientationFaceDown:
			default:
				break; // leave the layer in its last known orientation
		}
		currentFeature++;
	}
	
	[CATransaction commit];
}

- (void)addViewWithFaceRect:(CGRect)faceRect
{
    //
    
    //view.frame = faceRect;
    //view.backgroundColor = [UIColor whiteColor];
    /////view.alpha = 0.0;
    //[view removeFromSuperview];
    //[previewView addSubview:view];
    if (![self.view.subviews containsObject:backgroundView])
    {
        [previewView addSubview:backgroundView];
    }
    backgroundView.transparentRectangleRect = faceRect;
    [backgroundView setNeedsDisplay];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	NSLog(@"captureOutput");
    // got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	int exifOrientation;
	
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
	NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
	
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
	});
}

- (void)dealloc
{
    //[imageViews release];
	[self teardownAVCapture];
}

// use front/back camera
- (IBAction)switchCameras:(id)sender
{
	AVCaptureDevicePosition desiredPosition;
	if (isUsingFrontFacingCamera)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
				[[previewLayer session] removeInput:oldInput];
			}
			[[previewLayer session] addInput:input];
			[[previewLayer session] commitConfiguration];
			break;
		}
	}
	isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		beginGestureScale = effectiveScale;
	}
	return YES;
}

// scale image depending on users pinch gesture
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
	BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [recognizer numberOfTouches], i;
	for ( i = 0; i < numTouches; ++i ) {
		CGPoint location = [recognizer locationOfTouch:i inView:previewView];
		CGPoint convertedLocation = [previewLayer convertPoint:location fromLayer:previewLayer.superlayer];
		if ( ! [previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer ) {
		effectiveScale = beginGestureScale * recognizer.scale;
		if (effectiveScale < 1.0)
			effectiveScale = 1.0;
		CGFloat maxScaleAndCropFactor = [[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
		if (effectiveScale > maxScaleAndCropFactor)
			effectiveScale = maxScaleAndCropFactor;
		[CATransaction begin];
		[CATransaction setAnimationDuration:.025];
		[previewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
		[CATransaction commit];
	}
}

- (void)checkIfTheGuestIsRecognized
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WPInnovaServer *server = [[WPInnovaServer alloc]init];
    
    NSMutableArray* imageArray =[NSMutableArray arrayWithCapacity:3];

    for (UIImage * image in images) {
        NSString *imageBase64 = [self imageBase64String:image];
        [imageArray addObject:imageBase64];
    }
    
    [server searchGuestByPicture:imageArray resualtBloack:^(BOOL find, NSDictionary *jsonData) {
        
        if (find) {
            guestInfo = jsonData;
            [self performSegueWithIdentifier:@"RecognizedGuestSegue" sender:self];
        }
        else
        {
            [self performSegueWithIdentifier:@"UnrecognizedGuestSegue" sender:self];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

#pragma mark - IBaction
- (IBAction)Unrecognized:(UIButton *)sender {

    [self performSegueWithIdentifier:@"UnrecognizedGuestSegue" sender:self];
}

- (IBAction)Recognized:(UIButton *)sender {

    [self performSegueWithIdentifier:@"RecognizedGuestSegue" sender:self];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RecognizedGuestSegue"]) {
        
        WPRecognizedGuestViewController *recognizedGuestVC = segue.destinationViewController;
        recognizedGuestVC.model = guestInfo;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

@end