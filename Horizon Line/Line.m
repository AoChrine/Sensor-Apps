//
//  Line.m
//  Horizon Line
//
//  Created by Alexander Ou on 2/26/16.
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

-(void) changeToCGPoint: (CGPoint) startPoint ToCGPoint: (CGPoint) endPoint {
    _pointA.x = startPoint.x;
    _pointA.y = startPoint.y;
    _pointB.x = endPoint.x;
    _pointB.y = endPoint.y;
}


-(void)drawLine:(CGContextRef) context {
    
    CGPoint newStart, newEnd;
    newStart.x = _pointA.x;
    newStart.y = _pointA.y;
    newEnd.x = _pointB.x;
    newEnd.y = _pointB.y;
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 8.0f);
    CGContextMoveToPoint(context, newStart.y, newStart.x);
    CGContextAddLineToPoint(context, newEnd.y, newEnd.x);
    CGContextStrokePath(context);

}

@end
