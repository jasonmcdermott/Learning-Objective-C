//
//  SENDataSession.h
//  HPV
//
//  Created by Jason McDermott on 22/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OSCLogEntry;

@interface SENDataSession : NSManagedObject

@property (nonatomic, retain) NSDate * datetime;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) NSSet *oscdataset;
@end

@interface SENDataSession (CoreDataGeneratedAccessors)

- (void)addOscdatasetObject:(OSCLogEntry *)value;
- (void)removeOscdatasetObject:(OSCLogEntry *)value;
- (void)addOscdataset:(NSSet *)values;
- (void)removeOscdataset:(NSSet *)values;

@end
