//
//  COGViewControllerTime.h
//  Look Both Ways
//
//  Created by Conor McNinja on 17/12/2012.
//  Copyright (c) 2012 Clarity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@interface COGViewControllerTime : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate>  {
	AVCaptureSession *_captureSession;
	UIImageView *_imageView;
    UIImageView *_imageViewBack;
    UIImage *imageAllSlices;
	CALayer *_customLayer;
	AVCaptureVideoPreviewLayer *_prevLayer;
    NSTimer *aTimer;
    int frameCount;
    
    UIImage *shiftingRight;
    UIImage *inImage;
    UIImage *imagePixelData;
    UIImage *theSliceImage;
    UIImage *allSliceImage;
    
    UIImage *testImage;
    
    CGImageRef imageRefAllSlices;
    CGContextRef contextRefAllSlices;
    
    CGContextRef myNewContext;
    
    
    char *pixelDataPointer;
    
    void *pixelData;
    
    int sliceSize;
}

-(IBAction)buttonClickedExitTime:(UIButton *)sender;

/*!
 @brief	The capture session takes the input from the camera and capture it
 */
@property AVCaptureSession *captureSession;

/*!
 @brief	The UIImageView we use to display the image generated from the imageBuffer
 */
@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, retain) UIImageView *imageViewBack;
/*!
 @brief	The CALayer we use to display the CGImageRef generated from the imageBuffer
 */
@property (nonatomic, retain) CALayer *customLayer;
/*!
 @brief	The CALAyer customized by apple to display the video corresponding to a capture session
 */
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

/*!
 @brief	This method initializes the capture session
 */
- (void)initCapture;

void ManipulateImagePixelData(CGImageRef inImage);

CGContextRef CreateARGBBitmapContext (CGImageRef inImage);


@end
