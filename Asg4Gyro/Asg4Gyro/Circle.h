//
//  Circle.h
//  Asg4Gyro
//
//  Created by Alexander Ou on 3/7/16.
//  Copyright © 2016 ChrineApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#include <math.h>
#include "Shape2D.h"

#ifndef Circle_h
#define Circle_h
@interface Circle : Shape2D

//Variables
@property (nonatomic) CGPoint circleCenter;
@property (nonatomic) CGFloat circleSize;



//Methods
-(id)init;
-(id)initWithCGPoint : (CGPoint) point;
-(void)drawCircle:(CGContextRef) context;

@end
#endif /* Circle_h */
