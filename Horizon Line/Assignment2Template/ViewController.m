//
//  ViewController.m
//  Assignment2Template
//
//  Created on 2/1/16.
//  Copyright © 2016 CMPE161. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController
@synthesize AccNewLine;
@synthesize DMNewLine;

#pragma mark - View methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // allocate the lines for accelerometer and device motion
    AccNewLine = [[Line alloc]init];
    DMNewLine = [[Line alloc]init];
    
    
    //Initialize any variables
    _viewSize.x = self.view.frame.size.width;//Width of UIView
    _viewSize.y =self.view.frame.size.height;//Height of UIView
    
    NSLog(@"Width of UIView: %f",_viewSize.x);
    NSLog(@"Height of UIView: %f",_viewSize.y);
    
    
    //Initialize AVCaptureDevice
    [self initCapture];
    
    //Disable autolock
    UIApplication *thisApp = [UIApplication sharedApplication];
    thisApp.idleTimerDisabled = YES;

    //Initialize motion manager and update intervals
    mManager = [[CMMotionManager alloc] init];
    mManager.deviceMotionUpdateInterval = 1.0/10.0;
    mManager.accelerometerUpdateInterval = 1.0/10.0;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Camera
- (void)initCapture {
    
    AVCaptureDevice     *theDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
                                          deviceInputWithDevice:theDevice
                                          error:nil];
    /*We setupt the output*/
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    /*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
     If you don't want this behaviour set the property to NO */
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    //We create a serial queue to handle the processing of our frames
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // Set the video output to store frame in YpCbCr planar so we can access the brightness in contiguios memory
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    // choice is kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or RGBA
    
    NSNumber* value = [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] ;
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    
    //And we create a capture session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //You can change this for different resolutions
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    //We add input and output
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:captureOutput];
    
    //Initialize and add imageview
    self.imageView = [[UIImageView alloc] init];
    
#warning Initialize to size of the screen. You need to select the right values and replace 100 and 100
    //TODO: select right width and height value
    self.imageView.frame = CGRectMake(0, 0, 375, 667);
    
    //Add subviews to master view
    //The order is important in order to view the button
    [self.view addSubview:self.imageView];

#warning Add any UI elements here
    [self.view addSubview:_object2DSelectionSegmentControl];//Adding the segment control
    
    
    //Once startRunning is called the camera will start capturing frames
    [self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    self.width = CVPixelBufferGetWidth(imageBuffer);
    self.height = CVPixelBufferGetHeight(imageBuffer);
    
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, self.width, self.height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    //Context size
    _contextSize.x = self.width;
    _contextSize.y = self.height;
    
    //See the values of the image buffer
//    NSLog(@"Self width: %zu",self.width);
//    NSLog(@"Self height: %zu",self.height);
    
    
#warning Here is where you draw 2D objects
    //----------------------------------------------------------------------------------------
    //TODO: Here is where you draw 2D objects.
    //----------------------------------------------------------------------------------------
    //Draw axes

    
    
    
    //Draw lines
    if (_objectToDraw == ACCELEROMETER) {
            // check to make sure acce. is available
        if (mManager.accelerometerAvailable) {
            // apply the rotation matrix to the accelerometer data from acce. ref. system to camera ref. system. This is done on paper.
            float acceNormX = mManager.accelerometerData.acceleration.x;
            float acceNormY = -(mManager.accelerometerData.acceleration.y);
            float acceNormZ = -(mManager.accelerometerData.acceleration.z);
            NSLog(@"x value is: %f",acceNormX);
            NSLog(@"y value is: %f",acceNormY);
            NSLog(@"z value is: %f",acceNormZ);
            
            
            // set up variable A, B, C as shown in Prof. Manduchi's slides, focal length a bit off so rounded down a bit.
            float A = acceNormX;
            float B = acceNormY;
            float C = -(acceNormX)*(240) - (acceNormY)*(320) + (acceNormZ)*(520);
            
            
            // make the two points to form the horizon line
            float startPointX = 0;
            float startPointY = (-C - A*(0))/B;
            
            float endPointX = 480;
            float endPointY = (-C - A*(480))/B;
            
            // update the startPoint and endPoint values
            _startPointA = CGPointMake(startPointX, startPointY);
            _endPointA = CGPointMake(endPointX, endPointY);
            
            // change the startPoint and endPoint for AccNewLine to the updated points
            [AccNewLine changeToCGPoint:_startPointA ToCGPoint:_endPointA];
            // draw line
            [AccNewLine drawLine:context];

        }
    //Draw lines
    }else if (_objectToDraw == DEVICEMOTION){
        
   
        // make sure accelerometer is available
        if (mManager.accelerometerAvailable) {
            
            
            // apply rot. matrix to devicemotion data.
            float DMNormX = mManager.deviceMotion.gravity.x;
            float DMNormY = -(mManager.deviceMotion.gravity.y);
            float DMNormZ = -(mManager.deviceMotion.gravity.z);
            NSLog(@"x value is: %f",DMNormX);
            NSLog(@"y value is: %f",DMNormY);
            NSLog(@"z value is: %f",DMNormZ);
            
            
            // set up variable A, B, C as shown in Prof. Manduchi's slides, focal length a bit off so rounded down a bit
            float A = DMNormX;
            float B = DMNormY;
            float C = -(DMNormX)*(240) - (DMNormY)*(320) + (DMNormZ)*(520);
            
            
            // set up start and end point
            float startPointX = 0;
            float startPointY = (-C - A*(0))/B;
            
            float endPointX = 480;
            float endPointY = (-C - A*(480))/B;
            
            // update start and end point value
            _startPointD = CGPointMake(startPointX, startPointY);
            _endPointD = CGPointMake(endPointX, endPointY);
            
            // update the start and end point for DMNewLine with latest value
            [DMNewLine changeToCGPoint:_startPointD ToCGPoint:_endPointD];
            // draw line
            [DMNewLine drawLine:context];
        }
    
    }
    //----------------------------------------------------------------------------------------
    //----------------------------------------------------------------------------------------
    
    
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    // UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:(CGFloat)1 orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    //notice we use this selector to call our setter method 'setImg' Since only the main thread can update this
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
}


#pragma mark - Actions
#warning Example of using segmented controls
- (IBAction)object2DSelectionSegmentChanged:(id)sender {
    
    //Line selected
    if (_object2DSelectionSegmentControl.selectedSegmentIndex == ACCELEROMETER) {
        
        //Let the captureOutput() know to draw on accelerometer
        _objectToDraw = ACCELEROMETER;
        
        
    //Circle selected
    }else if (_object2DSelectionSegmentControl.selectedSegmentIndex == DEVICEMOTION) {
        // let captureOutput() know to draw on devicemotion
        _objectToDraw = DEVICEMOTION;
        
        
    }
}

- (IBAction)startUpdate:(id)sender {
    // start accelerometer update
    if (_objectToDraw == ACCELEROMETER) {
        
        [mManager startAccelerometerUpdates];
        
                
    }

    // start device motion
    if (_objectToDraw == DEVICEMOTION) {
        [mManager startDeviceMotionUpdates];
        
    }
}

- (IBAction)stopUpdate:(id)sender {
    // stop accelerometer update
    if (_objectToDraw == ACCELEROMETER) {
        [mManager stopAccelerometerUpdates];
    }
    
    if (_objectToDraw == DEVICEMOTION) {
        
        //stop device mpotion updates
        [mManager stopDeviceMotionUpdates];

    }
}

@end
