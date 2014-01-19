//
//  SENHeartGame.h
//  openGLSchoolInterface
//
//  Created by Jason McDermott on 18/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "SENLayering.h"
#import "SENRing.h"
#import "constants.h"

@interface SENHeartGame : NSObject



@property (nonatomic, readonly) NSInteger score;
@property (strong, nonatomic) SENLayering *layering;

@end
