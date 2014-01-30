//
//  RBLMainViewController.m
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import "BLEDevice.h"


unsigned char const OEM_RELIABLE = 0xA0;
unsigned char const OEM_UNRELIABLE = 0xA1;
unsigned char const OEM_PULSE = 0xB0;
unsigned char const SYNC_CHAR = 0xF9;
unsigned const NUM_PULSE_BYTES = 3;
unsigned const DEF_MAX_INACTIVITY = 8;
NSString * const  UUIDPrefKey = @"UUIDPrefKey";
NSString * const  INACTIVITY_KEY = @"BrightheartsInactivity";
NSString * const  USERNAME_KEY = @"BrightheartsUsername";


@interface BLEDevice()

@property (nonatomic) BOOL showTable;
@property (weak, nonatomic) IBOutlet UITableView *deviceList;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;



@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) NSMutableArray *tempDevices;
@end



@implementation BLEDevice

#pragma mark - Init

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

    
	// Do any additional setup after loading the view.
    NSLog(@"RBLMainViewController didLoad");
    self.passedToParent = NO;
    
    self.bleShield = [[BLE alloc] init];
    [self.bleShield controlSetup];
    self.bleShield.delegate = self;
    
    self.rfduinoManager = [RFduinoManager sharedRFduinoManager];
    self.rfduinoManager.delegate = self;
    
    self.mPDDRiver = [[SENPDDriver alloc] init];
    self.mSesionData = [[SENSessionData alloc] init];
    self.mDevices = [[NSMutableArray alloc] init];
    self.tempDevices = [[NSMutableArray alloc] init];
    

    _max_inactivity = DEF_MAX_INACTIVITY;
    
    self.knownDevices = @[@"722D74FC-0359-F949-C771-36C04647C7C2"];
    self.deviceAliases = @[@"Sensor X"];
    
    //Retrieve saved UUID from system
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    
    [self showButtons];
//    if (self.lastUUID.length > 0)
//    {
//        self.uuidLabel.text = self.lastUUID;
//        self.scanButton.hidden = true;
//    }
//    else
//    {
//        self.scanButton.hidden = false;
//        self.connectButton.hidden = true;
//    }
    [self sendUnsentSesions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mDevices.count;
    NSLog(@"%lu",(unsigned long)self.mDevices.count);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Available Devices";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"BLEDeviceList";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier forIndexPath:indexPath];
    
    for (int i=0;i<[self.knownDevices count];i++) {
        if ([[self.mDevices objectAtIndex:indexPath.row] isEqualToString:[self.knownDevices objectAtIndex:i]]){
            cell.textLabel.text = [self.deviceAliases objectAtIndex:i];
        } else {
//            cell.textLabel.text = @"New Sensor Device";
            cell.textLabel.text = [self.mDevices objectAtIndex:i]; // for the time being
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelected:indexPath.row];
    self.deviceList.hidden = YES;
}

#pragma mark - Interface Elements

- (IBAction)touchConnect:(UIButton *)sender {
    self.isFindingLast = YES;
    [self initiateScan];
}

- (IBAction)touchScan:(UIButton *)sender {
    self.isFindingLast = NO;
    [self initiateScan];
}

- (IBAction)touchDisconnect:(UIButton *)sender {
    if (self.bleShield.activePeripheral){
        if(self.bleShield.activePeripheral.state == CBPeripheralStateConnected) [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
    }
    if (self.connected_rfduino != NULL) {
        [self.connected_rfduino disconnect];
        self.connected_rfduino = NULL;
    }
    [self showButtons];
}

- (void)initiateScan
{
    [self disconnectPeripheralsBeforeScanning];
    [self.bleShield findBLEPeripherals:3];
    [self.rfduinoManager startScan];
    [NSTimer scheduledTimerWithTimeInterval:(float)4.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    [self showButtons];
}

- (void)didSelected:(NSInteger)index
{
//    self.scanButton.hidden = true;
    // need to add in logic for picking BLEMini or RFDuino
    
    for (id device in self.mDeviceDictionary) {
        NSNumber *originalArrayIndex = [self.mDeviceDictionary objectForKey:@"originalArrayIndex"];
        NSNumber *aggregatedArrayIndex = [self.mDeviceDictionary objectForKey:@"aggregatedArrayIndex"];
        NSString *deviceType = [self.mDeviceDictionary objectForKey:@"deviceType"];
        
        if (index == [aggregatedArrayIndex integerValue]) {
            if ([deviceType isEqualToString:@"BLEMini"]) {
                [self.bleShield connectPeripheral:[self.bleShield.peripherals objectAtIndex:[originalArrayIndex integerValue]]];
            } else if ([deviceType isEqualToString:@"RFDuino"]) {
                RFduino *rfduino = [[self.rfduinoManager rfduinos] objectAtIndex:[originalArrayIndex integerValue]];
                if (!rfduino.outOfRange) {
                    [self.rfduinoManager connectRFduino:rfduino];
                }
            }
        }
    }
}

//-(void) displaySesionStart
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"HH:mm:ss"];
//    [formatter setTimeZone:[NSTimeZone localTimeZone]];
//    
//    NSString *stringFromDate = [formatter stringFromDate:self.mSesionData.mSesionStart];
//    [self.sessionStartLabel setText:stringFromDate];
//}

- (void)hideAll
{
    NSLog(@"hiding");
    self.view.hidden = YES;
}

- (IBAction)touchCloseButton:(UIButton *)sender
{
    [self hideAll];
    [self.delegate startGLView];
}

#pragma mark - Bluetooth Periphery

- (void)disconnectPeripheralsBeforeScanning
{
    // check if we have BLEShield active. If we do, and it's connected, disconnect it.
    if (self.bleShield.activePeripheral) {
        if (self.bleShield.activePeripheral.state == CBPeripheralStateConnected) {
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
            return;
        }
    }
    // reset list of peripherals. we're starting a new scan
    if (self.bleShield.peripherals) self.bleShield.peripherals = nil;
    
    // check if we have a connect RFDuino
    if (self.connected_rfduino != NULL) {
        [self.connected_rfduino disconnect];
        self.connected_rfduino = NULL;
        //        return; // do we need this?
    }
}

// Called when scan period is over 
-(void)connectionTimer:(NSTimer *)timer
{
    [self.mDevices removeAllObjects];
    self.mDeviceDictionary = [[NSMutableDictionary alloc] init];
    
    self.finishedScan = NO;
    self.scanning = YES;
    self.connected = NO;
    
    if(self.bleShield.peripherals.count > 0) {

        //to connect to last known peripheral
        if(self.isFindingLast) {
            
            // check last UUID against all BLEMini device UUIDs found
            for (int i = 0; i < self.bleShield.peripherals.count; i++) {
                CBPeripheral *p = [self.bleShield.peripherals objectAtIndex:i];
                if (p.identifier != NULL) {
                    // Compare UUIDs and call connectPeripheral if matched
                    if([self.lastUUID isEqualToString:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)]]) {
                        [self.bleShield connectPeripheral:p];
                    }
                }
            }
            
            // also check last UUID against all rfduino device UUIDs found
            for(int i = 0; i < [[self.rfduinoManager rfduinos] count]; i++) {
                RFduino *rfduino = [self.rfduinoManager.rfduinos objectAtIndex:i];
                if([self.lastUUID isEqualToString:rfduino.UUID]) {
                    RFduino *rfduino = [[self.rfduinoManager rfduinos] objectAtIndex:i];
                    if (!rfduino.outOfRange) {
                        [self.rfduinoManager connectRFduino:rfduino];
                        [self.spinner stopAnimating];
                    }
                }
            }

        // We're scanning for new devices now
        } else {
            int counter = 0;
            for (int i = 0; i < self.bleShield.peripherals.count; i++) {
                CBPeripheral *p = [self.bleShield.peripherals objectAtIndex:i];
                counter++;
                if (p.identifier != NULL) { // is this even necessary?
                    [self.mDeviceDictionary setObject:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)] forKey:@"UUID"];
                    [self.mDeviceDictionary setObject:@"BLEMini" forKey:@"deviceType"];
                    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
                    
                    [self.mDevices addObject:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)]];
                } else {
                    [self.mDeviceDictionary setObject:@"NULL" forKey:@"UUID"];
                    [self.mDeviceDictionary setObject:@"BLEMini" forKey:@"deviceType"];
                    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
                    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
                    
                    [self.mDevices addObject:@"NULL"];
                }
            }
            
            for (int i = 0; i < [[self.rfduinoManager rfduinos] count]; i++) {
                counter++;
                RFduino *rfduino = [self.rfduinoManager.rfduinos objectAtIndex:i];
                
                [self.mDeviceDictionary setObject:rfduino.UUID forKey:@"UUID"];
                [self.mDeviceDictionary setObject:@"RFDuino" forKey:@"deviceType"];
                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
                
                [self.mDevices addObject:rfduino.UUID];
                [self.mDeviceTypes addObject:@"RFDuino"];
            }
            
            //Show the list for user selection
//            [self.spinner stopAnimating];
//            _showTable = YES;
//            self.deviceList.hidden = NO;
            [self.deviceList reloadData];
        }
    }
    
    self.finishedScan = YES;
    self.scanning = NO;
    [self showButtons];
    
}

- (void)showButtons
{
    if (self.scanning == NO && self.connected == NO && self.finishedScan == NO) {
        if (self.lastUUID.length > 0) {
            self.uuidLabel.text = self.lastUUID;
            self.scanButton.enabled = YES;
            self.connectButton.enabled = YES;
        } else {
            self.scanButton.enabled = NO;
            self.connectButton.enabled = NO;
            self.disconnectButton.enabled = NO;
        }
//        self.connectButton.enabled = NO;
//        self.scanButton.enabled = YES;
//        self.disconnectButton.enabled = YES;
        self.deviceList.hidden = YES;
        [self.spinner stopAnimating];
        
    } else if (self.scanning == YES && self.connected == NO && self.finishedScan == NO) {
        self.connectButton.enabled = NO;
        self.scanButton.enabled = NO;
        self.disconnectButton.enabled = NO;
        self.deviceList.hidden = YES;
        [self.spinner startAnimating];
        
    } else if (self.scanning == NO && self.connected == NO && self.finishedScan == YES) {
        if (self.disconnected == YES) {
            self.deviceList.hidden = YES;
            self.connectButton.enabled = YES;
        } else {
            self.deviceList.hidden = NO;
            self.connectButton.enabled = NO;
        }
        self.scanButton.enabled = YES;
        self.disconnectButton.enabled = NO;
        [self.spinner stopAnimating];
        
    } else if (self.scanning == NO && self.connected == YES && self.finishedScan == NO) {
        self.connectButton.enabled = NO;
        self.scanButton.enabled = NO;
        self.disconnectButton.enabled = NO;
        self.deviceList.hidden = YES;
        [self.spinner stopAnimating];
        
    } else if (self.scanning == NO && self.connected == YES && self.finishedScan == YES) {
        self.connectButton.enabled = NO;
        self.scanButton.enabled = NO;
        self.disconnectButton.enabled = YES;
        self.deviceList.hidden = YES;
        [self.spinner stopAnimating];
        
    } else {
        NSLog(@"what should I do?");
        // figure out what to do.
    }
    NSLog(@"%hhd %hhd %hhd",self.scanning, self.connected, self.finishedScan);
}

// Merge two bytes to integer value
unsigned int mergeBytes (unsigned char lsb, unsigned char msb)
{
    unsigned int ret = msb & 0xFF;
    ret = ret << 7;
    ret = ret + lsb;
    return ret;
}

// we received data from BLE - process it
-(void)bleDidReceiveData:(unsigned char *)data length:(int)length
{
    [self processBluetoothData:data length:length];
}


-(void)processBluetoothData:(unsigned char *)data length:(int)length
{
//    if (self.passedToParent == NO) {
    for (int i = 0; i < length && _bufferIndex < 4; i++) {
        unsigned char b = data[i];
        
        // we will force resynchronisation
        if (b == OEM_PULSE || b == SYNC_CHAR || b == OEM_RELIABLE || b == OEM_UNRELIABLE) _bufferIndex = 0;
        
        _oemBuffer.data[_bufferIndex] = b;
        _bufferIndex++;
        
        switch (_oemBuffer.data[0]) {
            case OEM_PULSE:
                if (_bufferIndex == NUM_PULSE_BYTES) {
                    unsigned char lsb = _oemBuffer.data[1];
                    unsigned char msb = _oemBuffer.data[2];
                    
                    unsigned interval = mergeBytes(lsb, msb);
                    
                    
                    if (!_started) {
                        [self.mSesionData clearSesionLists];
                        [self.mSesionData setStartSesion];
                        self.mSesionData.mUsername = self.username;
                        self.mSesionData.mDeviceID = self.lastUUID;
                        
//                        [self displaySesionStart];
                        
//                        self.sessionStatusLabel.text = @"Sesion Started";
                        _started = true;
                        
                        [self.mPDDRiver startSession];
                        self.generateButton.hidden = true;
                    }

                    [self.delegate setLabel:[NSString stringWithFormat:@"Interval %d", interval]];
                    NSLog(@"%u",interval);

                    [self.mPDDRiver sendIBI:interval];
                    _bufferIndex = 0;
                    _inactivityCount = 0;
                    
                    [self.mSesionData addIbi:interval];
                }
                
                break;
                
            case SYNC_CHAR:
                _bufferIndex = 0;
                
                
                break;
                
            case OEM_RELIABLE:
                _bufferIndex = 0;
                _reliable = true;
                
                [self.mPDDRiver sendtoPDBaseReliability:1];
                self.sessionStatusLabel.text = @"Reliable";
                _inactivityCount = 0;
                
                [self.mSesionData addReliability:true];
                
                break;
                
            case OEM_UNRELIABLE:
                _bufferIndex = 0;
                _reliable = false;
                
                [self.mPDDRiver sendtoPDBaseReliability:0];
                self.sessionStatusLabel.text = @"Unreliable";
                _inactivityCount = 0;
                
                [self.mSesionData addReliability:false];
                
                
                break;
                
            default:
                _bufferIndex = 0; // we are not going to accept other values
                break;
        }
    }
    _inactivityCount++;
    
    if (_inactivityCount >= _max_inactivity) {
        self.intervalLabel.text = @"";
        self.sessionStatusLabel.text = @"session Ended";
        if (_started) {
            _started = false;
            [self.mPDDRiver endSession];
            
            [self.mSesionData setSessionEnd];
            self.sessionStatusLabel.text = @"Uploaded";
            
//            XMLDataGenerator* xml = [[XMLDataGenerator alloc]init];
//            NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
            
//            [xml generateXML:self.mSesionData filename: [NSString stringWithFormat:@"%@.xml", uuid]];
//            [xml release];
        }
    }
//    }
}


- (void)bleDidDisconnect
{
    self.connected = NO;
    self.disconnected = YES;
    [self showButtons];
}

-(void)bleDidConnect
{
    //Save UUID into system
    self.lastUUID = [SENUtilities getUUIDString:CFBridgingRetain(self.bleShield.activePeripheral.identifier)];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.connected = YES;
    [self showButtons];
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
}


#pragma mark - RFDUINO

//-(void)connectLastServiceRfduino
//{
//    int value = [[self.rfduinoManager rfduinos] count];
//    for(int i = 0; i < value; i++)
//    {
//        RFduino *rfduino = [self.rfduinoManager.rfduinos objectAtIndex:i];
//        NSString *text = [[NSString alloc] initWithFormat:@"%@", rfduino.name];
//        
//        NSString *uuid = rfduino.UUID;
//        if([self.lastUUID isEqualToString:uuid]) {
////            [self didSelectRFDuino:i];
//        }
//        
//    }
//}

//-(void)didSelectRFDuino:(NSInteger)index
//{
//    RFduino *rfduino = [[self.rfduinoManager rfduinos] objectAtIndex:index];
//    
//    if (!rfduino.outOfRange) {
//        [self.rfduinoManager connectRFduino:rfduino];
//    }
//}

- (void)didDiscoverRFduino:(RFduino *)rfduino
{
    NSLog(@"didDiscoverRFduino");
}

- (void)didUpdateDiscoveredRFduino:(RFduino *)rfduino
{
    if (self.connected_rfduino != NULL) return;
    
//    NSLog(@"didUpdateRFduino");
//    int numberOfRFDuiunos = [[self.rfduinoManager rfduinos] count];
    
//    for(int i = 0; i < numberOfRFDuiunos; i++) {
//        RFduino *rfduino = [self.rfduinoManager.rfduinos objectAtIndex:i];

        
//        NSString *uuid = rfduino.UUID;
//        NSString *text = [[NSString alloc] initWithFormat:@"%@", rfduino.name]; // it has a name?
//        int rssi = rfduino.advertisementRSSI.intValue;
        
//        NSString *advertising = @"";
//        if (rfduino.advertisementData) {
//            advertising = [[NSString alloc] initWithData:rfduino.advertisementData encoding:NSUTF8StringEncoding];
//        }
//        [self.mDevices addObject:uuid];
//        [self.mDeviceTypes addObject:@"RFDuino"];
//    }
}

- (void)didConnectRFduino:(RFduino *)rfduino
{
    NSLog(@"didConnectRFduino");
    
    self.connected_rfduino = rfduino;
    
    [self.rfduinoManager stopScan];
    [self.connected_rfduino setDelegate:self];
    NSString *uuid = rfduino.UUID;
    
    self.lastUUID = uuid;
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.uuidLabel.text = self.lastUUID;
//    self.sessionStatusLabel.text = @"Device Connected";
//    [self.scanButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    self.connected = YES;
    [self showButtons];
    
    //loadService = false;
}

- (void)didLoadServiceRFduino:(RFduino *)rfduino
{
    //AppViewController *viewController = [[AppViewController alloc] init];
    //viewController.rfduino = rfduino;
    
    //loadService = true;
    //[[self navigationController] pushViewController:viewController animated:YES];
}

- (void)didDisconnectRFduino:(RFduino *)rfduino
{
    self.connected_rfduino = NULL;
    NSLog(@"didDisconnectRFduino");
    self.connected = NO;
    self.disconnected = YES;
    [self showButtons];
    
    /*
     if (loadService) {
     [[self navigationController] popViewControllerAnimated:YES];
     }
     */
//    self.intervalLabel.text = @"";
//    [self displayLastButton];
    //self.rssiLabel.hidden = true;
    //self.rssiLabel.text = @"";
//    self.sessionStatusLabel.text = @"Disconected";
//    [self.scanButton setTitle:@"Scan All" forState:UIControlStateNormal];
    
//    [rfduinoManager startScan];
    //[self.tableView reloadData];
}

- (void)didReceive:(NSData *)data
{
    NSLog(@"RecievedData");
    unsigned char *value = [data bytes];
    int length = [data length];
    [self processBluetoothData:value length:length];
}

#pragma mark -
#pragma mark XML

-(void) sendUnsentSesions
{
//    SENXmlDataGenerator* xmlDataGenerator = [[SENXmlDataGenerator alloc]init];
//    [xmlDataGenerator sendUnsentSesions];
}

@end
