//
//  COGViewControllerColour.m
//  Look Both Ways
//
//  Created by Conor McNinja on 11/12/2012.
//  Copyright (c) 2012 Clarity. All rights reserved.
//

#import "COGViewControllerTime.h"

@interface COGViewControllerTime ()

@end

@implementation COGViewControllerTime

#define BYTES_PER_PIXEL 4

@synthesize captureSession = _captureSession;
@synthesize customLayer = _customLayer;
@synthesize prevLayer = _prevLayer;



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
    
    /*We use medium quality, on the iPhone 4 this demo would be laging too much, the conversion in UIImage and CGImage demands too much ressources for a 720p resolution.*/
    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
	    
    int lCurrentWidth = self.view.frame.size.width;
    int lCurrentHeight = self.view.frame.size.height;
    NSLog(@"ImageView height = %zd", lCurrentHeight);
    NSLog(@"ImageView width = %zd", lCurrentWidth);

    // (3)
	/*We add the imageView*/
	self.imageView = [[UIImageView alloc] init];
	self.imageView.frame = CGRectMake(0, lCurrentHeight/2, lCurrentWidth, lCurrentHeight/2);
    
    self.imageViewBack = [[UIImageView alloc] init];
	self.imageViewBack.frame = CGRectMake(0, 0, lCurrentWidth, lCurrentHeight);
  
    //self.imageView.transform = CGAffineTransformMakeScale(-1, 1);
    [self.view addSubview:self.imageViewBack];
    [self.view addSubview:self.imageView];
    
    	/*We start the capture*/
	[self.captureSession startRunning];
    sliceSize = 2;

    
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
 
    /*Create a CGImageRef from the CVImageBufferRef*/
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextBG = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    //ImageRef for full image
    CGImageRef imageRefBG = CGBitmapContextCreateImage(contextBG);
    //Ref for slice
    CGImageRef imageRef1Slice = CGImageCreateWithImageInRect(imageRefBG , CGRectMake(width/2, 0, sliceSize, height));
       
    //Quartz guide method
    CGRect myBoundingBox;// 1
    myBoundingBox = CGRectMake (0, 0, width, height);// 2
    
    myNewContext = MyCreateBitmapContext (height, width);// 3
    
    //draw into context here
    //make bg black
    CGContextSetRGBFillColor (myNewContext, 0, 0, 0, 1);
    CGContextFillRect (myNewContext, CGRectMake (0, 0, height, width ));
    
    //draw in 1 clice                                  
    CGContextDrawImage(myNewContext, CGRectMake(0, 0, sliceSize, width), imageRef1Slice);
    //draw in all previous slices fro last frame
    CGContextDrawImage(myNewContext, CGRectMake(sliceSize, 0, height, width), allSliceImage.CGImage);
 
    struct CGImage *myImage = CGBitmapContextCreateImage (myNewContext);// 5
    
    char *bitmapData = CGBitmapContextGetData(myNewContext); // 7
    //ImageRef for new image
    CGImageRef imageRefNew = CGBitmapContextCreateImage(myNewContext);

    allSliceImage = [UIImage imageWithCGImage:imageRefNew scale:1.0 orientation:UIImageOrientationRight];
    
    CGContextRelease (myNewContext);// 8
    
    if (bitmapData) free(bitmapData);
    
    CGImageRelease(myImage);
    
    UIImage *imageBack= [UIImage imageWithCGImage:imageRefBG  scale:1.0 orientation:UIImageOrientationRight];
    
    /*We release some components*/
    CGContextRelease(contextBG);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRelease(imageRefBG);
    CGImageRelease(imageRefNew);
    CGImageRelease(imageRef1Slice);
    CGImageRelease(imageRefAllSlices);
    
    //add this shit to the views
  	[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:allSliceImage waitUntilDone:YES];
	[self.imageViewBack performSelectorOnMainThread:@selector(setImage:) withObject:imageBack waitUntilDone:YES];
    
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
	self.customLayer = nil;
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


//this method is curtosy of the quartz 2d guide from apple
CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh)
{    
    CGContextRef    context = NULL;
    
    CGColorSpaceRef colorSpace;
    
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide * 4);// 1
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);

    colorSpace = CGColorSpaceCreateDeviceRGB();// 2
    bitmapData = malloc( bitmapByteCount );// 3
    
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,// 4
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    
    if (context== NULL)
    {
        free (bitmapData);// 5
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );// 6

    return context;// 7
    
}

@end
