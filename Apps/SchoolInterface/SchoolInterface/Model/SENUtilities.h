//
//  SENUtilities.h
//  HPV
//
//  Created by Jason McDermott on 24/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface SENUtilities : NSObject

+ (NSString *)getUUID;
+ (NSString*)getUUIDString:(CFUUIDRef)ref;

+ (NSString*)getStringForKey:(NSString*)key;
+ (void)setStringForKey:(NSString*)value withKey:(NSString*)key;
+ (void)setIntForKey:(NSInteger)value withKey:(NSString*)key;

+ (float)randomFloatInRange:(float)Min :(float)Max;
+ (CGFloat)randomCGFloatInRange:(float)Min :(float)Max;
+ (int)randomIntInRange:(int)Min :(int)Max;
+ (BOOL)randomBool;



@property (strong, nonatomic) NSString *school;

@end
