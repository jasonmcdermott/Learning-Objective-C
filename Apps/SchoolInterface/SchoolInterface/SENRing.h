//
//  SENRing.h
//  openGLExperiment
//
//  Created by Jason McDermott on 28/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SENUtilities.h"

@interface SENRing : NSObject

@property (nonatomic) NSInteger shapeType;
@property (nonatomic) int numSides;
@property (nonatomic) float diameter, blur, thickness, opacity;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) float x, y, z;
@property (nonatomic) BOOL active;

- (void)updateVals;

@end
