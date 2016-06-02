//
//  ViewController.h
//  Asg4Gyro
//
//  Created by Alexander Ou on 3/7/16.
//  Copyright © 2016 ChrineApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#include <math.h>
#include "Circle.h"

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UITextFieldDelegate>
{
    CMMotionManager *mManager;
    NSOperationQueue *deviceMotionQueue;
    NSOperationQueue *gyroQueue;
    Boolean gyroFirstTime;
}


// enum

typedef enum { GYROR, GYROSA, DEVICEMOTION } ObjectType;

// properties
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) size_t height;
@property (nonatomic) size_t width;
@property (nonatomic) CGPoint contextSize;
@property (nonatomic) CGPoint viewSize;
@property (nonatomic) ObjectType objectToDraw;
@property (nonatomic) NSMutableArray* dmListOfCircles;
@property (nonatomic) NSMutableArray* fullListOfCircles;
@property (nonatomic) NSMutableArray* saListOfCircles;
@property (nonatomic) CGPoint circlePoint;
@property (nonatomic) CGPoint circleCenter;

// dm touch vector
@property (nonatomic) GLKVector3 dmCircleVec;
// dm camera vec
@property (nonatomic) GLKVector3 dmCirVec;
//dm rotated vec in gyro, which will be converted to camera ref.
@property (nonatomic) GLKVector3 dmRotatedVec;
//dm pixel to draw vec
@property (nonatomic) GLKVector3 dmFPixelVec;


// gyrofull touch vec
@property (nonatomic) GLKVector3 fullCircleVec;
// gyrofull camera vec
@property (nonatomic) GLKVector3 fullCirVec;
// gyrofull rotated vec in gyro -> camera
@property (nonatomic) GLKVector3 fullRotatedVec;
// gyrofull pixel to draw vec
@property (nonatomic) GLKVector3 fullFPixelVec;


// gyro small angle touch vec
@property (nonatomic) GLKVector3 saCircleVec;
// gyro sa camera vec
@property (nonatomic) GLKVector3 saCirVec;
// gyro sa rotated vec in gyro -> camera
@property (nonatomic) GLKVector3 saRotatedVec;
// gyro sa pixel to draw vec
@property (nonatomic) GLKVector3 saFPixelVec;

// time stamp and attitude property
@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic) NSTimeInterval previousTime;
@property (nonatomic) NSTimeInterval changeInTime;
@property (nonatomic) CMAttitude *referenceAttitude;
@property (nonatomic) NSTimeInterval timestampReference;


// rotation matrices
@property (nonatomic) GLKMatrix3 previousGyroFullRotationMatrix;
@property (nonatomic) GLKMatrix3 currentGyroFullRotationMatrix;
@property (nonatomic) GLKMatrix3 previousGyroSARotaionMatrix;
@property (nonatomic) GLKMatrix3 currentGyroSARotationMatrix;

// detect touch
-(void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;


//Outlets might have to redo the button

@property (weak, nonatomic) IBOutlet UISegmentedControl *object2DSelectionSegmentControl;
@property (weak, nonatomic) IBOutlet UISwitch *modeSwitch;


-(BOOL)canBecomeFirstResponder;
-(void)viewDidAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;
-(void)viewDidDisappear:(BOOL)animated;


//Actions
- (IBAction)object2DSelectionSegmentChanged:(id)sender;
- (IBAction)modeSwitchChanged:(id)sender;
- (IBAction)resetPressed:(id)sender;

@end

