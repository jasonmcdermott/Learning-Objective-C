//
//  SENSettingsViewController.m
//  ResearchInterfaceDemo
//
//  Created by Jason McDermott on 14/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENSettingsViewController.h"

@interface SENSettingsViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) BOOL showOtherProcedureType;
@property (nonatomic) BOOL showQuestionnaire;

@property (weak, nonatomic) IBOutlet UISwitch *showQuestionnaireSwitch;
@property (weak, nonatomic) IBOutlet UIView *questionnaireView;
@property (weak, nonatomic) IBOutlet UIView *scanView;

@property (strong, nonatomic) NSArray *questionnaireAges;
@property (strong, nonatomic) NSArray *questionnaireProcedures;
@property (strong, nonatomic) NSArray *questionnaireLocations;

@property (weak, nonatomic) IBOutlet UIPickerView *agePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *locationPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *procedurePicker;

@property (strong, nonatomic) NSString *ageSelected;
@property (strong, nonatomic) NSString *locationSelected;
@property (strong, nonatomic) NSString *procedureSelected;

@property (weak, nonatomic) IBOutlet UITextField *questionnaireUniqueID;
@property (weak, nonatomic) IBOutlet UITextField *questionnaireOtherProcedureType;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanSpinner;

- (IBAction)textFieldReturn:(UITextField *)sender;

@end

@implementation SENSettingsViewController

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
    [self loadSettingsData];
}

- (void)loadSettingsData
{

    self.questionnaireAges = @[@"5 years old", @"6 years old", @"7 years old",@"8 years old", @"9 years old", @"10 years old", @"11 years old", @"12 years old", @"13 years old", @"14 years old", @"15 years old", @"16 years old", @"17 years old", @"18 years old"];
    self.questionnaireProcedures = @[@"Intra Muscular Injection", @"Blood Collection / Venipuncture", @"Intravenous Canula Injection", @"Other"];
    self.questionnaireLocations = @[@"Mt Carmel", @"St. Gregs", @"Cheltenham"];
    
    self.agePicker.delegate = self;
    self.agePicker.dataSource = self;
    
    self.showQuestionnaire = NO;
    [self updateViewLocations];
}


#pragma mark -
#pragma mark PickerView

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 24.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:_agePicker]) {
        return self.questionnaireAges.count;
    }
    else if ([pickerView isEqual:_procedurePicker]) {
        return self.questionnaireProcedures.count;
    }
    else if ([pickerView isEqual:_locationPicker]) {
        return self.questionnaireLocations.count;
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
    else if ([pickerView isEqual:_procedurePicker]) {
        return self.questionnaireProcedures[row];
    }
    else if ([pickerView isEqual:_locationPicker]) {
        return self.questionnaireLocations[row];
    } else {
        return nil;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    
    UILabel *pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        //label size
        CGRect frame = CGRectMake(0.0, 0.0, 188, 30);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentLeft];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        //here you can play with fonts
        [pickerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
    }
    if ([pickerView isEqual:_agePicker]) {
        [pickerLabel setText:[self.questionnaireAges objectAtIndex:row]];
    }
    if ([pickerView isEqual:_procedurePicker]) {
        [pickerLabel setText:[self.questionnaireProcedures objectAtIndex:row]];
    }
    if ([pickerView isEqual:_locationPicker]) {
        [pickerLabel setText:[self.questionnaireLocations objectAtIndex:row]];
    }
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == self.agePicker) {
		self.ageSelected = [NSString stringWithFormat:@"%@", [self.questionnaireAges objectAtIndex:[pickerView selectedRowInComponent:0]]];
	} else if (pickerView == self.procedurePicker) {
        self.procedureSelected = [NSString stringWithFormat:@"%@", [self.questionnaireProcedures objectAtIndex:[pickerView selectedRowInComponent:0]]];
        if ([self.procedureSelected isEqualToString:@"Other"]) {
            self.showOtherProcedureType = YES;
            [self.questionnaireOtherProcedureType becomeFirstResponder];
        } else {
            self.showOtherProcedureType = NO;
        }
    } else if (pickerView == self.locationPicker) {
        self.procedureSelected = [NSString stringWithFormat:@"%@", [self.questionnaireLocations objectAtIndex:[pickerView selectedRowInComponent:0]]];
    }
}

#pragma mark -
#pragma mark Interface Animation

- (IBAction)showHideQuestionnaire:(UISwitch *)sender {
    if (sender.isOn) {
        self.showQuestionnaire = YES;
        [self updateViewLocations];
    } else {
        self.showQuestionnaire = NO;
        [self updateViewLocations];
    }
}

- (void)updateViewLocations
{
    if (self.showQuestionnaire) {
        self.questionnaireView.hidden = NO;
        CGPoint position = self.scanView.center;
        position.y += self.questionnaireView.frame.size.height;
        [UIView beginAnimations:@"MoveUp" context:NULL];
        [UIView setAnimationDuration:0.5];
        self.scanView.center = position;
        [UIView commitAnimations];
    } else {
        self.questionnaireView.hidden = YES;
        CGPoint position = self.scanView.center;
        position.y -= self.questionnaireView.frame.size.height;
        [UIView beginAnimations:@"MoveUp" context:NULL];
        [UIView setAnimationDuration:0.5];
        self.scanView.center = position;
        [UIView commitAnimations];
    }
}

- (IBAction)textFieldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
}

@end
