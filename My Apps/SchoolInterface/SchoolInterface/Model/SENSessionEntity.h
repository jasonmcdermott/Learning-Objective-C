//
//  SENSessionEntity.h
//  HPV
//
//  Created by Jason McDermott on 22/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENSessionEntity : NSObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * sensitivity;
@property (nonatomic, retain) NSNumber * switchOSCIncoming;
@property (nonatomic, retain) NSNumber * switchOSCRelay;
@property (nonatomic, retain) NSNumber * incomingOSCport;
@property (nonatomic, retain) NSNumber * outgoingOSCport;
@property (nonatomic, retain) NSString * outgoingOSCip;

@end
