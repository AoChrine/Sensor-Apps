//
//  Square.h
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
#include "Shape2D.h"

@interface Square : Shape2D

// variables
@property (nonatomic) CGPoint center;
@property (nonatomic) CGPoint squareA;
@property (nonatomic) CGPoint squareB;
@property (nonatomic) CGPoint squareC;
@property (nonatomic) CGPoint squareD;


// methods
-(id)init;
-(id)initWithCGPoint : (CGPoint) point;
-(id)initWithAllCGPoint : (CGPoint) center : (CGPoint) squareA : (CGPoint) SquareB : (CGPoint) SquareC : (CGPoint) SquareD;
-(void)drawSquare:(CGContextRef) context : (CGPoint) mappingConstant;
@end
