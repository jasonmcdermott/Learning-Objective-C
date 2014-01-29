//
//  SENRing.m
//  openGLExperiment
//
//  Created by Jason McDermott on 28/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENRing.h"
#define ARC4RANDOM_MAX      0x100000000

@implementation SENRing

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        CGFloat red, green, blue, alpha;
        red = [SENUtilities randomCGFloatInRange:0.0 :1.0];
        green = [SENUtilities randomCGFloatInRange:0.0 :1.0];
        blue = [SENUtilities randomCGFloatInRange:0.0 :1.0];
        alpha = [SENUtilities randomCGFloatInRange:0.0 :1.0];
        
        self.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];

        self.x = [SENUtilities randomFloatInRange:-1 :1];
        self.y = [SENUtilities randomFloatInRange:-1 :1];
        self.z = [SENUtilities randomFloatInRange:-1 :1];
        
        self.shapeType = [SENUtilities randomIntInRange:0 :3];
        self.numSides = [SENUtilities randomIntInRange:3 :50];
        self.diameter = [SENUtilities randomFloatInRange:-0.15 :0.40];
        self.thickness = [SENUtilities randomFloatInRange:0 :self.diameter/2];
        self.blur = [SENUtilities randomFloatInRange:0 :0.40];
        self.opacity = [SENUtilities randomFloatInRange:0 :0.40];
        self.active = [SENUtilities randomBool];
//        NSLog(@"active: %hhd, opacity: %f, x: %f, y: %f, z: %f, blur: %f, thickness: %f, diameter: %f, numSides: %d", self.active, self.opacity, self.x, self.y, self.z, self.blur, self.thickness, self.diameter, self.numSides);
    }
    return self;
}

- (void)updateVals
{
    self.diameter += 0.001;
}

@end
