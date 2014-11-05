//
//  WPFaceDetectionViewControolerViewController.h
//  WelcomeProject
//
//  Created by Guy Kahlon on 4/27/14.
//  Copyright (c) 2014 GuyKahlon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WPFloatingView.h"
@class CIDetector;

@interface WPFaceDetectionViewControolerViewController : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
	IBOutlet UIView *previewView;
	IBOutlet UISegmentedControl *camerasControl;
	AVCaptureVideoPreviewLayer *previewLayer;
	AVCaptureVideoDataOutput *videoDataOutput;
	BOOL detectFaces;
	dispatch_queue_t videoDataOutputQueue;
	AVCaptureStillImageOutput *stillImageOutput;
	UIView *flashView;
	UIImage *square;
	BOOL isUsingFrontFacingCamera;
	CIDetector *faceDetector;
	CGFloat beginGestureScale;
	CGFloat effectiveScale;
    NSMutableArray *images;
    IBOutletCollection(UIImageView) NSArray *imageViews;
    BOOL finish;
    NSDictionary *guestInfo;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *numberLabel;
    WPFloatingView *backgroundView;
    BOOL isReady;
}

- (IBAction)takePicture;
- (IBAction)switchCameras:(id)sender;
- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender;
- (IBAction)toggleFaceDetection:(id)sender;
@property (nonatomic)BOOL automaticTakePictureOnFaceDetection;

@end