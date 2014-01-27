//
//  SENUtilities.h
//  openGLExperiment
//
//  Created by Jason McDermott on 28/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENUtilities : NSObject

+ (float)randomFloatInRange:(float)Min :(float)Max;
+ (CGFloat)randomCGFloatInRange:(float)Min :(float)Max;
+ (int)randomIntInRange:(int)Min :(int)Max;

@end
