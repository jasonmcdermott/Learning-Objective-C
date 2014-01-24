//
//  SENiPadSettingsViewController.m
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENQuestionnaireTabViewController.h"

/* 
I might want to implement this as a segue rather than a window that can be shown and hidden.
Might make creating, refreshing and what-not data points faster. 
Or perhaps not.
*/

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

#pragma mark -
#pragma mark Initialise

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
//    self.filePath = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:@"Sensorium"]];
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

#pragma mark -
#pragma mark UUID


- (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

#pragma mark -
#pragma mark PickerView

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
    [self resetValues];
    [self readCoreDataStore];
    NSLog(@"saved");
    [self uploadDataToURL];
    [self newQuestionnaire];
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
    [self.birthDatePicker setDate:[[NSDate alloc] init] animated:NO];
}

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


- (BOOL)setCoreDataValues
{
    BOOL success;
    if (self.questionnaire != nil) {
        
        self.questionnaire.age = self.age;
        self.questionnaire.birthDate = self.birthDate;
        self.questionnaire.gender = self.gender;
        self.questionnaire.school = self.school;
        self.questionnaire.uniqueID = self.uniqueID;
        if ([self.vaccineTaken isEqualToString:@"please select one"] || self.vaccineTaken == nil || [self.vaccineTaken isEqualToString:@""]) {
            self.questionnaire.vaccineTaken = @"none";
        } else {
            self.questionnaire.vaccineTaken = self.vaccineTaken;
        }
        
        self.questionnaire.didTakeOtherVaccine = self.didTakeOtherVaccine;
        self.questionnaire.didTakeVaccine = self.didTakeVaccine;
        
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
             NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

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

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    
    // for performing minor changes to the coredata database
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],
                             NSInferMappingModelAutomaticallyOption, nil];

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
          NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (void)readCoreDataStore
{
    /* Tell the request that we want to read the
     contents of the Person entity */
    /* Create the fetch request first */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"SENQuestionnaire"];
    NSError *requestError = nil;
    
    /* And execute the fetch request on the context */
    NSArray *questionnaires =
    [self.managedObjectContext executeFetchRequest:fetchRequest
                                             error:&requestError];
    
    /* Make sure we get the array */
    if ([questionnaires count] > 0){
        
        /* Go through the persons array one by one */
        NSUInteger counter = 1;
        for (SENQuestionnaire *q in questionnaires) {
            if ([q.writtenToDisk isEqualToString:@"YES"]){
                // do nothing
            } else {
                NSLog(@"%lu age = %@",(unsigned long)counter,q.age);
                NSLog(@"%lu birthDate = %@",(unsigned long)counter,q.birthDate);
                NSLog(@"%lu gender = %@",(unsigned long)counter,q.gender);
                NSLog(@"%lu school = %@",(unsigned long)counter,q.school);
                NSLog(@"%lu uniqueID = %@",(unsigned long)counter,q.uniqueID);
                NSLog(@"%lu vaccineTaken = %@",(unsigned long)counter,q.vaccineTaken);
                NSLog(@"%lu didTakeVaccine = %@",(unsigned long)counter,q.didTakeVaccine);
                NSLog(@"%lu didTakeOtherVaccine = %@",(unsigned long)counter,q.didTakeOtherVaccine);
                NSLog(@"%lu submittedDateTime = %@",(unsigned long)counter,q.submittedDateTime);
                
                [self writeDictionaryToDisk:q];
                q.writtenToDisk = @"YES";
                NSLog(@"logged");
            }
            counter++;
        }
    } else {
        NSLog(@"Could not find any Person entities in the context.");
    }
}

- (void)writeDictionaryToDisk:(SENQuestionnaire *)q
{
    NSDictionary *questionnaireDictionary =
    @{
      @"uniqueID" : q.uniqueID,
      @"age" : q.age,
      @"birthDate" : q.birthDate,
      @"didTakeOtherVaccine" : q.didTakeOtherVaccine,
      @"didTakeVaccine" : q.didTakeVaccine,
      @"vaccineTaken" : q.vaccineTaken,
      @"gender" : q.gender,
      @"school" : q.school,
      @"submittedDateTime" : q.submittedDateTime,
      };
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *doc = [basePath stringByAppendingString:@"/"];
    NSString *file = [doc stringByAppendingString:q.uniqueID];
    NSString *filePath = [file stringByAppendingString:@".plist"];
    
    // plistDict is a NSDictionary
    NSString *error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:questionnaireDictionary
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:filePath atomically:YES];
    } else {
        NSLog(@"%@",error);
    }
}


//-(NSString*)readXMLFile:(NSString *)file
//{
//    NSString *docFile = file;
    
//    NSFileManager *filemgr;
//    NSData *databuffer;
    
//    filemgr = [NSFileManager defaultManager];
    
//    databuffer = [filemgr contentsAtPath: docFile];
    
//    return [[NSString alloc] initWithData:databuffer encoding:NSUTF16StringEncoding];
//    NSString *a = @"";
//    return a;
//}


- (void)uploadDataToURL
{


    
    // working, sort of.
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *doc = [basePath stringByAppendingString:@"/"];
    NSString *fileName = [doc stringByAppendingString:@"2AED2573-9CB0-43B1-9649-F5196560D1A8"];
    NSString *file = [fileName stringByAppendingString:@".plist"];
    
    
    NSString *docFile = file;
    
    NSFileManager *filemgr;
    NSData *databuffer;

    filemgr = [NSFileManager defaultManager];

    databuffer = [filemgr contentsAtPath: docFile];

    NSString *text = [[NSString alloc] initWithData:databuffer encoding:NSUTF16StringEncoding];
//    return [[NSString alloc] initWithData:databuffer encoding:NSUTF16StringEncoding];

    
    
//    NSString *text = [self readXMLFile:file];
    

    NSMutableString* xml_text = [[NSMutableString alloc] initWithCapacity:0x1000000] ;
    [xml_text setString:text];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *params = @{@"uuid": @"2AED2573-9CB0-43B1-9649-F5196560D1A8",
                             @"datalog": text,
                             @"fieldSubject" : @"hello",
                             @"fieldDescription" :@"file upload",
                             @"fieldFormName" : @"12345678",
                             @"fieldFormEmail" : @"research@sensoriumhealth.com",
                             @"attachment" : file
                             ,};
    
    [manager POST:@"http://alpha.sensoriumhealth.com/attachment.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    ////////
    
    
    
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"wav"];
//    
//    // NSLog(@"filePath : %@", filePath);
//    
//    
//    
//    NSData *postData = [[NSData alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
//    
//    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
//    
//    NSLog(@"postLength : %@", postLength);
//    
//    
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    
//    [request setHTTPMethod:@"POST"];
//    
//    [request setURL:[NSURL URLWithString:@"http://exampleserver.com/upload.php"]];
//    
//    
//    
//    NSString *boundary = @"---------------------------14737809831466499882746641449";
//    
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
//    
//    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
//    
//    
//    
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    
//    
//    
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    
//    [request setHTTPBody:postData];
//    
//    [request setTimeoutInterval:30.0];
//    
//    
//    
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    
//    
//    
//    if (conn)
//        
//    {
//        
//        receivedData = [[NSMutableData data] retain];
//        
//    } else {
//        
//        NSLog(@"Connection Failed");
//        
//    }
//
//    
//    
//    NSMutableData *postData = [NSMutableData data];
//    NSString *header = [NSString stringWithFormat:@"--%@\r\n", boundary]
//    [postData appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    //add your filename entry
//    NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"filename", @"your file name"];
//    
//    [postData appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [postData appendData:[NSData dataWithContentsOfFile:@"your file path"];
//     NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
//     
//     [postData appendData:[endItemBoundary dataUsingEncoding:NSUTF8StringEncoding]];
//     [request setHTTPBody:postData];
    
    
  
}

- (void)convertDictionaryToJSON:(NSDictionary *)dict
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:dict
                        options:NSJSONWritingPrettyPrinted
                        error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        
        NSLog(@"Successfully serialized the dictionary into data.");
        NSString *jsonString =
        [[NSString alloc] initWithData:jsonData
                              encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String = %@", jsonString);
    }
    else if ([jsonData length] == 0 && error == nil){
        NSLog(@"No data was returned after serialization.");
    }
    else if (error != nil){
        NSLog(@"An error happened = %@", error);
    }
}

@end
