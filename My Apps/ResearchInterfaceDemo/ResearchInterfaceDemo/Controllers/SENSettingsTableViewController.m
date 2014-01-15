//
//  StaticTableViewController.m
//  StaticTableViewDemo
//
//  Created by Marty Dill on 12-02-28.
//  Copyright (c) 2012 Marty Dill. All rights reserved.
//

#import "SENSettingsTableViewController.h"
#import "SENBluetoothConnectionViewController.h"

@interface SENSettingsTableViewController()

@property (nonatomic) BOOL showQuestionnaireTableSection;
@property (nonatomic) BOOL showOtherProcedureType;
@property (nonatomic) BOOL previousDeviceUUIDInMemory;
@property (nonatomic) BOOL connectedToBLEDevice;

@property (strong, nonatomic) NSString *ageSelected;
@property (strong, nonatomic) NSString *locationSelected;
@property (strong, nonatomic) NSString *procedureSelected;

@property (strong, nonatomic) NSArray *questionnaireAges;
@property (strong, nonatomic) NSArray *questionnaireProcedures;
@property (strong, nonatomic) NSArray *questionnaireLocations;

@property (weak, nonatomic) IBOutlet UIPickerView *agePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *locationPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *procedurePicker;

@property (weak, nonatomic) IBOutlet UISwitch *showQuestionnaire;

@property (weak, nonatomic) IBOutlet UILabel *previousDeviceLabel;

@property (weak, nonatomic) IBOutlet UITextField *questionnaireUniqueID;
@property (weak, nonatomic) IBOutlet UITextField *questionnaireOtherProcedureType;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanSpinner;

@property (weak, nonatomic) IBOutlet UIButton *scanForDevices;
@property (weak, nonatomic) IBOutlet UIButton *connectToPreviousDevice;


- (IBAction)textFieldReturn:(UITextField *)sender;

@end

NSString * const  UUIDPrefKey = @"UUIDPrefKey";

@implementation SENSettingsTableViewController

@synthesize showQuestionnaireTableSection;
@synthesize showOtherProcedureType;
@synthesize previousDeviceUUIDInMemory;
@synthesize connectedToBLEDevice;

#pragma mark -
#pragma mark Initialise

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeComponents];
    [self loadSettingsData];
}

- (void)initializeComponents
{
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
}

- (void)reLoadTableData
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark DataSource

- (void)loadSettingsData
{
    self.questionnaireAges = @[@"5 years old", @"6 years old", @"7 years old",@"8 years old", @"9 years old", @"10 years old", @"11 years old", @"12 years old", @"13 years old", @"14 years old", @"15 years old", @"16 years old", @"17 years old", @"18 years old"];
    self.questionnaireProcedures = @[@"Intra Muscular Injection", @"Blood Collection / Venipuncture", @"Intravenous Canula Injection", @"Other"];
    self.questionnaireLocations = @[@"Mt Carmel", @"St. Gregs", @"Cheltenham"];
    
    //Retrieve saved UUID from system
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    
    if (self.lastUUID.length > 0) {
        self.previousDeviceLabel.text = self.lastUUID;
    } else {
        previousDeviceUUIDInMemory = NO;
    }
    
    self.mDevices = [[NSMutableArray alloc] init];
    
}

#pragma mark -
#pragma mark TableViewSettings

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

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
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
        if (previousDeviceUUIDInMemory) {
            return 2;
        } else if (connectedToBLEDevice) {
            return 0;
        } else {
            return 1;
        }
    }
}

#pragma mark -
#pragma mark PickerView

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:_agePicker]) {
        return self.questionnaireAges.count;
    }
    else if ([pickerView isEqual:_procedurePicker]) {
        return self.questionnaireProcedures.count;
        NSLog(@"%d",self.questionnaireProcedures.count);
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
            [self reLoadTableData];
        } else {
            self.showOtherProcedureType = NO;
            [self reLoadTableData];
        }
    } else if (pickerView == self.locationPicker) {
        self.procedureSelected = [NSString stringWithFormat:@"%@", [self.questionnaireLocations objectAtIndex:[pickerView selectedRowInComponent:0]]];
        [self reLoadTableData];
    }
}

#pragma mark -
#pragma mark Interface
- (IBAction)showQuestionnaire:(UISwitch *)sender {
    
    if (sender.isOn == 1) {
        showQuestionnaireTableSection = YES;
    } else {
        showQuestionnaireTableSection = NO;
    }
    [self reLoadTableData];
}

- (IBAction)textFieldReturn:(UITextField *)sender {
    [sender resignFirstResponder];
}


#pragma mark -
#pragma mark BluetoothInterface

- (IBAction)scanForDevices:(id)sender
{
    if (bleShield.activePeripheral)
    {
        if(bleShield.activePeripheral.isConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    }
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    isFindingLast = false;
//    self.lastButton.hidden = true;
//    self.scanButton.hidden = true;
    [self.scanSpinner startAnimating];
}

- (IBAction)connectToPreviousDevice:(UIButton *)sender
{
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    isFindingLast = true;
//    self.lastButton.hidden = true;
//    self.scanButton.hidden = true;
    [self.scanSpinner startAnimating];
}

// Called when scan period is over
-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        //to connect to the peripheral with a particular UUID
        if(isFindingLast)
        {
            int i;
            for (i = 0; i < bleShield.peripherals.count; i++)
            {
                CBPeripheral *p = [bleShield.peripherals objectAtIndex:i];
                
                if (p.UUID != NULL)
                {
                    //Comparing UUIDs and call connectPeripheral is matched
                    if([self.lastUUID isEqualToString:[self getUUIDString:p.UUID]])
                    {
                        [bleShield connectPeripheral:p];
                    }
                }
            }
        }
        //Scan for all BLE in range and prepare a list
        else
        {
            [self.mDevices removeAllObjects];
            
            int i;
            for (i = 0; i < bleShield.peripherals.count; i++)
            {
                CBPeripheral *p = [bleShield.peripherals objectAtIndex:i];
                
                if (p.UUID != NULL)
                {
                    [self.mDevices insertObject:[self getUUIDString:p.UUID] atIndex:i];
                }
                else
                {
                    [self.mDevices insertObject:@"NULL" atIndex:i];
                }
            }
            
            //Show the list for user selection
            [self performSegueWithIdentifier:@"showDevice" sender:self];
        }
    }
    else
    {
        [self.scanSpinner stopAnimating];
        
        if (self.lastUUID.length == 0) {
//            self.lastButton.hidden = true;
        } else {
//            self.lastButton.hidden = false;
        }
//        self.scanButton.hidden = false;
    }
}

//Show device list for user selection
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDevice"])
    {
        SENBluetoothConnectionViewController *vc = [segue destinationViewController];
        vc.BLEDevices = self.mDevices;
        vc.delegate = self;
    }
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    
}

- (void) bleDidDisconnect
{
//    self.lastButton.hidden = false;
//    self.rssiLabel.hidden = true;
    [self.scanForDevices setTitle:@"Scan For Devices" forState:UIControlStateNormal];
}

-(void)bleDidConnect
{
    //Save UUID into system
    self.lastUUID = [self getUUIDString:bleShield.activePeripheral.UUID];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.scanSpinner stopAnimating];
//    self.lastButton.hidden = true;
//    self.scanButton.hidden = false;
    self.previousDeviceLabel.text = self.lastUUID;
//    self.rssiLabel.text = @"RSSI: ?";
//    self.rssiLabel.hidden = false;
    [self.scanForDevices setTitle:@"Disconnect" forState:UIControlStateNormal];
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
}

-(NSString*)getUUIDString:(CFUUIDRef)ref
{
    NSString *str = [NSString stringWithFormat:@"%@",ref];
    return [[NSString stringWithFormat:@"%@",str] substringWithRange:NSMakeRange(str.length - 36, 36)];
}

- (void)didSelected:(NSInteger)index
{
    [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:index]];
}

@end
