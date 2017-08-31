//
//  COGViewControllerMovingStill.h
//  Look Both Ways
//
//  Created by Conor McNinja on 15/02/2013.
//  Copyright (c) 2013 Clarity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@interface COGViewControllerNegative : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    
	AVCaptureSession *captureSession;
	UIImageView *_imageView;
    
    NSTimer *aTimer;
    int frameCount;
 
}
-(IBAction)buttonClickedExitNeg:(UIButton *)sender;

/*!
 @brief	The capture session takes the input from the camera and capture it
 */
@property (nonatomic, retain) AVCaptureSession *captureSession;

/*!
 @brief	The UIImageView we use to display the image generated from the imageBuffer
 */
@property (nonatomic, retain) UIImageView *imageView;

/*!
 @brief	The CALAyer customized by apple to display the video corresponding to a capture session
 */
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

/*!
 @brief	This method initializes the capture session
 */
- (void)initCapture;

- (UIImage *)makeImageNegative;

@end

