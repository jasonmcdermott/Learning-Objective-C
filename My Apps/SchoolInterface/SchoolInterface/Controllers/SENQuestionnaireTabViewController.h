//
//  SENiPadSettingsViewController.h
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "constants.h"

@interface SENQuestionnaireTabViewController : UIViewController

@property (strong, nonatomic) NSDate *date;
#pragma mark Variables
@property (strong, nonatomic) NSDate *birthDate;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *vaccineTakenTodayAnswer;
@property (strong, nonatomic) NSString *whichVaccineTakenToday;
@property (strong, nonatomic) NSString *otherVaccineTakenTodayAnswer;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSString *schoolName;

#pragma mark Data Arrays
@property (strong, nonatomic) NSArray *questionnaireAges;
@property (strong, nonatomic) NSArray *questionnaireVaccines;
@property (strong, nonatomic) NSArray *questionnaireSchools;
@property (strong, nonatomic) NSArray *questionnaireBirthdayMonths;
@property (strong, nonatomic) NSArray *questionnaireBirthdayDays;



@end
