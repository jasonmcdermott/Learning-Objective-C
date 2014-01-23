//
//  SENQuestionnaire.h
//  HPV
//
//  Created by Jason McDermott on 23/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SENQuestionnaire : NSManagedObject

@property (nonatomic, retain) NSNumber *questionnaireAge;
@property (nonatomic, retain) NSString *school;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSString *vaccineTakenToday;
@property (nonatomic) NSInteger age;
@property (nonatomic) BOOL didTakeVaccineToday;
@property (nonatomic) BOOL didTakeOtherVaccinesToday;

@end
