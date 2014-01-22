//
//  oscTolibPDMap.cpp
//  ofxParticle
//
//  Created by Andrew Nicholson on 25/04/13.
//
//

#include "SENOscTolibPDMap.hpp"
#include "PdBase.h"
#include "constants.h"

namespace wrapper {

    SENOscTolibPDMap::SENOscTolibPDMap() {
    
    }

    SENOscTolibPDMap::~SENOscTolibPDMap() {
        
    }

    
void SENOscTolibPDMap::startSession() {
    //Send to PD - "session-start"
    //Send bang.
    @autoreleasepool {
        
        [PdBase sendBangToReceiver:@"session-start"];
    }
}

void SENOscTolibPDMap::endSession() {
    //Send a message to "session-end"
    //Send bang.
    @autoreleasepool {
        [PdBase sendBangToReceiver:@"session-end"];
    }
}
    
void SENOscTolibPDMap::sendtoPDBaseReliability(int signal) {
    NSNumber *value = [NSNumber numberWithInt:signal];
    [PdBase sendFloat:[value floatValue] toReceiver:@"sensor-reliability"];
}

void SENOscTolibPDMap::decodeMessage(const char *_msg, float _value) {
    
    @autoreleasepool {
        
        NSNumber *value = [NSNumber numberWithFloat:_value];
        NSString *msg = [NSString stringWithUTF8String:_msg];
        
        //Send a message to PD "heart-ibi" if CLEAN_IBI osc message
        //
        NSString *cleanibi = [NSString stringWithUTF8String:MSG_CLEAN_IBI];
        if ([msg isEqualToString:cleanibi]) {
            [PdBase sendFloat:[value floatValue] toReceiver:@"heart-ibi"];
        }
        NSString *reliability = [NSString stringWithUTF8String:MSG_RELIABILITY];
        if ([msg isEqualToString:reliability]) {
            [PdBase sendFloat:[value floatValue] toReceiver:@"sensor-reliability"];
        }
        NSString *hb_raw = [NSString stringWithUTF8String:MSG_NUM_HEART_BEATS];
        if ([msg isEqualToString:hb_raw]) {
            [PdBase sendFloat:[value floatValue] toReceiver:@"raw-beat-count"];
        }
        NSString *hb_clean = [NSString stringWithUTF8String:MSG_CLEAN_COUNT];
        if ([msg isEqualToString:hb_clean]) {
            [PdBase sendFloat:[value floatValue] toReceiver:@"beat-count"];
        }
        NSString *max_ibi = [NSString stringWithUTF8String:MSG_MAX_IBI];
        if ([msg isEqualToString:max_ibi]) {
            [PdBase sendFloat:[value floatValue] toReceiver:@"session-ibi-max"];
        }
        NSString *min_ibi = [NSString stringWithUTF8String:MSG_MIN_IBI];
        if ([msg isEqualToString:min_ibi]) {
            [PdBase sendFloat:[value floatValue] toReceiver:@"session-ibi-min"];
        }
        
        NSString *avg_ibi = [NSString stringWithUTF8String:MSG_CURRENT_IBI];
        if ([msg isEqualToString:avg_ibi]) {
            [PdBase sendFloat:[value floatValue] toReceiver:@"session-ibi-current"];
        }
    }
}

void SENOscTolibPDMap::rawPulse() {
    
    //Send a message to "heart-ibi"
    // We know this is the RAW_PULSE event.
    //Send bang.
    @autoreleasepool {
        
        [PdBase sendBangToReceiver:@"pulse-raw"];

    }
}
    
}

