//
//  Line.m
//  Assignment2Template
//
//  Created by Alexander Ou on 2/10/16.
//  Copyright © 2016 CMPE161. All rights reserved.
//

#import "Line.h"

@implementation Line

-(id) init {
    self = [super init];
    if (self) {
        _pointA.x = 0.0f;
        _pointA.y = 0.0f;
        _pointB.x = 5.0f;
        _pointB.y = 5.0f;
    }
    return self;
}

-(id) initFromCGPoint:(CGPoint) startPoint ToCGPoint:(CGPoint)endPoint {
    self = [super init];
    if(self) {
        _pointA.x = startPoint.x;
        _pointA.y = startPoint.y;
        _pointB.x = endPoint.x;
        _pointB.y = endPoint.y;
        
    }
    return self;
}


-(void)drawLine:(CGContextRef) context : (CGPoint) mappingConstant {
    
    CGPoint newStart, newEnd;
    newStart.x = _pointA.x*mappingConstant.x;
    newStart.y = _pointA.y*mappingConstant.y;
    newEnd.x = _pointB.x*mappingConstant.x;
    newEnd.y = _pointB.y*mappingConstant.y;
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 5.0f);
    CGContextMoveToPoint(context, newStart.y, newStart.x);
    CGContextAddLineToPoint(context, newEnd.y, newEnd.x);
    CGContextStrokePath(context);    
}


@end
