//
//  SENLayering.h
//  openGLSchoolInterface
//
//  Created by Jason McDermott on 18/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SENRing.h"

@interface SENLayering : NSObject

- (instancetype)initWithRingCount:(NSUInteger)count;

@property (strong, nonatomic) NSMutableArray *rings;

@end
