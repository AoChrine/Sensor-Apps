//
//  ViewController.m
//  Asg4Gyro
//
//  Created by Alexander Ou on 3/7/16.
//  Copyright © 2016 ChrineApps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _circlePoint = CGPointMake(0.0, 0.0);
    
    _changeInTime = 0.0;
    
    _previousGyroFullRotationMatrix = GLKMatrix3Make(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);

    _previousGyroSARotaionMatrix = GLKMatrix3Make(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);
    
    NSLog(@"prev gyro rot matrix = %f", _previousGyroFullRotationMatrix.m00);
    
    _referenceAttitude = nil;
    
    gyroFirstTime = true;
    
    deviceMotionQueue = [NSOperationQueue currentQueue];
    gyroQueue = [NSOperationQueue currentQueue];
    

    //Initialize any variables
    _viewSize.x = self.view.frame.size.width;//Width of UIView
    _viewSize.y =self.view.frame.size.height;//Height of UIView
    
    NSLog(@"Width of UIView: %f",_viewSize.x);
    NSLog(@"Height of UIView: %f",_viewSize.y);
    

    
    //Initialize arrays
    _dmListOfCircles = [[NSMutableArray alloc]init];
    _fullListOfCircles = [[NSMutableArray alloc]init];
    _saListOfCircles = [[NSMutableArray alloc]init];
    
    //Initialize AVCaptureDevice
    [self initCapture];
    
    //this allows the user to have multiple fingers touching the screen.
    self.view.multipleTouchEnabled = YES;
    
    //Disable autolock
    UIApplication *thisApp = [UIApplication sharedApplication];
    thisApp.idleTimerDisabled = YES;
    
    //Initialize motion manager and update intervals
    mManager = [[CMMotionManager alloc] init];
    mManager.accelerometerUpdateInterval = 1.0/10.0;
    mManager.deviceMotionUpdateInterval = 1.0/10.0;
    mManager.gyroUpdateInterval = 1.0/10.0;

    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


-(void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event{
    
    // our ps,0 point, apply the mapping constant, and allign to gyro
    _circlePoint = [[touches anyObject]locationInView:self.view];

    // update dmcircle vec
     if (_objectToDraw == DEVICEMOTION) {
        _dmCircleVec.x = _circlePoint.x*(_contextSize.y/_viewSize.x);
     
        _dmCircleVec.y = (_contextSize.x)-(_circlePoint.y*(_contextSize.x/_viewSize.y));
   
        _dmCircleVec.z = 520;
         
         // change to camera
         _dmCirVec.x = _dmCircleVec.x - 240.0;
         _dmCirVec.y = _dmCircleVec.y - 320.0;
         _dmCirVec.z = _dmCircleVec.z;
    }
    
    // update fullcircle vec
    if (_objectToDraw == GYROR) {
        _fullCircleVec.x = _circlePoint.x*(_contextSize.y/_viewSize.x);
        _fullCircleVec.y = (_contextSize.x)-(_circlePoint.y*(_contextSize.x/_viewSize.y));
        _fullCircleVec.z = 520;
   
        
        // change to camera
        _fullCirVec.x = _fullCircleVec.x - 240.0;
        _fullCirVec.y = _fullCircleVec.y - 320.0;
        _fullCirVec.z = _fullCircleVec.z;
    }
    
    // update small angle circle vec
    if (_objectToDraw == GYROSA) {
        _saCircleVec.x = _circlePoint.x*(_contextSize.y/_viewSize.x);
        _saCircleVec.y = (_contextSize.x)-(_circlePoint.y*(_contextSize.x/_viewSize.y));
        _saCircleVec.z = 520;
 

        // change to camera
        _saCirVec.x = _saCircleVec.x - 240.0;
        _saCirVec.y = _saCircleVec.y - 320.0;
        _saCirVec.z = _saCircleVec.z;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//pragma mark - Shake Functions


-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    [self becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewDidDisappear:NO];
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
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
    
    //warning Initialize to size of the screen. You need to select the right values and replace 100 and 100
    //TODO: select right width and height value
    // we had 375.0, 667.0;
    // where the shapes are drawn . . . this is it. this controls it
    self.imageView.frame = CGRectMake(0, 0,375.0,667.0);
    
    //Add subviews to master view
    //The order is important in order to view the button
    [self.view addSubview:self.imageView];
    
    //warning Add any UI elements here
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
    
    
//----------------------------------------------------------------------------------------
//TODO: Here is where you draw 2D objects.
//----------------------------------------------------------------------------------------
//Draw axes
    
   
    if (_circlePoint.x != 0.0 && _circlePoint.y != 0.0) {
    
    // device motion and trace on
        [mManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical toQueue:deviceMotionQueue withHandler:^(CMDeviceMotion *motion, NSError *error){
            
            if (_objectToDraw == DEVICEMOTION && _modeSwitch.on) {
  
                    if(_referenceAttitude == nil) {
                        _referenceAttitude = motion.attitude;
                    }
                    // get current attitude
                    CMAttitude *currentAttitude = motion.attitude;
                
                    //NSLog(@"dm attitude data = %@", currentAttitude);
                
            
                    //find the rotation matrix
                    
                    CMRotationMatrix dmRotationMatrix;
                    
                    
                    // get the change in attitude
                    [currentAttitude multiplyByInverseOfAttitude:_referenceAttitude];
                    
                    // set dmrotationmatrix
                    dmRotationMatrix = currentAttitude.rotationMatrix;
                    
                    // fill in rotation matrix using glkmatrix3
                    GLKMatrix3 dmFRotationMatrix = GLKMatrix3Make(dmRotationMatrix.m11, dmRotationMatrix.m12, dmRotationMatrix.m13, dmRotationMatrix.m21, dmRotationMatrix.m22, dmRotationMatrix.m23, dmRotationMatrix.m31, dmRotationMatrix.m32, dmRotationMatrix.m33);
                    NSLog(@"rot m11 = %f rot m12= %f", dmRotationMatrix.m11, dmRotationMatrix.m12);
                    
                    // apply the rotation to the point
                    _dmRotatedVec = GLKMatrix3MultiplyVector3(dmFRotationMatrix, _dmCirVec);
                    
                    
                    // gyro to camera
                    _dmRotatedVec.y = _dmRotatedVec.y * -1;
                
            
                
                    // change from camera to pixel ref.
                    _dmFPixelVec.x = 520*(_dmRotatedVec.x/_dmRotatedVec.z) + 240.0;
                    _dmFPixelVec.y = 520*(_dmRotatedVec.y/_dmRotatedVec.z) + 320.0;

                    
                    // make new circle
                    _circleCenter = CGPointMake(_dmFPixelVec.x, _dmFPixelVec.y);
                    
                    // add new circle to array to be drawn
                    Circle *newCircle = [[Circle alloc]initWithCGPoint:_circleCenter];
                    [_dmListOfCircles addObject:newCircle];
                }
                
           
            if (_objectToDraw == DEVICEMOTION && !(_modeSwitch.on)) {
                

                    if(_referenceAttitude == nil) {
                        _referenceAttitude = motion.attitude;
                    }
                    // get current attitude
                    CMAttitude *currentAttitude = motion.attitude;
      
                
                    
                    //find the rotation matrix
                    
                    CMRotationMatrix dmRotationMatrix;
                    
                    
                    // get the change in attitude
                    [currentAttitude multiplyByInverseOfAttitude:_referenceAttitude];
                    
                    // set dmrotationmatrix
                    dmRotationMatrix = currentAttitude.rotationMatrix;
                    
                    // fill in rotation matrix using glkmatrix3
                    GLKMatrix3 dmFRotationMatrix = GLKMatrix3Make(dmRotationMatrix.m11, dmRotationMatrix.m12, dmRotationMatrix.m13, dmRotationMatrix.m21, dmRotationMatrix.m22, dmRotationMatrix.m23, dmRotationMatrix.m31, dmRotationMatrix.m32, dmRotationMatrix.m33);
                    NSLog(@"rot m11 = %f rot m12= %f", dmRotationMatrix.m11, dmRotationMatrix.m12);
                    
                // apply the rotation to the point
                _dmRotatedVec = GLKMatrix3MultiplyVector3(dmFRotationMatrix, _dmCirVec);
                
                
                // gyro to camera
                _dmRotatedVec.y = _dmRotatedVec.y * -1;
  

                
                
                // change from camera to pixel ref.
                _dmFPixelVec.x = 520*(_dmRotatedVec.x/_dmRotatedVec.z) + 240.0;
                _dmFPixelVec.y = 520*(_dmRotatedVec.y/_dmRotatedVec.z) + 320.0;
                
                NSLog(@"rotatedvec.x = %f, rotatedvec.y = %f", _dmFPixelVec.x, _dmFPixelVec.y);
                
                // make new circle
                _circleCenter = CGPointMake(_dmFPixelVec.x, _dmFPixelVec.y);
                
                // add new circle to array to be drawn
                Circle *newCircle = [[Circle alloc]initWithCGPoint:_circleCenter];
                [_dmListOfCircles removeAllObjects];
                [_dmListOfCircles addObject:newCircle];
                }
            //}
        }];
    

        [mManager startGyroUpdatesToQueue:gyroQueue withHandler:^(CMGyroData *gyroData, NSError *error){
            // time since phone booted
            _currentTime = gyroData.timestamp;
            
            
            //save the reference attitude and time
            if(gyroFirstTime) {
                _timestampReference = _currentTime;
                gyroFirstTime = false;
            }else{
                // get current time since time 0
                _currentTime = _currentTime - _timestampReference;
                    
                _changeInTime = _currentTime - _previousTime;
                
                _previousTime = _currentTime;
                
     
                
            }
            
            GLKVector3 Omega;
            Omega.x = gyroData.rotationRate.x * _changeInTime;
            Omega.y = gyroData.rotationRate.y * _changeInTime;
            Omega.z = gyroData.rotationRate.z * _changeInTime;
         
        
                // gyror and trace on
                if (_objectToDraw == GYROR && _modeSwitch.on) {
                    //if (_fullCircleVec.x != -30.0 && _fullCircleVec.y != -30.0) {
                    NSLog(@"previousvec = %f, %f, %f", _previousGyroFullRotationMatrix.m11, _previousGyroFullRotationMatrix.m01, _previousGyroFullRotationMatrix.m02);
                        // find big omega
                    
                    NSLog(@"omega.x = %f, omega.y = %f, omega.z = %f", Omega.x, Omega.y, Omega.z);
                        // find rotation matrix using omega
                        // find the cross matrix for omega
                        GLKMatrix3 preRodCrossMatrix = GLKMatrix3Make(0.0, -Omega.z, Omega.y,
                                                                   Omega.z, 0.0, -Omega.x,
                                                                   -Omega.y, Omega.x, 0.0);
                        
                        // find cross matrix squared
                        GLKMatrix3 preRodCrossMatrix2 = GLKMatrix3Multiply(preRodCrossMatrix, preRodCrossMatrix);
                        
                        // find magnitude of omega
                        float OmegaMagnitude = sqrtf((Omega.x * Omega.x) + (Omega.y * Omega.y) + (Omega.z * Omega.z));
                        
                        // find the sin and cos component of the formula
                        float sinComponent = sinf(OmegaMagnitude) / OmegaMagnitude;
                        float cosComponent = (1-cosf(OmegaMagnitude)) / (OmegaMagnitude * OmegaMagnitude);
                        
                        
                        // cross matrix multiplied by scalar
                        GLKMatrix3 postRodCrossMatrix = GLKMatrix3Make(preRodCrossMatrix.m00*sinComponent, preRodCrossMatrix.m01*sinComponent, preRodCrossMatrix.m02*sinComponent, preRodCrossMatrix.m10*sinComponent, preRodCrossMatrix.m11*sinComponent, preRodCrossMatrix.m12*sinComponent, preRodCrossMatrix.m20*sinComponent, preRodCrossMatrix.m21*sinComponent, preRodCrossMatrix.m22*sinComponent);
                        
                        GLKMatrix3 postRodCrossMatrix2 = GLKMatrix3Make(preRodCrossMatrix2.m00*cosComponent, preRodCrossMatrix2.m01*cosComponent, preRodCrossMatrix2.m02*cosComponent, preRodCrossMatrix2.m10*cosComponent, preRodCrossMatrix2.m11*cosComponent, preRodCrossMatrix2.m12*cosComponent, preRodCrossMatrix2.m20*cosComponent, preRodCrossMatrix2.m21*cosComponent, preRodCrossMatrix2.m22*cosComponent);
                        
                        
                        // complete rotation matrix
                        GLKMatrix3 rodRotationMatrix = GLKMatrix3Subtract(GLKMatrix3Identity, GLKMatrix3Add(postRodCrossMatrix, postRodCrossMatrix2));
                    
         
                    
                    if (!isnan(rodRotationMatrix.m00)) {
                        _previousGyroFullRotationMatrix = GLKMatrix3Multiply(_previousGyroFullRotationMatrix, rodRotationMatrix);
                    }
                    
                    NSLog(@"previousvec after = %f", _previousGyroFullRotationMatrix.m12);
                    

                    
                        _fullRotatedVec = GLKMatrix3MultiplyVector3(_previousGyroFullRotationMatrix, _fullCirVec);
                    
                    _fullRotatedVec.y = _fullRotatedVec.y * -1;
         
                    
                    _fullFPixelVec.x = 520.0 * (_fullRotatedVec.x/_fullRotatedVec.z) + 240.0;
                    _fullFPixelVec.y = 520.0 * (_fullRotatedVec.y/_fullRotatedVec.z) + 320.0;
                    
                    NSLog(@"fullrotatedvec.x = %f, rotatedvec.y = %f", _fullFPixelVec.x, _fullFPixelVec.y);

                    
                        _circleCenter = CGPointMake(_fullFPixelVec.x, _fullFPixelVec.y);
                        
                        Circle *newCircle = [[Circle alloc]initWithCGPoint:_circleCenter];
                        [_fullListOfCircles addObject:newCircle];
                    //}
                }
                    
 
                    // gyror and trace off
                    if (_objectToDraw == GYROR && !(_modeSwitch.on)) {
                        //if (_fullCircleVec.x != -30.0 && _fullCircleVec.y != -30.0) {
                        
                         NSLog(@"previousvec = %f, %f, %f", _previousGyroFullRotationMatrix.m11, _previousGyroFullRotationMatrix.m01, _previousGyroFullRotationMatrix.m02);
                        
                        // find big omega
                        NSLog(@"omega.x = %f, omega.y = %f, omega.z = %f", Omega.x, Omega.y, Omega.z);

                        
                        // find rotation matrix using omega
                        // find the cross matrix for omega
                        GLKMatrix3 preRodCrossMatrix = GLKMatrix3Make(0.0, -Omega.z, Omega.y,
                                                                      Omega.z, 0.0, -Omega.x,
                                                                      -Omega.y, Omega.x, 0.0);
                        
                        // find cross matrix squared
                        GLKMatrix3 preRodCrossMatrix2 = GLKMatrix3Multiply(preRodCrossMatrix, preRodCrossMatrix);
                        
                        // find magnitude of omega
                        float OmegaMagnitude = sqrtf((Omega.x * Omega.x) + (Omega.y * Omega.y) + (Omega.z * Omega.z));
                        
                        // find the sin and cos component of the formula
                        float sinComponent = sinf(OmegaMagnitude) / OmegaMagnitude;
                        float cosComponent = (1-cosf(OmegaMagnitude)) / (OmegaMagnitude * OmegaMagnitude);
                        
                        
                        // cross matrix multiplied by scalar
                        GLKMatrix3 postRodCrossMatrix = GLKMatrix3Make(preRodCrossMatrix.m00*sinComponent, preRodCrossMatrix.m01*sinComponent, preRodCrossMatrix.m02*sinComponent, preRodCrossMatrix.m10*sinComponent, preRodCrossMatrix.m11*sinComponent, preRodCrossMatrix.m12*sinComponent, preRodCrossMatrix.m20*sinComponent, preRodCrossMatrix.m21*sinComponent, preRodCrossMatrix.m22*sinComponent);
                        
                        GLKMatrix3 postRodCrossMatrix2 = GLKMatrix3Make(preRodCrossMatrix2.m00*cosComponent, preRodCrossMatrix2.m01*cosComponent, preRodCrossMatrix2.m02*cosComponent, preRodCrossMatrix2.m10*cosComponent, preRodCrossMatrix2.m11*cosComponent, preRodCrossMatrix2.m12*cosComponent, preRodCrossMatrix2.m20*cosComponent, preRodCrossMatrix2.m21*cosComponent, preRodCrossMatrix2.m22*cosComponent);
                        
                        
                        // complete rotation matrix
                        GLKMatrix3 rodRotationMatrix = GLKMatrix3Subtract(GLKMatrix3Identity, GLKMatrix3Add(postRodCrossMatrix, postRodCrossMatrix2));
                        NSLog(@"rodrotationmatr.m00 = %f, %f", rodRotationMatrix.m00, rodRotationMatrix.m01);

                        if (!isnan(rodRotationMatrix.m00)) {
                            _previousGyroFullRotationMatrix = GLKMatrix3Multiply(_previousGyroFullRotationMatrix, rodRotationMatrix);
                        }
                        
                        //NSLog(@"currentrotmatrix.m00 = %f", _currentGyroFullRotationMatrix.m00);
                        NSLog(@"prevrotmatrix.m00 = %f", _previousGyroFullRotationMatrix.m00);

                        
                        _fullRotatedVec = GLKMatrix3MultiplyVector3(_previousGyroFullRotationMatrix, _fullCirVec);
                        
                        _fullRotatedVec.y = _fullRotatedVec.y * -1;
           
                        
                        _fullFPixelVec.x = 520.0 * (_fullRotatedVec.x/_fullRotatedVec.z) + 240.0;
                        _fullFPixelVec.y = 520.0 * (_fullRotatedVec.y/_fullRotatedVec.z) + 320.0;
                        

                        
                        _circleCenter = CGPointMake(_fullFPixelVec.x, _fullFPixelVec.y);
                        
                        Circle *newCircle = [[Circle alloc]initWithCGPoint:_circleCenter];
                        [_fullListOfCircles removeAllObjects];
                        [_fullListOfCircles addObject:newCircle];
                        
                    }
                    
                    
                    
                    // gyro small angle and trace on
                if (_objectToDraw == GYROSA && _modeSwitch.on) {

                    
                        GLKMatrix3 saRotationMatrix = GLKMatrix3Make(1.0, Omega.z, -Omega.y,
                                                                     -Omega.z, 1.0, Omega.x,
                                                                     Omega.y, -Omega.x, 1.0);
                    
                    if (!isnan(saRotationMatrix.m00)) {
                        _previousGyroSARotaionMatrix = GLKMatrix3Multiply(_previousGyroSARotaionMatrix, saRotationMatrix);
                        
                    }
                    
                    
                    
                        _saRotatedVec = GLKMatrix3MultiplyVector3(_previousGyroSARotaionMatrix, _saCirVec);
                        
                        _saRotatedVec.y = _saRotatedVec.y * -1;
                  
                    
                        _saFPixelVec.x = 520.0 * (_saRotatedVec.x/_saRotatedVec.z) + 240.0;
                        _saFPixelVec.y = 520.0 * (_saRotatedVec.y/_saRotatedVec.z) + 320.0;

                    
                    
                        _circleCenter = CGPointMake(_saFPixelVec.x, _saFPixelVec.y);
                        
                        Circle * newCircle = [[Circle alloc]initWithCGPoint:_circleCenter];
                        [_saListOfCircles addObject:newCircle];
                                            
                
                   
                }
                
                // gyro small angle and trace off
                if (_objectToDraw == GYROSA && !(_modeSwitch.on)) {

                    
                    
                      GLKMatrix3 saRotationMatrix = GLKMatrix3Make(1.0, Omega.z, -Omega.y,
                                                                 -Omega.z, 1.0, Omega.x,
                                                                 Omega.y, -Omega.x, 1.0);
                    
                    if (!isnan(saRotationMatrix.m00)) {
                        _previousGyroSARotaionMatrix = GLKMatrix3Multiply(saRotationMatrix, _previousGyroSARotaionMatrix);
                        
                    }
                    
         
                    
                    _saRotatedVec = GLKMatrix3MultiplyVector3(_previousGyroSARotaionMatrix, _saCirVec);
                    
                    _saRotatedVec.y = -_saRotatedVec.y;
                  
                    
                    _saFPixelVec.x = 520.0 * (_saRotatedVec.x/_saRotatedVec.z) + 240.0;
                    _saFPixelVec.y = 520.0 * (_saRotatedVec.y/_saRotatedVec.z) + 320.0;
                    
                  
                    
                    
                    _circleCenter = CGPointMake(_saFPixelVec.x, _saFPixelVec.y);
                    
                    Circle * newCircle = [[Circle alloc]initWithCGPoint:_circleCenter];
                    [_saListOfCircles removeAllObjects];
                    [_saListOfCircles addObject:newCircle];
                
            }

        }];
    }
    //Draw circles
 
    
    //Iterate through the list of circles and draw them all
    if (_objectToDraw == DEVICEMOTION) {
        for (int i=0; i<[_dmListOfCircles count]; i++) {
            
            //Mapping constant calculated to do the mapping from Points to Context
            [_dmListOfCircles[i] drawCircle:context];
            }
    }
    
    //Iterate through the list of circles and draw them all
    if (_objectToDraw == GYROR) {
        for (int i=0; i<[_fullListOfCircles count]; i++) {
            
            //Mapping constant calculated to do the mapping from Points to Context
            [_fullListOfCircles[i] drawCircle:context];
        }
    }
    
    //Iterate through the list of circles and draw them all
    if (_objectToDraw == GYROSA) {
        for (int i=0; i<[_saListOfCircles count]; i++) {
            
            //Mapping constant calculated to do the mapping from Points to Context
            [_saListOfCircles[i] drawCircle:context];
        }
    }
    
    
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

//pragma mark - Actions
//warning Example of using segmented controls


- (IBAction)object2DSelectionSegmentChanged:(id)sender {
    

    if (_object2DSelectionSegmentControl.selectedSegmentIndex == GYROR) {

        _objectToDraw = GYROR;
        
    }else if (_object2DSelectionSegmentControl.selectedSegmentIndex == GYROSA) {
        
        _objectToDraw = GYROSA;
        
    }else if (_object2DSelectionSegmentControl.selectedSegmentIndex == DEVICEMOTION) {
        _objectToDraw = DEVICEMOTION;
        
    }
}

- (IBAction)modeSwitchChanged:(id)sender {
}

- (IBAction)resetPressed:(id)sender {
    _dmListOfCircles = nil;
    _fullListOfCircles = nil;
    _saListOfCircles = nil;
    
    
    _dmListOfCircles = [[NSMutableArray alloc]init];
    _fullListOfCircles = [[NSMutableArray alloc]init];
    _saListOfCircles = [[NSMutableArray alloc]init];
    
    [gyroQueue setSuspended:TRUE];
    [gyroQueue cancelAllOperations];
    gyroQueue = nil;
    
    [deviceMotionQueue setSuspended:TRUE];
    [deviceMotionQueue cancelAllOperations];
    deviceMotionQueue = nil;
    
    //stop device mpotion updates
    [mManager stopDeviceMotionUpdates];
    
    [mManager stopGyroUpdates];

    
    _referenceAttitude = nil;
    
    gyroFirstTime = true;
    
    deviceMotionQueue = [NSOperationQueue currentQueue];
    gyroQueue = [NSOperationQueue currentQueue];
    
    _circlePoint.x = 0.0;
    _circlePoint.y = 0.0;
    _circleCenter.x = -50.0;
    _circleCenter.y = -50.0;
    
    _previousGyroFullRotationMatrix = GLKMatrix3Make(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);
    
    _previousGyroSARotaionMatrix = GLKMatrix3Make(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0);
    
}

@end
