//
//  COGViewControllerColour.m
//  Look Both Ways
//
//  Created by Conor McNinja on 11/12/2012.
//  Copyright (c) 2012 Clarity. All rights reserved.
//

#import "COGViewControllerColour.h"

@interface COGViewControllerColour ()

@end

@implementation COGViewControllerColour

#define BYTES_PER_PIXEL 4

@synthesize captureSession = _captureSession;
@synthesize customLayer = _customLayer;
@synthesize prevLayer = _prevLayer;
@synthesize sliderLabel;
@synthesize buttonR2G, buttonBNeg, buttonG2B, buttonGNeg, buttonR2B, buttonRNeg;

#pragma mark -
#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		/*We initialize some variables*/
		self.prevLayer = nil;
		self.customLayer = nil;
	}
	return self;
}

- (void)viewDidLoad {
	/*We intialize the capture*/
    aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(timerFired:)
                                            userInfo:nil
                                             repeats:YES];
    frameCount = 0;
	[self initCapture];
}

- (void)initCapture {
	/*We setup the input*/
    //AVCaptureDeviceInput is a concrete sub-class of AVCaptureInput you use to capture data from an AVCaptureDevice object.
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
										  deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]
										  error:nil];
	/*We setupt the output*/
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	/*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
	 If you don't want this behaviour set the property to NO */
	captureOutput.alwaysDiscardsLateVideoFrames = YES;
	/*We specify a minimum duration for each frame (play with this settings to avoid having too many frames waiting
	 in the queue because it can cause memory issues). It is similar to the inverse of the maximum framerate.
	 In this example we set a min frame duration of 1/10 seconds so a maximum framerate of 10fps. We say that
	 we are not able to process more than 10 frames per second.*/
	//captureOutput.minFrameDuration = CMTimeMake(1, 10);
	
	/*We create a serial queue to handle the processing of our frames*/
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	//dispatch_release(queue);
    
	// Set the video output to store frame in BGRA (It is supposed to be faster)
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[captureOutput setVideoSettings:videoSettings];
    
    
	/*And we create a capture session*/
	self.captureSession = [[AVCaptureSession alloc] init];
	/*We add input and output*/
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
    
    /*We use medium quality, ont the iPhone 4 this demo would be laging too much, the conversion in UIImage and CGImage demands too much ressources for a 720p resolution.*/
    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
	/*We add the Custom Layer (We need to change the orientation of the layer so that the video is displayed correctly)*//*
	self.customLayer = [CALayer layer];
	self.customLayer.frame = self.view.bounds;
	self.customLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0f, 0, 0, 1);
	self.customLayer.contentsGravity = kCAGravityResizeAspectFill;
    */
    
    
    int lCurrentWidth = self.view.frame.size.width;
    int lCurrentHeight = self.view.frame.size.height;
    /*We add the view */
	self.imageView = [[UIImageView alloc] init];
	self.imageView.frame = CGRectMake(0, 0, lCurrentWidth, lCurrentHeight);
    [self.view addSubview:self.imageView];
    
    
    //add the customLayer behind the controls 
    [self.view.layer insertSublayer:self.imageView atIndex:0];
	//[self.view.layer addSublayer:self.customLayer];
    
    
    //initiliase the colour sliders to 1
    sliderRedValue = 1;
    sliderGreenValue = 1;
    sliderBlueValue = 1;
    rNeg = true;
    gNeg = true;
    bNeg = true;
    
    red2blue = true;
    red2green =true;
    green2blue = true;
    
	/*We start the capture*/
	[self.captureSession startRunning];
    
    
}


-(IBAction)sliderRedChanged:(id)sender{
    
    UISlider *slider = (UISlider *)sender;
    sliderRedValue = (slider.value);
 //   int progressAsInt =(int)(slider.value + 0.5f);
  //  NSString *newText =[[NSString alloc]initWithFormat:@"%d", progressAsInt];
    
   // sliderLabel.text = newText;
}
-(IBAction)sliderBlueChanged:(id)sender{
    
    UISlider *slider = (UISlider *)sender;
    sliderBlueValue = (slider.value);
   }
-(IBAction)sliderGreenChanged:(id)sender{
    
    UISlider *slider = (UISlider *)sender;
    sliderGreenValue = (slider.value);
}
-(IBAction)buttonClickedR2G:(id)sender{
    
    if (red2green==false) {
        red2green = true;
        UIImage *image = [UIImage imageNamed:@"rg_colour_cross.png"];
        [sender setImage:image forState:UIControlStateNormal];
    }else {
        UIImage *image = [UIImage imageNamed:@"rg_colour_cross_press.png"];
        [sender setImage:image forState:UIControlStateNormal];
        red2green =false;
    }
}
-(IBAction)buttonClickedR2B:(id)sender{
    
    if (red2blue==false) {
        red2blue = true;
        UIImage *image = [UIImage imageNamed:@"rb_colour_cross.png"];
        [sender setImage:image forState:UIControlStateNormal];
    }else {
        UIImage *image = [UIImage imageNamed:@"rb_colour_cross_press.png"];
        [sender setImage:image forState:UIControlStateNormal];
        red2blue =false;
    }
}
-(IBAction)buttonClickedReset:(id)sender{
    
    red2blue = false;
    red2green =false;
    green2blue = false;
    rNeg = false;
    gNeg = false;
    bNeg = false;
    
    UIImage *image1 = [UIImage imageNamed:@"rb_colour_cross.png"];
    [buttonG2B setImage:image1 forState:UIControlStateNormal];
    UIImage *image2 = [UIImage imageNamed:@"rg_colour_cross.png"];
    [buttonR2G setImage:image2 forState:UIControlStateNormal];
    UIImage *image3 = [UIImage imageNamed:@"gb_colour_cross.png"];
    [buttonG2B setImage:image3 forState:UIControlStateNormal];
    UIImage *image4 = [UIImage imageNamed:@"r_neg_button.png"];
    [buttonRNeg setImage:image4 forState:UIControlStateNormal];
    UIImage *image5 = [UIImage imageNamed:@"g_neg_button.png"];
    [buttonGNeg setImage:image5 forState:UIControlStateNormal];
    UIImage *image6 = [UIImage imageNamed:@"b_neg_button.png"];
    [buttonBNeg setImage:image6 forState:UIControlStateNormal];
    
    //Sort out the sliders
  
    
}

-(IBAction)buttonClickedG2B:(id)sender{
    
    if (green2blue==false) {
        green2blue = true;
        UIImage *image = [UIImage imageNamed:@"gb_colour_cross.png"];
        [sender setImage:image forState:UIControlStateNormal];
    }else {
        UIImage *image = [UIImage imageNamed:@"gb_colour_cross_press.png"];
        [sender setImage:image forState:UIControlStateNormal];
        green2blue =false;
    }
}
-(IBAction)buttonClickedRNeg:(id)sender{
    
    if (rNeg  ==false) {
        rNeg = true;
        UIImage *image = [UIImage imageNamed:@"r_neg_button.png"];
         [sender setImage:image forState:UIControlStateNormal];
    }else {
         UIImage *image = [UIImage imageNamed:@"r_neg_button_press.png"];
         [sender setImage:image forState:UIControlStateNormal];
        rNeg =false;
    }
}
-(IBAction)buttonClickedGNeg:(id)sender{
    
    if (gNeg  ==false) {
        gNeg = true;
        UIImage *image = [UIImage imageNamed:@"g_neg_button.png"];
        [sender setImage:image forState:UIControlStateNormal];
    }else {
        UIImage *image = [UIImage imageNamed:@"g_neg_button_press.png"];
        [sender setImage:image forState:UIControlStateNormal];
        gNeg =false;
    }
}
-(IBAction)buttonClickedBNeg:(id)sender{
    
    if (bNeg  ==false) {
        bNeg = true;
        UIImage *image = [UIImage imageNamed:@"b_neg_button.png"];
        [sender setImage:image forState:UIControlStateNormal];
    }else {
        UIImage *image = [UIImage imageNamed:@"b_neg_button_press.png"];
        [sender setImage:image forState:UIControlStateNormal];
        bNeg =false;
    }
}
#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection
{
	/*We create an autorelease pool because as we are not in the main_queue our code is
	 not executed in the main thread. So we have to create an autorelease pool for the thread we are in*/
	
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
	int bufferWidth = CVPixelBufferGetWidth(imageBuffer);
	int bufferHeight = CVPixelBufferGetHeight(imageBuffer);
	unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    
    frameCount++;
    
    
	for( int row = 0; row < bufferHeight; row++ ) {
		for( int column = 0; column < bufferWidth; column++ ) {

            //pixels are in BGRA order
            pixel[0] = pixel[0]*sliderBlueValue;
			pixel[1] = pixel[1]*sliderGreenValue;
            pixel[2] = pixel[2]*sliderRedValue;
			pixel += BYTES_PER_PIXEL;
            
            if (rNeg == false) {
                pixel[2] = 255 - pixel[2];
            }
            if (gNeg == false) {
                pixel[1] = 255 - pixel[0];
            }
            if (bNeg == false) {
                pixel[0] = 255 - pixel[0];
            }
            
            if (red2blue==false){
                int temp = pixel[2];
                pixel[2] = pixel[0];
                pixel[0] = temp;
            }
         
            
            if (red2green==false){
                int temp = pixel[2];
                pixel[2] = pixel[1];
                pixel[1] = temp;
            }
            
            
            if (green2blue==false){
                int temp = pixel[1];
                pixel[1] = pixel[0];
                pixel[0] = temp;
            }
            
            //mind about casting these to chars??
		}
	}
    
    
    
    
    
    /*Create a CGImageRef from the CVImageBufferRef*/
    // (2) and (3)
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    UIImage *image = [UIImage imageWithCGImage:newImage  scale:1.0 orientation:UIImageOrientationRight];
	
    /*We release some components*/
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    
	[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    
    /*We display the result on the custom layer. All the display stuff must be done in the main thread because
	 UIKit is no thread safe, and as we are not in the main thread (remember we didn't use the main_queue)
	 we use performSelectorOnMainThread to call our CALayer and tell it to display the CGImage.*/
    //(2)
	//[self.customLayer performSelectorOnMainThread:@selector(setContents:) withObject: (id) CFBridgingRelease(newImage) waitUntilDone:YES];
	
	/*We display the result on the image view (We need to change the orientation of the image so that the video is displayed correctly).
	 Same thing as for the CALayer we are not in the main thread so ...*/
	//UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    //this has same affect as inverting function
    //UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
	
	/*We relase the CGImageRef*/
	//CGImageRelease(newImage);
	
	//[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
	
	/*We unlock the  image buffer*/
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	//[pool drain];
} 

-(void)timerFired:(NSTimer *) theTimer
{
    NSLog(@"timerFired @ %@", [theTimer fireDate]);
    NSLog(@"frame count = %d", frameCount);
}

//Lock the screen into portrait
- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
// pre-iOS 6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	self.customLayer = nil;
	self.prevLayer = nil;
}

/* look like theres no need to clean up any more
 - (void)dealloc {
	[self.captureSession release];
    [super dealloc];
}*/





- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
