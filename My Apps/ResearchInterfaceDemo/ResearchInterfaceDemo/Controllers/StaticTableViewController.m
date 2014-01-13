//
//  StaticTableViewController.m
//  StaticTableViewDemo
//
//  Created by Marty Dill on 12-02-28.
//  Copyright (c) 2012 Marty Dill. All rights reserved.
//

#import "StaticTableViewController.h"
#import "SENBluetoothConnectionViewController.h"

@interface StaticTableViewController()
@property (weak, nonatomic) IBOutlet UISwitch *doSomethingSwitch;
@property (nonatomic) BOOL showQuestionnaireTableSection;
@property (nonatomic) BOOL showOtherProcedureType;

@property (weak, nonatomic) IBOutlet UIPickerView *agePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *procedurePicker;
@property (strong, nonatomic) NSString *ageSelected;
@property (strong, nonatomic) NSString *procedureSelected;

@property (strong, nonatomic) NSArray *questionnaireAges;
@property (strong, nonatomic) NSArray *questionnaireProcedures;

@property (weak, nonatomic) IBOutlet UITextField *questionnaireUniqueID;
@property (weak, nonatomic) IBOutlet UITextField *questionnaireLocation;
@property (weak, nonatomic) IBOutlet UITextField *questionnaireOtherProcedureType;
- (IBAction)textFieldReturn:(UITextField *)sender;

@end
@implementation StaticTableViewController

@synthesize showQuestionnaireTableSection;
@synthesize showOtherProcedureType;

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1 && !showQuestionnaireTableSection) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1 && !showQuestionnaireTableSection) {
        return 1;
    }
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1 && !showQuestionnaireTableSection){
        return 1;
    }
    return 16;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1 && showQuestionnaireTableSection){
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSInteger sectionID = section;
    if(section == 1) {
        if(!showQuestionnaireTableSection) {
            return 0;
        } else {
            if (showOtherProcedureType) {
                return 5;
            } else {
                return 4;
            }
        }
    } else if (section == 0) {
        return 1;
    } else {
//        return [tableView numberOfRowsInSection:3]; // doesn't like this, for some reason
        return 3;
    }
}

- (IBAction)doSomethingSwitch:(UISwitch *)sender {
    if (sender.isOn == 1) {
        showQuestionnaireTableSection = YES;
    } else {
        showQuestionnaireTableSection = NO;
    }
    [self reLoadTableData];
}

- (void)reLoadTableData
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadSettingsData];
}

#pragma mark -
#pragma mark PickerView DataSource

- (void)loadSettingsData
{
    self.questionnaireAges = @[@"5", @"6", @"7",@"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18"];
    self.questionnaireProcedures = @[@"something", @"something else", @"Other"];
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:_agePicker]) {
        return self.questionnaireAges.count;
    } else if ([pickerView isEqual:_procedurePicker]) {
        return self.questionnaireProcedures.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if ([pickerView isEqual:_agePicker]) {
        return self.questionnaireAges[row];
    } else if ([pickerView isEqual:_procedurePicker]) {
        return self.questionnaireProcedures[row];
    }
    return nil;
}

#pragma mark -
#pragma mark PicerView InterfaceDetails


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
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        //here you can play with fonts
        [pickerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
    }
    if ([pickerView isEqual:_agePicker]) {
//        return self.questionnaireAges[row];
        [pickerLabel setText:[self.questionnaireAges objectAtIndex:row]];
    } else if ([pickerView isEqual:_procedurePicker]) {
//        return self.questionnaireProcedures[row];
        [pickerLabel setText:[self.questionnaireProcedures objectAtIndex:row]];
    }
    return pickerLabel;
}

#pragma mark -
#pragma mark PickerView Delegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == self.agePicker)	// don't show selection for the custom picker
	{
		// report the selection to the UI label
		self.ageSelected = [NSString stringWithFormat:@"%@", [self.questionnaireAges objectAtIndex:[pickerView selectedRowInComponent:0]]];
//        NSLog(@"%@",self.ageSelected);
	} else if (pickerView == self.procedurePicker) {
        self.procedureSelected = [NSString stringWithFormat:@"%@", [self.questionnaireProcedures objectAtIndex:[pickerView selectedRowInComponent:0]]];
        if ([self.procedureSelected isEqualToString:@"Other"]) {
            self.showOtherProcedureType = YES;
            [self reLoadTableData];
        } else {
            self.showOtherProcedureType = NO;
            [self reLoadTableData];
        }
    }
}

#pragma mark -
#pragma mark Navigation Interface 

- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    SENBluetoothConnectionViewController *source = [segue sourceViewController];
//    SENToDoItem *item = source.toDoItem;
//    if (item != nil) {
//        [self.toDoItems addObject:item];
//        [self.tableView reloadData];
//    }
}

- (IBAction)textFieldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
}
@end
