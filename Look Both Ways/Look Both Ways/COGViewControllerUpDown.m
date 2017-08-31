//
//  COGViewControllerMovingStill.m
//  Look Both Ways
//
//  Created by Conor McNinja on 15/02/2013.
//  Copyright (c) 2013 Clarity. All rights reserved.
//

#import "COGViewControllerUpDown.h"

@interface COGViewControllerUpDown ()

@end

@implementation COGViewControllerUpDown

#define BYTES_PER_PIXEL 4

@synthesize captureSession = _captureSession;

#pragma mark -
#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		/*We initialize some variables*/
		//self.prevLayer = nil;
		//self.customLayer = nil;
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
    
    
	/*Create a capture session*/
	self.captureSession = [[AVCaptureSession alloc] init];
	/*We add input and output*/
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
    
    int lCurrentWidth = self.view.frame.size.width;
    int lCurrentHeight = self.view.frame.size.height;
    NSLog(@"ImageView height = %zd", lCurrentHeight);
    NSLog(@"ImageView width = %zd", lCurrentWidth);
    
	/*We add the view */
	self.imageView = [[UIImageView alloc] init];
	self.imageView.frame = CGRectMake(0, 0, lCurrentWidth, lCurrentHeight);
    [self.view addSubview:self.imageView];
    
    /*We start the capture*/
	[self.captureSession startRunning];
}


#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection
{
    //background image stuff
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    /* NSLog(@"buffer width = %zd", width);
     NSLog(@"buffer height = %zd", height);
     NSLog(@"buffer bytesPerRow = %zd", bytesPerRow);
     */
    /*
    int bufferWidth = CVPixelBufferGetWidth(imageBuffer);
	int bufferHeight = CVPixelBufferGetHeight(imageBuffer);
	unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    for( int row = 0; row < bufferHeight; row++ ) {
		for( int column = 0; column < bufferWidth; column++ ) {
            pixel[0] = 255 - pixel[0];
			pixel[1] = 255 - pixel[1]; // De-green (second pixel in BGRA is green)
            pixel[2] = 255 - pixel[2];
			pixel += BYTES_PER_PIXEL;
		}
	}
    */
    
    /*Create a CGImageRef from the CVImageBufferRef*/
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextBG = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little       | kCGImageAlphaPremultipliedFirst);
    
    
    //ImageRef for full image
    CGImageRef imageRefBG = CGBitmapContextCreateImage(contextBG);
    
    
	UIImage *image = [UIImage imageWithCGImage:imageRefBG  scale:1.0 orientation:UIImageOrientationRight];
    
    
    /*We release some components*/
    CGContextRelease(contextBG);
    CGColorSpaceRelease(colorSpace);
    
	/*We relase the CGImageRef*/
    CGImageRelease(imageRefBG );
    
	[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    
	frameCount++;
    /*We unlock the  image buffer*/
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
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
	
	self.prevLayer = nil;
}

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

