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
@property (weak, nonatomic) IBOutlet UISwitch *showHideQuestionnaireSwitch;
@property (weak, nonatomic) IBOutlet UIView *questionnaireView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

#pragma mark User Data Entry
@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *agePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *vaccinePicker;
@property (weak, nonatomic) IBOutlet UILabel *hpvVaccineLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *vaccineQuestion;
@property (weak, nonatomic) IBOutlet UISegmentedControl *otherVaccineQuestion;

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (weak, nonatomic) IBOutlet UITextField *schoolTextString;

@end

@implementation SENQuestionnaireTabViewController

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
    
    self.date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    self.dateTimeLabel.text = [dateFormatter stringFromDate:self.date];
    
    self.submitButton.enabled = NO;
    self.schoolName = @"";
    self.schoolTextString.text = [self getStringForKey:@"schoolName"];

    self.questionnaireAges = @[@"10 years old", @"11 years old", @"12 years old", @"13 years old", @"14 years old", @"15 years old", @"16 years old", @"17 years old", @"18 years old"];
    self.questionnaireVaccines = @[@"please select one", @"my 1st vaccine", @"my 2nd vaccine", @"my 3rd vaccine"];
    
    self.questionnaireBirthdayMonths = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    self.questionnaireBirthdayDays = @[@"31",@"29",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    
    _uniqueID = [self GetUUID];
    _uuidLabel.text = _uniqueID;
    
    [_birthDatePicker addTarget:self
                   action:@selector(selectBirthDate:)
         forControlEvents:UIControlEventValueChanged];
    
    
    
    [self.genderControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self.vaccineQuestion setSelectedSegmentIndex:UISegmentedControlNoSegment];
    [self.otherVaccineQuestion setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    [self setPickerHeight:_vaccinePicker];
    [self setPickerHeight:_agePicker];
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

#pragma mark -
#pragma mark PickerView

- (void)setPickerHeight:(UIPickerView *)pickerView
{
    pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    CGSize ps = [pickerView sizeThatFits: CGSizeZero];
    pickerView.frame = CGRectMake(0.0, 0.0, ps.width, 162.0);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 200.0;
}


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
    if (pickerView == self.agePicker) {
        _age = self.questionnaireAges[row];
    } else if (pickerView == self.vaccinePicker) {
        self.whichVaccineTakenToday = self.questionnaireVaccines[row];
    }
    [self checkCompleted];
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}


#pragma mark Submit Logic
#pragma mark -

- (void)checkCompleted
{
    float completionScore = 0;
    
    if (_gender != nil) completionScore++;
    if (_birthDate != nil) completionScore++;
    if (_vaccineTakenTodayAnswer != nil) completionScore++;
    if (_otherVaccineTakenTodayAnswer != nil) completionScore++;
    if ([_vaccineTakenTodayAnswer isEqualToString:@"Yes"] && ![_whichVaccineTakenToday isEqualToString:@"please select one"]) completionScore++;
    if (![self.schoolTextString.text isEqualToString:@""]) completionScore++;

    if ([_vaccineTakenTodayAnswer isEqualToString:@"No"] && completionScore == 5) {
        self.submitButton.enabled = YES;
    } else if ([_vaccineTakenTodayAnswer isEqualToString:@"Yes"] && completionScore == 6) {
        self.submitButton.enabled = YES;
    } else {
        self.submitButton.enabled = NO;
    }
//    NSLog(@"%@, %@, %@, %@, %@, %@, %@",_birthDate, _age, _vaccineTakenTodayAnswer, _otherVaccineTakenTodayAnswer, _gender, _schoolName, _whichVaccineTakenToday);
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
    self.schoolName = sender.text;
    [self setStringForKey:sender.text withKey:@"schoolName"];
    [self checkCompleted];
}

- (IBAction)selectUniqueID:(UITextField *)sender {
    self.uniqueID = sender.text;
    [self checkCompleted];
}

- (IBAction)answerVaccineQuestion:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.vaccineTakenTodayAnswer = @"No";
        self.hpvVaccineLabel.hidden = YES;
        self.vaccinePicker.hidden = YES;
    } else {
        self.vaccineTakenTodayAnswer = @"Yes";
        self.hpvVaccineLabel.hidden = NO;
        self.vaccinePicker.hidden = NO;
    }
    [self checkCompleted];
}

- (IBAction)answerOtherVaccineQuestion:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.otherVaccineTakenTodayAnswer = @"No";
    } else {
        self.otherVaccineTakenTodayAnswer = @"Yes";
    }
    [self checkCompleted];
}


- (void)hideAll
{
    NSLog(@"hiding");
    self.view.hidden = YES;
}

- (IBAction)touchSubmitButton:(UIButton *)sender
{
    // create XML file. save and send.
    [self hideAll];
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
    self.age = self.questionnaireAges[age-10];
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

@end
