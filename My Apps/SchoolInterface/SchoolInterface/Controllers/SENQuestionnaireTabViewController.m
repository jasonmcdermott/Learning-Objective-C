//
//  SENiPadSettingsViewController.m
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENQuestionnaireTabViewController.h"

@interface SENQuestionnaireTabViewController ()

#pragma mark Variables
@property (strong, nonatomic) NSDate *birthDate;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *vaccineTakenToday;
@property (strong, nonatomic) NSString *otherVaccineTakenToday;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *uniqueID;
@property (strong, nonatomic) NSString *schoolName;

#pragma mark Interface Elements
@property (weak, nonatomic) IBOutlet UISwitch *showHideQuestionnaireSwitch;
@property (weak, nonatomic) IBOutlet UIView *questionnaireView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneTabBarButton;

#pragma mark Data Arrays
@property (strong, nonatomic) NSArray *questionnaireAges;
@property (strong, nonatomic) NSArray *questionnaireVaccines;
@property (strong, nonatomic) NSArray *questionnaireSchools;
@property (strong, nonatomic) NSArray *questionnaireBirthdayMonths;
@property (strong, nonatomic) NSArray *questionnaireBirthdayDays;

#pragma mark User Data Entry
@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *agePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *vaccinePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *otherVaccineControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (weak, nonatomic) IBOutlet UITextField *uniqueIDTextString;
@property (weak, nonatomic) IBOutlet UITextField *schoolTextString;

@end



@implementation SENQuestionnaireTabViewController


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
    self.questionnaireView.hidden = YES;
    self.questionnaireAges = @[@"10 years old", @"11 years old", @"12 years old", @"13 years old", @"14 years old", @"15 years old", @"16 years old", @"17 years old", @"18 years old"];
    self.questionnaireVaccines = @[@"None", @"Intra Muscular Injection", @"Blood Collection / Venipuncture", @"Intravenous Canula Injection", @"Other"];
    self.questionnaireSchools = @[@"Select One", @"Mt Carmel", @"St. Gregs", @"Cheltenham"];
    
    self.questionnaireBirthdayMonths = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    self.questionnaireBirthdayDays = @[@"31",@"29",@"31",@"30",@"31",@"30",@"31",@"31",@"30",@"31",@"30",@"31"];
    
    
    [_birthDatePicker addTarget:self
                   action:@selector(selectBirthDate:)
         forControlEvents:UIControlEventValueChanged];
    
    [self setPickerHeight:_vaccinePicker];
    [self setPickerHeight:_agePicker];

    
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
	CGFloat componentWidth = 0.0;
//    if ([pickerView isEqual:_birthdaySelector]) {
//        if (component == 0)
//            componentWidth = 240.0;	// first column size is wider to hold names
//        else
//            componentWidth = 40.0;	// second column is narrower to show numbers
//    } else {
        componentWidth = 200;
//    }
    return componentWidth;
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

//- (UIView *)pickerView:(UIPickerView *)pickerView
//            viewForRow:(NSInteger)row
//          forComponent:(NSInteger)component
//           reusingView:(UIView *)view
//{
//    
//    UILabel *pickerLabel = (UILabel *)view;
////    if (pickerLabel == nil) {
//        //label size
//        CGRect frame = CGRectMake(0.0, 0.0, 188, 20);
//        pickerLabel = [[UILabel alloc] initWithFrame:frame];
//        [pickerLabel setTextAlignment:NSTextAlignmentLeft];
//        [pickerLabel setBackgroundColor:[UIColor clearColor]];
//        //here you can play with fonts
//        [pickerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
////    }
//    if ([pickerView isEqual:_agePicker]) {
//        [pickerLabel setText:[self.questionnaireAges objectAtIndex:row]];
//    }
//    if ([pickerView isEqual:_vaccinePicker]) {
//        [pickerLabel setText:[self.questionnaireVaccines objectAtIndex:row]];
//    }
//    return pickerLabel;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//	if (pickerView == self.agePicker) {
//		self.ageSelected = [NSString stringWithFormat:@"%@", [self.questionnaireAges objectAtIndex:[pickerView selectedRowInComponent:0]]];
//	} else if (pickerView == self.procedurePicker) {
//        self.procedureSelected = [NSString stringWithFormat:@"%@", [self.questionnaireProcedures objectAtIndex:[pickerView selectedRowInComponent:0]]];
//        if ([self.procedureSelected isEqualToString:@"Other"]) {
//            self.showOtherProcedureType = YES;
//            [self.questionnaireOtherProcedureType becomeFirstResponder];
//            [self reLoadTableData];
//        } else {
//            self.showOtherProcedureType = NO;
//            [self reLoadTableData];
//        }
//    } else if (pickerView == self.locationPicker) {
//        self.procedureSelected = [NSString stringWithFormat:@"%@", [self.questionnaireLocations objectAtIndex:[pickerView selectedRowInComponent:0]]];
//        [self reLoadTableData];
//    }
    if (pickerView == self.agePicker) {
        _age = self.questionnaireAges[row];
    } else if (pickerView == self.vaccinePicker) {
        self.vaccineTakenToday = self.questionnaireVaccines[row];
    }
    [self checkCompleted];
}

- (void)checkCompleted
{
    NSLog(@"%@, %@, %@, %@, %@, %@, %@",_birthDate, _age, _vaccineTakenToday, _otherVaccineTakenToday, _gender, _uniqueID, _schoolName);
    if (_birthDate != nil && _age != nil && _vaccineTakenToday != nil && _otherVaccineTakenToday != nil && _gender != nil && _uniqueID != nil && _schoolName != nil) {
        self.doneButton.enabled = YES;
        self.doneTabBarButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
        self.doneTabBarButton.enabled = NO;
    }
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
//    if ([pickerView isEqual:_agePicker]) { // works, but not necessary just right now
//        return 2;
//    } else {
        return 1;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showHideQuestionnaire:(UISwitch *)sender {
    if (sender.isOn) {
        self.questionnaireView.hidden = NO;
    } else {
        self.questionnaireView.hidden = YES;
    }
}

#pragma mark -
#pragma mark UI Utilities

- (IBAction)textFieldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
    [self checkCompleted];
}

- (IBAction)otherVaccinesToday:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.otherVaccineTakenToday = @"No";
    } else {
        self.otherVaccineTakenToday = @"Yes";
    }
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
    [self checkCompleted];
}

- (IBAction)selectUniqueID:(UITextField *)sender {
    self.uniqueID = sender.text;
    [self checkCompleted];
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

@end
