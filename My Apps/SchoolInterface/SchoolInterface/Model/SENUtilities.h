//
//  SENUtilities.h
//  HPV
//
//  Created by Jason McDermott on 24/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#include <sys/time.h>

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

+ (double) doubleTime;
+ (unsigned long long)microTime;
+ (void)addMessageText:(NSMutableString *)mutableString :(NSString *)text :(UITextView *)textView;

@property (strong, nonatomic) NSString *school;

@end
