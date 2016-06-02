//
//  Line.h
//  Assignment2Template
//
//  Created by Alexander Ou on 2/10/16.
//  Copyright © 2016 CMPE161. All rights reserved.
//

#import "Shape2D.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#include <math.h>

extern int i;


@interface Line : Shape2D


// Variables
@property (nonatomic) CGPoint pointA;
@property (nonatomic) CGPoint pointB;

// Methods
-(id)init;
-(id)initFromCGPoint: (CGPoint) startPoint ToCGPoint: (CGPoint) endPoint;
-(void)drawLine:(CGContextRef) context : (CGPoint) mappingConstant;


@end
