//
//  Square.m
//  Assignment2Template
//
//  Created by Alexander Ou on 2/10/16.
//  Copyright © 2016 CMPE161. All rights reserved.
//

#import "Square.h"

@implementation Square

-(id)init {
    self = [super init];
    
    if (self) {
        _center.x =170.5f;
        _center.y =320.5f;
        _squareA.x = _center.x - 50;
        _squareA.y = _center.y - 50;
        _squareB.x = _center.x + 50;
        _squareB.y = _center.y - 50;
        _squareC.x = _center.x - 50;
        _squareC.y = _center.y + 50;
        _squareD.x = _center.x + 50;
        _squareD.y = _center.y + 50;
        
    } 
    return self;
}

-(id) initWithCGPoint:(CGPoint)point {
    self = [super init];
    
    if (self) {
        _center.x = point.x;
        _center.y = point.y;
        _squareA.x = _center.x - 50;
        _squareA.y = _center.y - 50;
        _squareB.x = _center.x + 50;
        _squareB.y = _center.y - 50;
        _squareC.x = _center.x - 50;
        _squareC.y = _center.y + 50;
        _squareD.x = _center.x + 50;
        _squareD.y = _center.y + 50;

   }
    return self;
}

-(id)initWithAllCGPoint : (CGPoint) center : (CGPoint) squareA : (CGPoint) squareB : (CGPoint) squareC : (CGPoint) squareD {
    self = [super init];
    if(self) {
        
        _center.x = center.x;
        _center.y = center.y;
        _squareA.x = squareA.x;
        _squareA.y = squareA.y;
        _squareB.x = squareB.x;
        _squareB.y = squareB.y;
        _squareC.x = squareC.x;
        _squareC.y = squareC.y;
        _squareD.x = squareD.x;
        _squareD.y = squareD.y;
        
        
        
        
    }
    return self;
}





-(void)drawSquare:(CGContextRef) context : (CGPoint) mappingConstant {
 
    
    CGPoint newSquareA, newSquareB, newSquareC, newSquareD;
    newSquareA.x = _squareA.x*mappingConstant.x;
    newSquareA.y = _squareA.y*mappingConstant.y;
    newSquareB.x = _squareB.x*mappingConstant.x;
    newSquareB.y = _squareB.y*mappingConstant.y;
    newSquareC.x = _squareC.x*mappingConstant.x;
    newSquareC.y = _squareC.y*mappingConstant.y;
    newSquareD.x = _squareD.x*mappingConstant.x;
    newSquareD.y = _squareD.y*mappingConstant.y;
    
    CGContextSetStrokeColorWithColor(context, [UIColor magentaColor].CGColor);
    CGContextSetLineWidth(context, 5.0f);
    CGContextMoveToPoint(context, newSquareA.y, newSquareA.x);
    CGContextAddLineToPoint(context, newSquareB.y, newSquareB.x);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, newSquareB.y, newSquareB.x);
    CGContextAddLineToPoint(context, newSquareD.y, newSquareD.x);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, newSquareD.y, newSquareD.x);
    CGContextAddLineToPoint(context, newSquareC.y, newSquareC.x);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, newSquareC.y, newSquareC.x);
    CGContextAddLineToPoint(context, newSquareA.y, newSquareA.x);
    CGContextStrokePath(context);
}

@end
