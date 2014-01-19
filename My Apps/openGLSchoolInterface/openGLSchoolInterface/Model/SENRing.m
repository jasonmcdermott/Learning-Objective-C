//
//  SENRing.m
//  openGLSchoolInterface
//
//  Created by Jason McDermott on 18/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENRing.h"



@interface SENRing()



@end

@implementation SENRing

- (void)updateRing:(NSString *)shapeType withNumSides:(NSInteger *)num withPosition:(Point3D *)point withColor:(UIColor *)color
{
    _color = color;
    _position = point;
    _numSides = *num;
    _shapeType = shapeType;
    if (_numSides < 3) _numSides = 3;
}


@end

