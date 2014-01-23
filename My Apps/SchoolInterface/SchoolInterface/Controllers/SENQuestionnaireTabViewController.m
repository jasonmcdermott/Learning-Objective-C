//
//  SENiPadSettingsViewController.m
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENQuestionnaireTabViewController.h"

@interface SENQuestionnaireTabViewController ()
#pragma mark Interface Elements

@property (weak, nonatomic) IBOutlet UIView *questionnaireView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *hpvVaccineLabel;

#pragma mark User Data Entry
@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *agePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *vaccinePicker;


@property (weak, nonatomic) IBOutlet UISegmentedControl *didTakeVaccineControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *didTakeOtherVaccineControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;

@property (weak, nonatomic) IBOutlet UITextField *schoolTextString;


@end

@implementation SENQuestionnaireTabViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark Initialise
#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialSetup];
}

- (void)initialSetup
{
    self.submitButton.enabled = NO;
    self.school = @"";
    self.schoolTextString.text = [self getStringForKey:@"school"];

    self.questionnaireAges = @[@"10 years old", @"11 years old", @"12 years old", @"13 years old", @"14 years old", @"15 years old", @"16 years old", @"17 years old", @"18 years old"];
    self.questionnaireVaccines = @[@"please select one", @"my 1st vaccine", @"my 2nd vaccine", @"my 3rd vaccine"];
    
    self.questionnaireBirthdayMonths = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    self.questionnaireBirthdayDays = @[@"31",@"29",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    
    
    [_birthDatePicker addTarget:self
                   action:@selector(selectBirthDate:)
         forControlEvents:UIControlEventValueChanged];
    
    [self newQuestionnaire];
    
}

- (void)newQuestionnaire
{
    [self.genderControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self.didTakeVaccineControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self.didTakeOtherVaccineControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self.vaccinePicker selectRow:0 inComponent:0 animated:NO];
    
    self.questionnaire = [NSEntityDescription
                          insertNewObjectForEntityForName:@"SENQuestionnaire"
                          inManagedObjectContext:self.managedObjectContext];
    
    _uniqueID = [self GetUUID];
    _uuidLabel.text = _uniqueID;
    self.date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    self.dateTimeLabel.text = [dateFormatter stringFromDate:self.date];
}

- (NSString*)getStringForKey:(NSString*)key
{
    NSString* val = @"";
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults stringForKey:key];
    if (val == NULL) val = @"";
    return val;
}

#pragma mark UUID
#pragma mark -

- (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

//#pragma mark -
//#pragma mark PickerView
//
//- (void)setPickerHeight:(UIPickerView *)pickerView
//{
//    pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    CGSize ps = [pickerView sizeThatFits: CGSizeZero];
//    pickerView.frame = CGRectMake(0.0, 0.0, ps.width, 162.0);
//}

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    return 200.0;
//}


- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:_agePicker]) {
        return self.questionnaireAges.count;
    }
    else if ([pickerView isEqual:_vaccinePicker]) {
        return self.questionnaireVaccines.count;
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if ([pickerView isEqual:_agePicker]) {
        return self.questionnaireAges[row];
    }
    else if ([pickerView isEqual:_vaccinePicker]) {
        return self.questionnaireVaccines[row];
    } else {
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.vaccinePicker) {
        self.vaccineTaken = self.questionnaireVaccines[row];
    }
    [self checkCompleted];
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}



#pragma mark -
#pragma mark UI Utilities

- (IBAction)textFieldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
    [self checkCompleted];
}

- (IBAction)selectGender:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.gender = @"Male";
    } else {
        self.gender = @"Female";
    }
    [self checkCompleted];
}

- (IBAction)selectSchoolName:(UITextField *)sender {
    self.school = sender.text;
    [self setStringForKey:sender.text withKey:@"school"];
    [self checkCompleted];
}

- (IBAction)answerVaccineQuestion:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.didTakeVaccine = @"NO";
        self.hpvVaccineLabel.hidden = YES;
        self.vaccinePicker.hidden = YES;

    } else {
        self.didTakeVaccine = @"YES";
        self.hpvVaccineLabel.hidden = NO;
        self.vaccinePicker.hidden = NO;
    }
    [self checkCompleted];
}

- (IBAction)answerOtherVaccineQuestion:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.didTakeOtherVaccine = @"NO";
    } else {
        self.didTakeOtherVaccine = @"YES";
    }
    [self checkCompleted];
}


- (void)hideAll
{
    NSLog(@"hiding");
    self.view.hidden = YES;
}

#pragma mark -
#pragma mark Completion

- (IBAction)touchSubmitButton:(UIButton *)sender
{
    self.submittedDateTime = [[NSDate alloc] init];
    if ([self setCoreDataValues]) [self saveContext];
    [self hideAll];
    [self newQuestionnaire];
    [self resetValues];
    NSLog(@"saved");
}

- (void)resetValues
{
    self.vaccineTaken = @"";
    self.gender = @"";
    self.didTakeOtherVaccine = @"";
    self.didTakeVaccine = @"";
    self.submitButton.enabled = NO;
    self.hpvVaccineLabel.hidden = YES;
    self.vaccinePicker.hidden = YES;
}

- (IBAction)touchCancelButton:(UIButton *)sender
{
    [self hideAll];
}

#pragma mark -
#pragma mark DatePicker

- (IBAction)selectBirthDate:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSInteger age = [self ageFromBirthday:datePicker.date];
    [_agePicker selectRow:age-10 inComponent:0 animated:YES];
    self.birthDate = datePicker.date;
    
    
    NSArray *_array = [self.questionnaireAges[age-10] componentsSeparatedByString:@" "];
    NSString *first = [_array firstObject];
    self.age = [[NSNumber alloc] initWithInt:first.intValue];
    NSLog(@"%ld is the age chosen",(long)_age);
    [self checkCompleted];
}

- (NSInteger)ageFromBirthday:(NSDate *)birthdate {
    NSDate *today = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthdate
                                       toDate:today
                                       options:1];
    return ageComponents.year;
}

#pragma mark Persistent Values
#pragma mark -

- (void)setStringForKey:(NSString*)value withKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

- (void)setIntForKey:(NSInteger)value withKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setInteger:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

#pragma mark -
#pragma mark Core Data

- (void)checkCompleted
{
    int completionScore = 0;
    
    if (_birthDate != nil) completionScore++;
    if (_gender != nil) completionScore++;
    if (![self.schoolTextString.text isEqualToString:@""]) completionScore++;
    
    if (self.didTakeVaccine != nil) completionScore++;
    if (self.didTakeOtherVaccine != nil) completionScore++;
    if ([self.didTakeVaccine isEqualToString:@"YES"]) {
        if ([self.vaccineTaken isEqualToString:@"please select one"] || self.vaccineTaken == nil || [self.vaccineTaken isEqualToString:@""]) {
            // nothing
        } else {
            completionScore++;
        }
    }
    
    if ([self.didTakeVaccine isEqualToString:@"NO"] && completionScore == 5) {
        self.submitButton.enabled = YES;
    } else if ([self.didTakeVaccine isEqualToString:@"YES"] && completionScore == 6) {
        self.submitButton.enabled = YES;
    } else {
        self.submitButton.enabled = NO;
    }
    NSLog(@"%@, %@, %@, %@, %@, %@, %@, %d", self.birthDate, self.age, self.didTakeVaccine, self.didTakeOtherVaccine, self.gender, self.school, self.vaccineTaken, completionScore);
}

- (BOOL)setCoreDataValues
{
    BOOL success;
    if (self.questionnaire != nil) {
        
        self.questionnaire.age = self.age;
        self.questionnaire.birthDate = self.birthDate;
        self.questionnaire.gender = self.gender;
        self.questionnaire.school = self.school;
        self.questionnaire.uniqueID = self.uniqueID;
        self.questionnaire.vaccineTaken = self.vaccineTaken;
        
        [self.questionnaire setDidTakeVaccine:self.didTakeVaccine];
        [self.questionnaire setDidTakeOtherVaccine:self.didTakeOtherVaccine]; // weird.
        //        self.questionnaire.didTakeVaccine = self.didTakeVaccine;
        //        self.questionnaire.didTakeOtherVaccine = self.didTakeOtherVaccine;
        
        self.questionnaire.submittedDateTime = self.submittedDateTime;
        
        NSLog(@"the age is: %ld",(long)self.age);
        NSLog(@"coreData is:%@",self.questionnaire.age);

        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){
            NSLog(@"Successfully saved the context.");
        } else {
            NSLog(@"Failed to save the context. Error = %@", savingError);
        }
    } else {
        NSLog(@"Failed to create the new questionnaire.");
    }
    success = YES;
    return success;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
