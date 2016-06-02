//
//  ViewController.h
//  Assignment2Template
//
//  Created on 2/1/16.
//  Copyright © 2016 CMPE161. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#include <math.h>
#include "Line.h"




@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CMMotionManager *mManager;

}

//Enums
typedef enum { ACCELEROMETER, DEVICEMOTION } ObjectType;

//Properties
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) size_t height;
@property (nonatomic) size_t width;
@property (nonatomic) CGPoint contextSize;
@property (nonatomic) CGPoint viewSize;
@property (nonatomic) ObjectType objectToDraw;

// setting these values as properties so we can just change the value for them in the app.
@property (nonatomic) Line *AccNewLine;
@property (nonatomic) Line *DMNewLine;
@property (nonatomic) CGPoint startPointA;
@property (nonatomic) CGPoint endPointA;
@property (nonatomic) CGPoint startPointD;
@property (nonatomic) CGPoint endPointD;


//Outlets
@property (weak, nonatomic) IBOutlet UISegmentedControl *object2DSelectionSegmentControl;





//Actions
- (IBAction)object2DSelectionSegmentChanged:(id)sender;

- (IBAction)startUpdate:(id)sender;
- (IBAction)stopUpdate:(id)sender;

@end

