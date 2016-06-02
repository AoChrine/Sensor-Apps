//
//  Shape2D.m
//  Assignment2Template
//
//  Created on 2/1/16.
//  Copyright © 2016 CMPE161. All rights reserved.
//

#import "Shape2D.h"

@implementation Shape2D

//Standard init method
-(id)init {
    self = [super init];
    
    //Initialize variables here
    if (self) {
        
        _degreesToRotate = 0.0;
        _color = [[UIColor greenColor] CGColor];
        
        //RGBA values for yellow
        _red = 1.0f;
        _green = 0.843f;
        _blue = 0.0f;
        _alpha = 1.0f;
    
    }
    return self;
}



//Class method: rotate vector
+(CGPoint)rotateVector:(CGPoint) vectorToRotate : (double)degreesToRotate {
    
    CGPoint newVector;
    GLKMatrix2 rotationMatrix;
    
    //TODO: Do the matrix operation
    rotationMatrix.m00 = cosf(degreesToRotate * M_PI/180.0);
    rotationMatrix.m01 = sinf(degreesToRotate * M_PI/180.0);
    rotationMatrix.m10 = sinf(degreesToRotate * M_PI/180.0);
    rotationMatrix.m11 = cosf(degreesToRotate * M_PI/180.0);
    
    newVector.x = (vectorToRotate.x * rotationMatrix.m00) - (vectorToRotate.y * rotationMatrix.m01);
    newVector.y = (vectorToRotate.y * rotationMatrix.m11) + (vectorToRotate.x * rotationMatrix.m10);
    
    return newVector;
}

+(CGPoint)translateVector: (CGPoint) vectorToTranslate : (double) XTranslateAmount : (double) YTranslateAmount{
    
    CGPoint newVector;
    
    
    newVector.x = vectorToTranslate.x + XTranslateAmount;
    newVector.y = vectorToTranslate.y + YTranslateAmount;
    
    return newVector;
}

@end
