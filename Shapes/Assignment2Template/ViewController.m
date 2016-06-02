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

#pragma mark - View methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.rotateText.delegate = self;
    self.TUDText.delegate = self;
    self.TLRText.delegate = self;

    
    i = 0;
    lineStart = CGPointMake(-10.0, -10.0);
    lineEnd = CGPointMake(-10.0, -10.0);
    
    NSLog(@"PI constant: %f",M_PI);
    
    //Initialize any variables
    _viewSize.x = self.view.frame.size.width;//Width of UIView
    _viewSize.y =self.view.frame.size.height;//Height of UIView
    
    NSLog(@"Width of UIView: %f",_viewSize.x);
    NSLog(@"Height of UIView: %f",_viewSize.y);
    
    //have a global variable to keep track of the coordinate.
    //int newX;
    //int newY;
    
    //Initialize arrays
    _listOfCircles = [[NSMutableArray alloc]init];
    _listofLines = [[NSMutableArray alloc]init];
    _listofSquare = [[NSMutableArray alloc]init];
    
    //Initialize AVCaptureDevice
    [self initCapture];
 
    //this allows the user to have multiple fingers touching the screen.
    self.view.multipleTouchEnabled = YES;
    
    // self.circleA = [[_CGContextRef alloc] init];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event{

    CGPoint point = [[touches anyObject]locationInView:self.view];
    NSLog(@"x coord = %f" @"y coord = %f",point.x, point.y);
          
    if (_objectToDraw == CIRCLE) {
        CGPoint circlecenter = [[touches anyObject]locationInView:self.view];
        Circle *newCircle = [[Circle alloc]initWithCGPoint:circlecenter];
        [_listOfCircles addObject:newCircle];
    }
    
    if (_objectToDraw == SQUARE) {
        if ([_listofSquare count] == 0) {
            CGPoint newCenter = CGPointMake(187.5f, 333.5f);
            Square *newSquare = [[Square alloc]initWithCGPoint:newCenter];
            [_listofSquare addObject:newSquare];
        }
    }
    
    if (_objectToDraw == LINE) {
        //when I = 0, this is for the case if we made our first endpoint
        if (i == 0) {
            lineStart = [[touches anyObject]locationInView:self.view];
        //second end point
        }else if(i > 0) {
            lineEnd = [[touches anyObject]locationInView:self.view];
            Line *newLine = [[Line alloc]initFromCGPoint:lineStart ToCGPoint:lineEnd];
            [_listofLines addObject:newLine];
            i--;
        }
        //So if we only made one endpoint for a line, increment i so we
        //can keep track how many times it takes to make one endpoint.
        if (lineStart.x != -10.0 && lineStart.y != -10.0 && lineEnd.x == -10.0 && lineEnd.y == -10.0) {
            i++;
        }
        // have to do this in order to make second line
        lineEnd = CGPointMake(-10.0, -10.0);
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
    if (motion == UIEventSubtypeMotionShake )
    {
        // shaking has began.
        NSLog(@" I have shaked!");
        
        
        //write code here to set every single contect to nil
        _listOfCircles = nil;
        _listofSquare = nil;
        _listofLines = nil;
        
        _listOfCircles = [[NSMutableArray alloc]init];
        _listofLines = [[NSMutableArray alloc]init];
        _listofSquare = [[NSMutableArray alloc]init];
        
        _rotateText.text = nil;
        _TUDText.text = nil;
        _TLRText.text = nil;
        
    }
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
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
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
    
    
//warning Here is where you draw 2D objects
    //----------------------------------------------------------------------------------------
    //TODO: Here is where you draw 2D objects.
    //----------------------------------------------------------------------------------------
    //Draw axes

    
    
    
    
    //Draw circles
    if (_objectToDraw == CIRCLE) {
  
        //Iterate through the list of circles and draw them all
        for (int i=0; i<[_listOfCircles count]; i++) {
            
            //Mapping constant calculated to do the mapping from Points to Context
            [_listOfCircles[i] drawCircle:
                                  context:
                                  CGPointMake(
                                  (_contextSize.y/_viewSize.x),
                                  (_contextSize.x/_viewSize.y))];
        }
        

    //Draw lines 
    }else if (_objectToDraw == LINE){
        for (int i = 0; i<[_listofLines count]; i++) {
            [_listofLines[i] drawLine:
                                  context:
                                  CGPointMake(
                                  (_contextSize.y/_viewSize.x),
                                  (_contextSize.x/_viewSize.y))];
        }

        
     //draw the square.
    }else if (_objectToDraw == SQUARE) {
        for (int i = 0; i<[_listofSquare count]; i++) {
            [_listofSquare[i] drawSquare:
                                 context:
                                  CGPointMake(
                                  (_contextSize.y/_viewSize.x),
                                  (_contextSize.x/_viewSize.y))];
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


//pragma mark - Actions
//warning Example of using segmented controls
- (IBAction)object2DSelectionSegmentChanged:(id)sender {
    
    //Line selected
    if (_object2DSelectionSegmentControl.selectedSegmentIndex == LINE) {
        
        //Let the captureOutput() know to draw lines only
        _objectToDraw = LINE;
        
        
        
        
        
    //Circle selected
    }else if (_object2DSelectionSegmentControl.selectedSegmentIndex == CIRCLE) {
        
        //Let the captureOutput() know to draw circles only
        _objectToDraw = CIRCLE;
 
    }else if (_object2DSelectionSegmentControl.selectedSegmentIndex == SQUARE) {
        _objectToDraw = SQUARE;
        
    }
}

- (IBAction)didRotate:(id)sender {
    if (_objectToDraw == SQUARE) {

        if([_listofSquare count] > 0) {
            Square *newSquare = [_listofSquare objectAtIndex:0];
            CGPoint transCenter = newSquare.center;
            CGPoint transSquareA = newSquare.squareA;
            CGPoint transSquareB = newSquare.squareB;
            CGPoint transSquareC = newSquare.squareC;
            CGPoint transSquareD = newSquare.squareD;

            transSquareA.x = transSquareA.x - transCenter.x;
            transSquareA.y = transSquareA.y - transCenter.y;
            
            transSquareB.x = transSquareB.x - transCenter.x;
            transSquareB.y = transSquareB.y - transCenter.y;
            
            transSquareC.x = transSquareC.x - transCenter.x;
            transSquareC.y = transSquareC.y - transCenter.y;
            
            transSquareD.x = transSquareD.x - transCenter.x;
            transSquareD.y = transSquareD.y - transCenter.y;
            
            double DegToRotate = [_rotateText.text doubleValue];
            
            transSquareA = [Shape2D rotateVector:transSquareA : DegToRotate];
            transSquareB = [Shape2D rotateVector:transSquareB : DegToRotate];
            transSquareC = [Shape2D rotateVector:transSquareC : DegToRotate];
            transSquareD = [Shape2D rotateVector:transSquareD : DegToRotate];

            transSquareA.x = transSquareA.x + transCenter.x;
            transSquareA.y = transSquareA.y + transCenter.y;
            
            transSquareB.x = transSquareB.x + transCenter.x;
            transSquareB.y = transSquareB.y + transCenter.y;
            
            transSquareC.x = transSquareC.x + transCenter.x;
            transSquareC.y = transSquareC.y + transCenter.y;
            
            transSquareD.x = transSquareD.x + transCenter.x;
            transSquareD.y = transSquareD.y + transCenter.y;
            
            Square *translatedSquare = [[Square alloc]initWithAllCGPoint:transCenter :transSquareA :transSquareB :transSquareC :transSquareD];
            
            [_listofSquare removeAllObjects];
            
            [_listofSquare addObject:translatedSquare];
            

        }
    }
}

- (IBAction)didTranslate:(id)sender {
    
    if(_objectToDraw == SQUARE) {
        if([_listofSquare count]>0) {
            Square *newSquare = [_listofSquare objectAtIndex:0];
            CGPoint transCenter = newSquare.center;
            CGPoint transSquareA = newSquare.squareA;
            CGPoint transSquareB = newSquare.squareB;
            CGPoint transSquareC = newSquare.squareC;
            CGPoint transSquareD = newSquare.squareD;
            
            double XTrans = 0, YTrans = 0;
            if (_TLRText.text && _TLRText.text.length > 0) {
                XTrans = [_TLRText.text doubleValue];
            }
            if (_TUDText.text && _TUDText.text.length > 0) {
                YTrans = [_TUDText.text doubleValue];
            }
            
            CGPoint newTransCenter = [Shape2D translateVector:transCenter :XTrans :YTrans];
            CGPoint amountToTrans;
            amountToTrans.x = newTransCenter.x - transCenter.x;
            amountToTrans.y = newTransCenter.y - transCenter.y;
            
            transSquareA.x = transSquareA.x + amountToTrans.x;
            transSquareA.y = transSquareA.y + amountToTrans.y;
            
            transSquareB.x = transSquareB.x + amountToTrans.x;
            transSquareB.y = transSquareB.y + amountToTrans.y;
            
            transSquareC.x = transSquareC.x + amountToTrans.x;
            transSquareC.y = transSquareC.y + amountToTrans.y;
            
            transSquareD.x = transSquareD.x + amountToTrans.x;
            transSquareD.y = transSquareD.y + amountToTrans.y;

            Square *ActualTranslatedSquare = [[Square alloc]initWithAllCGPoint:newTransCenter :transSquareA :transSquareB :transSquareC :transSquareD];
            
            [_listofSquare removeAllObjects];
            [_listofSquare addObject:ActualTranslatedSquare];
        }
    }
    
    
}
@end
