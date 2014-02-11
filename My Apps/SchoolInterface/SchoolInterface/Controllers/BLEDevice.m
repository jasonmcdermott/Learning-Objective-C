//
//  RBLMainViewController.m
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import "BLEDevice.h"

NSString * const UUIDPrefKey = @"UUIDPrefKey";
NSString * const NamePrefKey = @"NamePrefKey";
NSString * const  INACTIVITY_KEY = @"BrightheartsInactivity";
NSString * const  USERNAME_KEY = @"BrightheartsUsername";

unsigned char const OEM_RELIABLE = 0xA0;
unsigned char const OEM_UNRELIABLE = 0xA1;
unsigned char const OEM_PULSE = 0xB0;
unsigned char const SYNC_CHAR = 0xF9;

@interface BLEDevice()

@property (weak, nonatomic) IBOutlet UILabel *statusMessage;
@property (nonatomic) BOOL showTable;
@property (weak, nonatomic) IBOutlet UITableView *deviceList;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *ibiLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) NSMutableArray *tempDevices;
@property (strong, nonatomic) NSMutableString *statusString;
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
    
    self.BTLEdeviceData = nil;
    
    self.bleShield = [[BLE alloc] init];
    [self.bleShield controlSetup];
    self.bleShield.delegate = self;
    
    self.rfduinoManager = [RFduinoManager sharedRFduinoManager];
    self.rfduinoManager.delegate = self;
    
    self.mPDDRiver = [[SENPDDriver alloc] init];
    self.mSesionData = [[SENSessionData alloc] init];
    self.mDevices = [[NSMutableArray alloc] init];
    self.tempDevices = [[NSMutableArray alloc] init];
    self.BTLEDevices = [[NSMutableArray alloc] init];
    self.mDeviceNames = [[NSMutableArray alloc] init];
    
    _max_inactivity = DEF_MAX_INACTIVITY;
    
    self.statusString = [[NSMutableString alloc] init];
    [self addMessageText:@"starting up"];
    
    self.knownDevices = @[@"722D74FC-0359-F949-C771-36C04647C7C2"];
    self.deviceAliases = @[@"Sensor X"];
    
    //Retrieve saved properties from system
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:NamePrefKey];
    
    [self showButtons:@"Starting Up"];
    [self.mPDDRiver startSession];

    [NSTimer scheduledTimerWithTimeInterval:(float)10.0 target:self selector:@selector(checkIntervalTime) userInfo:nil repeats:YES];
    
//    [self sendUnsentSesions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkIntervalTime
{
    if (self.connected) {
        CFTimeInterval frameDuration = CFAbsoluteTimeGetCurrent() - self.previousTimestamp;
        NSLog(@"Frame duration: %f", frameDuration);
        if (frameDuration > 5) {
            [self showButtons:@"Connected but no ibi data"];
        }
    }
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
    cell.textLabel.text = [self.mDeviceNames objectAtIndex:indexPath.row];
    
//    NSLog(@"is this doing anything?");
//    for (int i=0;i<[self.mDeviceDictionary count];i++) {
//        if (indexPath.row == i) {
//            cell.textLabel.text = [self.mDeviceDictionary objectForKey:@"deviceName"];
//            NSLog(@"%@",[self.mDeviceDictionary objectForKey:@"deviceName"]);
//        }
//    }
//    
//    NSArray *keyArray =  [self.mDeviceDictionary allKeys];
//    int count = [keyArray count];
//    for (int i=0; i < count; i++) {
//        NSDictionary *tmp = [self.mDeviceDictionary objectForKey:[ keyArray objectAtIndex:i]];
//        for (id key in tmp) {
//            NSLog(@"key: %@, value: %@ \n", key, [tmp objectForKey:key]);
//        }
//        if (i == indexPath.row) {
//            NSLog(@"row row your boat");
//        }
//    }
    
    
//    NSLog(@"key is status, value is %@",[self.mDeviceDictionary objectForKey:@"name"]);
    
//    for (id device in self.mDeviceDictionary) {
//        NSNumber *aggregatedArrayIndex = [self.mDeviceDictionary objectForKey:@"aggregatedArrayIndex"];
//        if (indexPath.row == [aggregatedArrayIndex integerValue]) {
//            NSString *deviceType = [self.mDeviceDictionary objectForKey:@"deviceType"];
//            NSLog(@"%@, %ld",deviceType, (long)indexPath.row);
//            cell.textLabel.text = deviceType;
//        }
//    }
//    for (int i=0;i<[self.knownDevices count];i++) {
//        if ([[self.mDevices objectAtIndex:indexPath.row] isEqualToString:[self.knownDevices objectAtIndex:i]]){
//            cell.textLabel.text = [self.deviceAliases objectAtIndex:i];
//        } else {
//            cell.textLabel.text = @"New Sensor Device";
//            cell.textLabel.text = [self.mDevices objectAtIndex:i]; // for the time being
//        }
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelected:indexPath.row];
    NSLog(@"picked %ld",(long)indexPath.row);
    [self addMessageText:@"picked"];
    [self showButtons:@"Picked Device From List"];
}

#pragma mark - Interface Elements

- (IBAction)touchConnect:(UIButton *)sender {
    self.scanForNewDevices = YES;
    [self initiateScan];
}

- (IBAction)touchScan:(UIButton *)sender {
    self.scanForNewDevices = YES;
    [self initiateScan];
}

- (IBAction)touchDisconnect:(UIButton *)sender {
    
//    self.BTLEConnectionFlag = NO;
    [self disconnectPeripherals];
    [self addMessageText:@"trying to disconnect"];
    
    self->scannedDevices = 0;
    self->counter = 0;
    [self showButtons:@"Disconnect"];
}

- (void)initiateScan
{
//    self.BTLEConnectionFlag = YES;
    [self disconnectPeripherals];
    self.disconnected = NO;
    
    self.mDevices = [[NSMutableArray alloc] init];
    self.mDeviceNames = [[NSMutableArray alloc] init];
    self.mDeviceDictionary = [[NSMutableDictionary alloc] init];
    
    [self.bleShield findBLEPeripherals:SCAN_TIME];
    [self.rfduinoManager startScan];
    [self scanForBTLEDevices];
    
    [self addMessageText:@"scan initiated"];
    [NSTimer scheduledTimerWithTimeInterval:SCAN_TIME target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    self.scanForNewDevices ? [self showButtons:@"scanDevices"] : [self showButtons:@"connectPrevious"];
}

- (void)didSelected:(NSInteger)index
{
    NSLog(@"the integer is %ld",(long)index);
    for (id device in self.mDeviceDictionary) {
//        NSLog(@"are we here?");
        NSNumber *originalArrayIndex = [self.mDeviceDictionary objectForKey:@"originalArrayIndex"];
        NSNumber *aggregatedArrayIndex = [self.mDeviceDictionary objectForKey:@"aggregatedArrayIndex"];
        NSString *deviceType = [self.mDeviceDictionary objectForKey:@"deviceType"];
        NSString *deviceName = [self.mDeviceDictionary objectForKey:@"deviceName"];
        
        if (index == [aggregatedArrayIndex integerValue]) {
            NSLog(@"this isn't printing -- %ld,%@,%@,%@", (long)index, originalArrayIndex, aggregatedArrayIndex, deviceType);
            
            if ([deviceType isEqualToString:@"BLE Mini"]) {
                NSLog(@"connecting to redbear");
                [self.bleShield connectPeripheral:[self.bleShield.peripherals objectAtIndex:[originalArrayIndex integerValue]]];
            } else if ([deviceType isEqualToString:@"RFDuino"]) {
                NSLog(@"connecting to rfduino");
                RFduino *rfduino = [[self.rfduinoManager rfduinos] objectAtIndex:[originalArrayIndex integerValue]];
                if (!rfduino.outOfRange) {
                    [self.rfduinoManager connectRFduino:rfduino];
                    NSLog(@"did it work?");
                }
            } else if ([deviceName isEqualToString:@"MIO GLOBAL"]) {
                NSLog(@"connecting to BTLE Device");
                
                NSLog(@"%@, %lu",originalArrayIndex, (unsigned long)[self.BTLEDevices count]);
                CBPeripheral *p = [self.BTLEDevices objectAtIndex:[originalArrayIndex integerValue]];
                NSLog(@"the name is %@",p.name);
                
                [self addMessageText:@"selected peripheral"];
                [self addMessageText:p.name];

                p.delegate = self;
                [self.BTLEcentralManager connectPeripheral:p options:nil];
                self.heartRateMonitorPeripheral = p;
            }
        }
    }
}

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

#pragma mark - BTLE Utilities

- (void)scanForBTLEDevices
{
    NSLog(@"---- Started scan");
    NSArray *services = @[[CBUUID UUIDWithString:HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:HRM_DEVICE_INFO_SERVICE_UUID]];
	CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	[centralManager scanForPeripheralsWithServices:services options:nil];
	self.BTLEcentralManager = centralManager;
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"---- device state changed");
	// Determine the state of the peripheral
	if ([central state] == CBCentralManagerStatePoweredOff) {
		NSLog(@"CoreBluetooth BLE hardware is powered off");
	}
	else if ([central state] == CBCentralManagerStatePoweredOn) {
		NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
	}
	else if ([central state] == CBCentralManagerStateUnauthorized) {
		NSLog(@"CoreBluetooth BLE state is unauthorized");
	}
	else if ([central state] == CBCentralManagerStateUnknown) {
		NSLog(@"CoreBluetooth BLE state is unknown");
	}
	else if ([central state] == CBCentralManagerStateUnsupported) {
		NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
	} else {
        NSLog(@"Not sure what's going on");
    }
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self addMessageText:@"did connect"];
    NSLog(@"---- Connected");
    self.BTLEPeripheral = peripheral;
    
    [self.BTLEPeripheral setDelegate:self];
    [self.BTLEPeripheral discoverServices:nil];

    [self updateLastDevice:[SENUtilities getUUIDString:(__bridge CFUUIDRef)(peripheral.identifier)] withName:peripheral.name];
    
    [self showButtons:@"Connected"];
    self.BTLEconnected = [NSString stringWithFormat:@"Connected: %@", self.BTLEPeripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    NSLog(@"%@",self.BTLEconnected);
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"says we've discovered device %hhd",self.BTLEConnectionFlag);
    [self addMessageText:@"discovered service"];
    NSLog(@"---- didDiscoverServices");
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"says we've discovered device %hhd",self.BTLEConnectionFlag);
    NSLog(@"---- didDiscoverPeripheral");
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (![localName isEqual:@""]) {
        [self logDeviceWithUUID:[SENUtilities getUUIDString:CFBridgingRetain(peripheral.identifier)] withName:peripheral.name withDeviceType:@"BTLE_VENDOR" withOriginalIndex:[self.BTLEDevices count]];
        [self.BTLEDevices addObject:peripheral];
        
        self->scannedDevices++;
        self->BTLECounter++;
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"says we've discovered characteristics %hhd",self.BTLEConnectionFlag);
    NSLog(@"---- didDiscoverCharacteristicsForServices");
    if ([service.UUID isEqual:[CBUUID UUIDWithString:HRM_HEART_RATE_SERVICE_UUID]])  {  // 1
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Request heart rate notifications
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 2
                [self.heartRateMonitorPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            // Request body sensor location
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HRM_BODY_LOCATION_UUID]]) { // 3
                [self.heartRateMonitorPeripheral readValueForCharacteristic:aChar];
            }
        }
    }
    // Retrieve Device Information Services for the Manufacturer Name
    if ([service.UUID isEqual:[CBUUID UUIDWithString:HRM_DEVICE_INFO_SERVICE_UUID]])  { // 5
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HRM_MANUFACTURER_NAME_UUID]]) {
                [self.heartRateMonitorPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"says we've updated values %hhd",self.BTLEConnectionFlag);
    NSLog(@"---- didUpdateValueForCharacteristics");
    // Updated value for heart rate measurement received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 1
        // Get the Heart Rate Monitor BPM
        NSLog(@"getting bpm");
        [self getHeartBPMData:characteristic error:error];
    }
    // Retrieve the characteristic value for manufacturer name received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_MANUFACTURER_NAME_UUID]]) {  // 2
        [self getManufacturerName:characteristic];
    }
    // Retrieve the characteristic value for the body sensor location received
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_BODY_LOCATION_UUID]]) {  // 3
        [self getBodyLocation:characteristic];
    }
    // Add our constructed device information to our UITextView
    //	self.BTLEdeviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", self.connected, self.bodyData, self.manufacturer];  // 4
}

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"---- getHeartBPMData");
    // Get the Heart Rate Monitor BPM
    NSData *data = [characteristic value];      // 1
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {          // 2
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
    }
    // Display the heart rate value to the UI if no error occurred
    if( (characteristic.value)  || !error ) {   // 4
        [self handleIBIData:bpm];
        //        NSLog(@"%hu",self.BTLEheartRate);
        //		self.heartRateBPM.text = [NSString stringWithFormat:@"%i bpm", bpm];
        //		self.heartRateBPM.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:28];
        //		[self doHeartBeat];
        //		self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
    }
    return;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected from peripheral: %@ with UUID: %@",peripheral,peripheral.identifier);
    [self showButtons:@"Disconnected"];
}

// Instance method to get the manufacturer name of the device
- (void) getManufacturerName:(CBCharacteristic *)characteristic
{
    NSLog(@"---- getManName");
    NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    self.BTLEmanufacturer = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerName];
    return;
}

// Instance method to get the body location of the device
- (void) getBodyLocation:(CBCharacteristic *)characteristic
{
    NSLog(@"---- getBodyLoc");
    NSData *sensorData = [characteristic value];
    uint8_t *bodyData = (uint8_t *)[sensorData bytes];
    if (bodyData ) {
        uint8_t bodyLocation = bodyData[0];
        self.BTLEbodyData = [NSString stringWithFormat:@"Body Location: %@", bodyLocation == 1 ? @"Chest" : @"Undefined"];
    }
    else {
        self.BTLEbodyData = [NSString stringWithFormat:@"Body Location: N/A"];
    }
    return;
}

#pragma mark - Redbear & RFduino Periphery

- (void)disconnectPeripherals
{
    if (self.bleShield.activePeripheral){
        if(self.bleShield.activePeripheral.state == CBPeripheralStateConnected) {
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
        }
    }
    
    if (self.connected_rfduino != NULL) {
        [self.connected_rfduino disconnect];
        self.connected_rfduino = NULL;
    }
    
    if(self.BTLEPeripheral && (self.BTLEPeripheral.state == CBPeripheralStateConnected)) {
        [self.BTLEcentralManager cancelPeripheralConnection:self.BTLEPeripheral];
        NSLog(@"does this happen? %d", self.BTLEcentralManager.state);
    }
}

// Called when scan period is over 
-(void)connectionTimer:(NSTimer *)timer
{
    [self addMessageText:@"scan finished"];
    [self.BTLEcentralManager stopScan];

    self.finishedScan = NO;
    self.scanning = YES;
    self.connected = NO;

    [self.rfduinoManager stopScan];
    
//    if (self->counter > 0) {
        NSLog(@"---- we've made it this far");
        if (self.scanForNewDevices == NO) {
            NSLog(@"---- not scanning for new devices");
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
            for (int i=0;i<[self.BTLEDevices count];i++) {
                // this needs to be done.
            }

        // We're scanning for new devices now
        } else if (self.scanForNewDevices == YES) {
            NSLog(@"---- we are scanning for new devices");
            for (int i = 0; i < self.bleShield.peripherals.count; i++) {
                CBPeripheral *peripheral = [self.bleShield.peripherals objectAtIndex:i];
                [self logDeviceWithUUID:[SENUtilities getUUIDString:CFBridgingRetain(peripheral.identifier)] withName:peripheral.name withDeviceType:@"BLE Mini" withOriginalIndex:i];
                NSLog(@"found this guy %@",peripheral);
                
//                [self.mDeviceDictionary setObject:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)] forKey:@"UUID"];
//                [self.mDeviceDictionary setObject:@"BLEMini" forKey:@"deviceType"];
//                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
//                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
                
//                [self.mNames addObject:p.name];
//                [self.mDevices addObject:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)]];
//                [self.mDeviceTypes addObject:@"BLEMini"];
//                NSLog(@"adding BLE item to list %d",self->counter);
            }

            for (int i = 0; i < [[self.rfduinoManager rfduinos] count]; i++) {
                RFduino *rfduino = [self.rfduinoManager.rfduinos objectAtIndex:i];
                [self logDeviceWithUUID:rfduino.UUID withName:rfduino.name withDeviceType:@"RFDuino" withOriginalIndex:i];
//                [self.mDeviceDictionary setObject:rfduino.UUID forKey:@"UUID"];
//                [self.mDeviceDictionary setObject:@"RFDuino" forKey:@"deviceType"];
//                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
//                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
//                
//                [self.mDevices addObject:rfduino.UUID];
//                [self.mDeviceTypes addObject:@"RFDuino"];
//                
//                NSLog(@"adding RFDUINO item to list %d",self->counter);
            }
        }
//    }
    NSLog(@"here you go");
    [self.deviceList reloadData];
    [self showButtons:@"Finished Scan"];
}

- (void)logDeviceWithUUID:(NSString *)uuid withName:(NSString *)name withDeviceType:(NSString *)type withOriginalIndex:(int)originalIndex
{
//        CBPeripheral *peripheral = (__bridge CBPeripheral *)((void*)&device);  // cool, but not worthwhile

    [self.mDeviceDictionary setObject:uuid forKey:@"UUID"];
    [self.mDeviceDictionary setObject:name forKey:@"deviceName"];
    [self.mDeviceDictionary setObject:type forKey:@"deviceType"];
    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:originalIndex] forKey:@"originalArrayIndex"];
    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
    
    [self.mDevices addObject:uuid];
    [self.mDeviceNames addObject:name];
    
    self->counter++;    
}

- (void)showButtons:(NSString *)state
{
    if ([state isEqualToString:@"Disconnect"]) {
        self.deviceList.hidden = YES;
        self.connectButton.enabled = YES;
        self.scanButton.enabled = YES;
        self.disconnectButton.enabled = NO;
        [self.spinner stopAnimating];
        self.instructionLabel.text = @"Disconnecting. Make sure your device is switched on";
        self.ibiLabel.hidden = YES;
        
    } else if ([state isEqualToString:@"connectPrevious"]) {
        self.deviceList.hidden = YES;
        self.connectButton.enabled = NO;
        self.scanButton.enabled = NO;
        self.disconnectButton.enabled = NO;
        [self.spinner startAnimating];
        self.instructionLabel.text = @"Trying to connect to previous device";
        self.ibiLabel.hidden = YES;
        
    } else if ([state isEqualToString:@"scanDevices"]) {
        self.deviceList.hidden = YES;
        self.connectButton.enabled = NO;
        self.scanButton.enabled = NO;
        self.disconnectButton.enabled = NO;
        [self.spinner startAnimating];
        self.instructionLabel.text = @"Scanning for available devices";
        self.ibiLabel.hidden = YES;
        NSLog(@"scanning");
        
    } else if ([state isEqualToString:@"Connected"]) {
        self.connected = YES;
        
        self.deviceList.hidden = YES;
        self.connectButton.enabled = NO;
        self.scanButton.enabled = NO;
        self.disconnectButton.enabled = YES;
        [self.spinner stopAnimating];
        self.uuidLabel.text = self.lastUUID;
        self.instructionLabel.text = @"Connected";
        self.ibiLabel.text = @"Waiting for pulse data";
        self.ibiLabel.hidden = NO;
        
    } else if ([state isEqualToString:@"Disconnected"]) {
        self.connected = NO;
        self.disconnected = YES;
        
        self.deviceList.hidden = YES;
        self.connectButton.enabled = YES;
        self.scanButton.enabled = YES;
        self.disconnectButton.enabled = NO;
        [self.spinner stopAnimating];
        self.instructionLabel.text = @"Disconnected. Make sure your device is switched on";
        self.ibiLabel.hidden = YES;
      
    } else if ([state isEqualToString:@"Starting Up"]) {
        self.deviceList.hidden = YES;
        if (self.lastUUID != nil) self.connectButton.enabled = YES;
        self.scanButton.enabled = YES;
        self.disconnectButton.enabled = NO;
        [self.spinner stopAnimating];
        if (self.lastUUID.length > 0) self.uuidLabel.text = self.lastName;
        self.instructionLabel.text = @"Make sure your device is switched on";
        self.ibiLabel.hidden = YES;
        
    } else if ([state isEqualToString:@"Finished Scan"]) {
        [self.spinner stopAnimating];
        self.scanButton.enabled = YES;
        self.connectButton.enabled = YES;
        self.disconnectButton.enabled = NO;
        if (self->counter == 0) {
            self.deviceList.hidden = YES;
            self.instructionLabel.text = @"No devices available";
        } else {
            self.deviceList.hidden = NO;
            if (self.scanForNewDevices == YES) {
                self.instructionLabel.text = @"Select a device";
                [self.deviceList reloadData];
            } else {
                self.instructionLabel.text = @"Connecting";
            }
        }
        self.ibiLabel.hidden = YES;
        
    } else if ([state isEqualToString:@"Picked Device From List"]) {
        [self.spinner startAnimating];
        self.scanButton.enabled = NO;
        self.connectButton.enabled = NO;
        self.disconnectButton.enabled = NO;
        self.deviceList.hidden = YES;
        self.instructionLabel.text = @"Connecting";
        self.ibiLabel.hidden = YES;
        NSLog(@"connecting");
        
    } else if ([state isEqualToString:@"Connected but no ibi data"]) {
        self.scanButton.enabled = NO;
        self.connectButton.enabled = NO;
        self.disconnectButton.enabled = YES;
        self.deviceList.hidden = YES;
        self.instructionLabel.text = @"Connected";
        self.ibiLabel.hidden = NO;
        self.ibiLabel.text = @"Waiting for heart beat data";

    } else {
        NSLog(@"what should I do?");
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
//                        self.generateButton.hidden = true;
                    }

                    [self handleIBIData:(unsigned)interval];
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
                
//                [self.mPDDRiver sendtoPDBaseReliability:0];
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

- (void)handleIBIData:(unsigned)interval
{
    NSString *ibi = [NSString stringWithFormat:@"Interval %u", interval];
    self.ibiLabel.text = ibi;
    
    [self.delegate setLabel:ibi];
    NSLog(@"%@",ibi);
    
    [self.mPDDRiver sendIBI:interval];
    _bufferIndex = 0;
    _inactivityCount = 0;
    self.previousTimestamp = CFAbsoluteTimeGetCurrent();
    [self.mSesionData addIbi:interval];
}

#pragma mark - BLE Mini

- (void)bleDidDisconnect
{
    [self showButtons:@"Disconnected"];
}

-(void)bleDidConnect
{
    [self updateLastDevice:[SENUtilities getUUIDString:CFBridgingRetain(self.bleShield.activePeripheral.identifier)] withName:@"BLE Mini"];
    [self showButtons:@"Connected"];
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
//    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
}


#pragma mark - RFDUINO

- (void)didDiscoverRFduino:(RFduino *)rfduino
{
    NSLog(@"didDiscoverRFduino");
//    self->scannedDevices++;
}

- (void)didConnectRFduino:(RFduino *)rfduino
{
    NSLog(@"didConnectRFduino");    
    self.connected_rfduino = rfduino;
    [self.connected_rfduino setDelegate:self];
    [self updateLastDevice:rfduino.UUID withName:@"RFDuino"];
    [self showButtons:@"Connected"];
}

- (void)didDisconnectRFduino:(RFduino *)rfduino
{
    self.connected_rfduino = NULL;
    NSLog(@"didDisconnectRFduino");
    [self showButtons:@"Disconnected"];
}

- (void)didReceive:(NSData *)data
{
//    NSLog(@"ReceivedData");
    unsigned char *value = [data bytes];
    int length = [data length];
    [self processBluetoothData:value length:length];
}

- (void)updateLastDevice:(NSString *)uuid withName:(NSString *)name
{
    self.lastUUID = uuid;
    self.lastName = name;
    [[NSUserDefaults standardUserDefaults] setObject:self.lastName forKey:NamePrefKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.uuidLabel.text = self.lastName;
}

- (void)addMessageText:(NSString *)text
{
    [self.statusString appendString:text];
    [self.statusString appendString:@"\r\n"];
    self.statusMessage.text = self.statusString;
    self.statusMessage.hidden = NO;
}


#pragma mark -
#pragma mark XML

//-(void) sendUnsentSesions
//{
//    SENXmlDataGenerator* xmlDataGenerator = [[SENXmlDataGenerator alloc]init];
//    [xmlDataGenerator sendUnsentSesions];
//}

@end
