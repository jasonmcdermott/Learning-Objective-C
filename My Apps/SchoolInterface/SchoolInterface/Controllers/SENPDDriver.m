//
//  SENPDDriver.m
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENPDDriver.h"
#include "PdBase.h"

@implementation SENPDDriver

-(void) startSession
{
    //Send to PD - "session-start"
    //Send bang.
    @autoreleasepool {
//        [PdBase sendBangToReceiver:@"session-start"];
    }
}

-(void) endSession
{
    //Send a message to "session-end"
    //Send bang.
    @autoreleasepool {
//        [PdBase sendBangToReceiver:@"session-end"];
    }
}

-(void) rawPulse
{
    //Send a message to "heart-ibi"
    // We know this is the RAW_PULSE event.
    //Send bang.
    @autoreleasepool {
//        [PdBase sendBangToReceiver:@"pulse-raw"];
    }
}

-(void) sendtoPDBaseReliability:(int) signal
{
//    NSNumber *value = [NSNumber numberWithInt:signal];
//    [PdBase sendFloat:[value floatValue] toReceiver:@"sensor-reliability"];
}

-(void) sendIBI:(int) signal
{
//    NSNumber *value = [NSNumber numberWithInt:signal];
//    [PdBase sendFloat:[value floatValue] toReceiver:@"heart-ibi"];
}

@end
