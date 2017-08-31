//
//  COGViewControllerColour.h
//  Look Both Ways
//
//  Created by Conor McNinja on 11/12/2012.
//  Copyright (c) 2012 Clarity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>


@interface COGViewControllerColour : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UIImagePickerControllerDelegate>{
    
    float sliderGreenValue, sliderBlueValue, sliderRedValue;
    bool red2green, red2blue, green2blue, rNeg, gNeg, bNeg;
    int frameCount;
    NSTimer *aTimer;
    
    UILabel *sliderLabel;
    
    AVCaptureSession *_captureSession;
	UIImageView *_imageView;
    
	CALayer *_customLayer;
	AVCaptureVideoPreviewLayer *_prevLayer;
}

@property (nonatomic, retain)IBOutlet UILabel *sliderLabel;

-(IBAction)sliderGreenChanged:(id)sender;
-(IBAction)sliderBlueChanged:(id)sender;
-(IBAction)sliderRedChanged:(id)sender;

@property (nonatomic, strong) IBOutlet UIButton *buttonR2G;    //in IB drag this to your button
@property (nonatomic, strong) IBOutlet UIButton *buttonR2B;
@property (nonatomic, strong) IBOutlet UIButton *buttonG2B;
@property (nonatomic, strong) IBOutlet UIButton *buttonRNeg;
@property (nonatomic, strong) IBOutlet UIButton *buttonGNeg;
@property (nonatomic, strong) IBOutlet UIButton *buttonBNeg;

-(IBAction)buttonClickedR2G:(UIButton *)sender;    //in IB drag you button to this action
-(IBAction)buttonClickedR2B:(UIButton *)sender;
-(IBAction)buttonClickedG2B:(UIButton *)sender;
-(IBAction)buttonClickedRNeg:(UIButton *)sender;
-(IBAction)buttonClickedGNeg:(UIButton *)sender;
-(IBAction)buttonClickedBNeg:(UIButton *)sender;
-(IBAction)buttonClickedReset:(UIButton *)sender;

/*!
 @brief	The capture session takes the input from the camera and capture it
 */
@property (nonatomic, retain) AVCaptureSession *captureSession;
/*!
 @brief	The CALayer we use to display the CGImageRef generated from the imageBuffer
 */
@property (nonatomic, retain) CALayer *customLayer;
/*!
 @brief	The CALAyer customized by apple to display the video corresponding to a capture session
 */
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;

/*!
 @brief	The UIImageView we use to display the image generated from the imageBuffer
 */
@property (nonatomic, retain) UIImageView *imageView;

/*!
 @brief	This method initializes the capture session
 */
- (void)initCapture;


@end

