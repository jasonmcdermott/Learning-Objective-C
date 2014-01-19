//
//  SENHeartGame.m
//  openGLSchoolInterface
//
//  Created by Jason McDermott on 18/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENHeartGame.h"

@interface SENHeartGame()
@property (nonatomic, readwrite) NSInteger score;

@property (strong, nonatomic) NSMutableArray *rings;
@property (weak, nonatomic) NSString *state;
@end

@implementation SENHeartGame

- (SENLayering *)layering
{
    if (!_layering) _layering = [[SENLayering alloc] initWithRingCount:NUM_LAYERS];
    return _layering;
}

@end
