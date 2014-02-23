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
#import <CoreBluetooth/CoreBluetooth.h>

#import "SENConstants.h"
#include <CommonCrypto/CommonDigest.h>

@interface SENUtilities : NSObject {
    int newLine;
}

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
+ (void)addMessageTextToString:(NSMutableString *)mutableString withString:(NSString *)text toTextView:(UITextView *)textView withGesture:(BOOL)touched;

+ (NSString *)getNickname:(CBPeripheral *)peripheral;
+ (NSString *)computeNickname:(const void *)data :(size_t)len;
+ (NSString *)utf8:(NSData *)data;

@property (strong, nonatomic) NSString *school;



@end
