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

@property (nonatomic, retain) NSString *school;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSString *vaccineTaken;
@property (strong, nonatomic) NSString *gender;

@property (strong, nonatomic) NSNumber *age;

@property (nonatomic) NSString *didTakeVaccine;
@property (nonatomic) NSString *didTakeOtherVaccine;

@property (strong, nonatomic) NSDate *birthDate;
@property (strong, nonatomic) NSDate *submittedDateTime;

@property (strong, nonatomic) NSString *writtenToDisk;
@property (strong, nonatomic) NSString *uploaded;
@end
