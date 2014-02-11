//
//  SENUtilities.m
//  HPV
//
//  Created by Jason McDermott on 24/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENUtilities.h"

@implementation SENUtilities

@synthesize school = _school;

+ (NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

+ (NSString*)getUUIDString:(CFUUIDRef)ref
{
    NSString *str = [NSString stringWithFormat:@"%@",ref];
    return [[NSString stringWithFormat:@"%@",str] substringWithRange:NSMakeRange(str.length - 36, 36)];
}

+ (NSString*)getStringForKey:(NSString*)key
{
    NSString* val = @"";
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults stringForKey:key];
    if (val == NULL) val = @"";
    return val;
}

+ (void)setStringForKey:(NSString*)value withKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}


+ (void)setIntForKey:(NSInteger)value withKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setInteger:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

#pragma mark - Random Number Generators

+ (float)randomFloatInRange:(float)Min :(float)Max;
{
    float rand = Min+(Max-Min)*((float)arc4random())/ULONG_MAX;
//    NSLog(@"float %f",rand);
    return rand;
}

+ (CGFloat)randomCGFloatInRange:(float)Min :(float)Max;
{
    CGFloat rand = Min+(Max-Min)*((CGFloat)arc4random())/ULONG_MAX;
    return rand;
//    NSLog(@"CGFloat %f",rand);
}

+ (int)randomIntInRange:(int)Min :(int)Max;
{
    //    int rand = Min+(Max-Min)*((int)arc4random())/ULONG_MAX;
    int rand = (arc4random() % Max) + 1;
//    NSLog(@"int %d",rand);
    return rand;
}

+ (BOOL)randomBool
{
    int rand = (arc4random() % 2) - 1;
    BOOL result;
    if (rand == 0) {
        result = NO;
    } else {
        result = YES;
    }
//    NSLog(@"bool %hhd",result);
    return result;
}

#pragma mark - Methods Not Currently In Use



-(NSString*)readXMLFile:(NSString *)file
{
    // function not in use
    NSString *docFile = file;
    NSFileManager *filemgr;
    NSData *databuffer;
    filemgr = [NSFileManager defaultManager];
    databuffer = [filemgr contentsAtPath: docFile];
    return [[NSString alloc] initWithData:databuffer encoding:NSUTF16StringEncoding];
    NSString *a = @"";
    return a;
}

- (void)convertDictionaryToJSON:(NSDictionary *)dict
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:dict
                        options:NSJSONWritingPrettyPrinted
                        error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        
        NSLog(@"Successfully serialized the dictionary into data.");
        NSString *jsonString =
        [[NSString alloc] initWithData:jsonData
                              encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String = %@", jsonString);
    }
    else if ([jsonData length] == 0 && error == nil){
        NSLog(@"No data was returned after serialization.");
    }
    else if (error != nil){
        NSLog(@"An error happened = %@", error);
    }
}

#pragma mark - random utes

+ (unsigned int)mergeBytes:(unsigned char)lsb :(unsigned char)msb
{
    unsigned int ret = msb & 0xFF;
    ret = ret << 7;
    ret = ret + lsb;
    return ret;
}


@end
