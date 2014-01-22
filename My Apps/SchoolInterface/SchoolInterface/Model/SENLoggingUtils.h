//
//  SENLoggingUtils.h
//  HPV
//
//  Created by Jason McDermott on 22/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SENDataSession.h"
#import "SENOSCLogEntry.h"
#import "ASIHTTPRequest.h"
#import "SENOscTolibPDMap.hpp"

#import "RawPulse.h"
#import "MsgFloatOrder.h"
#import "MsgIntOrder.h"

#include <deque>

@interface SENLoggingUtils : NSObject

DataSession *currentDataSession;
wrapper::oscTolibPDMap pd_mapper;

// queue of osc messages
std::deque< RawPulse* > rawpulses;
std::deque< MsgFloatOrder* > msgfloatorders;
std::deque< MsgIntOrder* > msgintorders;

@property (strong, nonatomic) DataSession *currentDataSession;

-(void)startDataSessionWithName:(NSString *)name andWithLocation:(NSString *)location;
-(void)endCurrentDataSession;
-(void)logAllDataSessions;

-(void)logRawPulseWithMsgOrderAndSendToPD:(NSNumber *)msgOrder;
-(void)logOSCMessageAndSendToPD:(NSString *) msg withIntValue:(NSNumber *) value withMsgOrder:(NSNumber *) msgOrder;
-(void)logOSCMessageAndSendToPD:(NSString *) msg withFloatValue:(NSNumber *) value withMsgOrder:(NSNumber *) msgOrder;


@end
