//
//  SENOSCLogEntry.h
//  HPV
//
//  Created by Jason McDermott on 22/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DataSession;

@interface SENOSCLogEntry : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) DataSession *datasession;

@end
