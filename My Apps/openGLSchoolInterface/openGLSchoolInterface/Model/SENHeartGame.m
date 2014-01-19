//
//  SENHeartGame.m
//  openGLSchoolInterface
//
//  Created by Jason McDermott on 18/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENHeartGame.h"

@interface SENHeartGame()

@end

@implementation SENHeartGame

- (id)init
{
    self = [super init];
    if (self) {
        
        // Initialization code here.
        _startPoint = [[NSDate alloc] init];
        _layering = [[SENLayering alloc] initWithRingCount:NUM_LAYERS];
        _score = 0;
    }
    return self;
}

- (void)keepScore
{
    
}

@end
