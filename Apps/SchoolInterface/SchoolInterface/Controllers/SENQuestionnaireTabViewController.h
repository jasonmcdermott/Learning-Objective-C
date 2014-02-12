//
//  SENiPadSettingsViewController.h
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SENConstants.h"
#import "SENQuestionnaire.h"

//#import "SENXmlDataGenerator.h"
#import "AFNetworking.h"
#import "SENUtilities.h"


@protocol QuestionnaireDelegate <NSObject>

- (void) startGLView;

@end


@interface SENQuestionnaireTabViewController : UIViewController

@property (nonatomic, weak) id <QuestionnaireDelegate> delegate;

@property (strong, nonatomic) NSDate *date;
#pragma mark Variables

@property (strong, nonatomic) NSDate *birthDate;
@property (strong, nonatomic) NSDate *submittedDateTime;
@property (strong, nonatomic) NSString *birthDateString;

@property (strong, nonatomic) NSNumber *age;

@property (nonatomic) NSString *didTakeVaccine;
@property (nonatomic) NSString *didTakeOtherVaccine;

@property (strong, nonatomic) NSString *vaccineTaken;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *questionnaireID;
@property (strong, nonatomic) NSString *school;

#pragma mark Data Arrays
@property (strong, nonatomic) NSArray *questionnaireAges;
@property (strong, nonatomic) NSArray *questionnaireVaccines;
@property (strong, nonatomic) NSArray *questionnaireSchools;
@property (strong, nonatomic) NSArray *questionnaireBirthdayMonths;
@property (strong, nonatomic) NSArray *questionnaireBirthdayDays;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) SENQuestionnaire *questionnaire;

@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) SENUtilities *utilities;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) NSString *appID;


@end
