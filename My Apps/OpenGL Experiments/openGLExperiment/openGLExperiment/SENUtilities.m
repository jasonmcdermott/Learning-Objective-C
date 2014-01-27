//
//  SENUtilities.m
//  openGLExperiment
//
//  Created by Jason McDermott on 28/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENUtilities.h"

@implementation SENUtilities

+ (float)randomFloatInRange:(float)Min :(float)Max;
{
    float rand = Min+(Max-Min)*((float)arc4random())/ULONG_MAX;
    return rand;
}

+ (CGFloat)randomCGFloatInRange:(float)Min :(float)Max;
{
    CGFloat rand = Min+(Max-Min)*((CGFloat)arc4random())/ULONG_MAX;
    return rand;
}

+ (int)randomIntInRange:(int)Min :(int)Max;
{
//    int rand = Min+(Max-Min)*((int)arc4random())/ULONG_MAX;
    int rand = (arc4random() % Max) + 1;
    return rand;
}


@end
