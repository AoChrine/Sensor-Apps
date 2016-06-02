//
//  ViewController.h
//  Assignment2Template
//
//  Created on 2/1/16.
//  Copyright © 2016 CMPE161. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#include <math.h>
#include "Circle.h"
#include "Line.h"
#include "Square.h"

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, UITextFieldDelegate>

extern int i;
extern CGPoint lineStart;
extern CGPoint lineEnd;

//Enums
typedef enum { LINE, CIRCLE, SQUARE } ObjectType;

//Properties
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) size_t height;
@property (nonatomic) size_t width;
@property (nonatomic) CGPoint contextSize;
@property (nonatomic) CGPoint viewSize;
@property (nonatomic) ObjectType objectToDraw;
@property (nonatomic) NSMutableArray* listOfCircles;
@property (nonatomic) NSMutableArray* listofLines;
@property (nonatomic) NSMutableArray* listofSquare;

//@property (nonatomic) CGContextRef *circleA;

-(void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;


//Outlets might have to redo the button
@property (weak, nonatomic) IBOutlet UISegmentedControl *object2DSelectionSegmentControl;


-(BOOL)canBecomeFirstResponder;
-(void)viewDidAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;
-(void)viewDidDisappear:(BOOL)animated;
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event;


@property (weak, nonatomic) IBOutlet UITextField *rotateText;
@property (weak, nonatomic) IBOutlet UITextField *TUDText;
@property (weak, nonatomic) IBOutlet UITextField *TLRText;


//Actions
- (IBAction)object2DSelectionSegmentChanged:(id)sender;
- (IBAction)didRotate:(id)sender;
- (IBAction)didTranslate:(id)sender;





@end

