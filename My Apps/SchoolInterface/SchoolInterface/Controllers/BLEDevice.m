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

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *ibiLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
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

    _max_inactivity = DEF_MAX_INACTIVITY;
    
    self.knownDevices = @[@"722D74FC-0359-F949-C771-36C04647C7C2"];
    self.deviceAliases = @[@"Sensor X"];
    
    //Retrieve saved UUID from system
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    
    [self showButtons:@"Starting Up"];

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
    cell.textLabel.text = [self.mDevices objectAtIndex:indexPath.row];
    
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
    [self showButtons:@"Picked Device From List"];
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
    [self showButtons:@"Disconnect"];
}

- (void)initiateScan
{
    [self disconnectPeripheralsBeforeScanning];
    [self.bleShield findBLEPeripherals:3];
    [self.rfduinoManager startScan];
    self.disconnected = NO;
    [self scanForBTLEDevices];
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    self.isFindingLast ? [self showButtons:@"connectPrevious"] : [self showButtons:@"scanDevices"];
}

- (void)didSelected:(NSInteger)index
{
    for (id device in self.mDeviceDictionary) {
        NSNumber *originalArrayIndex = [self.mDeviceDictionary objectForKey:@"originalArrayIndex"];
        NSNumber *aggregatedArrayIndex = [self.mDeviceDictionary objectForKey:@"aggregatedArrayIndex"];
        NSString *deviceType = [self.mDeviceDictionary objectForKey:@"deviceType"];
        
        if (index == [aggregatedArrayIndex integerValue]) {
            NSLog(@"-- %ld,%@,%@,%@", (long)index, originalArrayIndex, aggregatedArrayIndex, deviceType);
            
            if ([deviceType isEqualToString:@"Redbear"]) {
                NSLog(@"connecting to redbear");
                [self.bleShield connectPeripheral:[self.bleShield.peripherals objectAtIndex:[originalArrayIndex integerValue]]];
            } else if ([deviceType isEqualToString:@"RFDuino"]) {
                
                NSLog(@"connecting to rfduino");
                RFduino *rfduino = [[self.rfduinoManager rfduinos] objectAtIndex:[originalArrayIndex integerValue]];
                if (!rfduino.outOfRange) {
                    [self.rfduinoManager connectRFduino:rfduino];
                    NSLog(@"did it work?");
                }
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
	self.centralManager = centralManager;
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
	}
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"---- Connected");
	[peripheral setDelegate:self];
    [peripheral discoverServices:nil];
	self.BTLEconnected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"---- didDiscoverServices");
	for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:nil forService:service];
	}
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"---- didDiscoverPeripheral");
	NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
	if (![localName isEqual:@""]) {
        NSLog(@"%@",localName);
		// We found the Heart Rate Monitor
        /* need to do the following;
        
         1. populate a list of peripheral objects, let's call it BTLEPeripherals
         2. add this device to our mDevices array, as well as our NSMutableDict
         3. after a time period, stop BTLE scan
         4. present full list to user
         5. when user selects item from our list, hook that up to this BTLEPeripherals array
         6. also allow user to disconnect.
         
        */
		[self.centralManager stopScan];
		self.heartRateMonitorPeripheral = peripheral;
		peripheral.delegate = self;
		[self.centralManager connectPeripheral:peripheral options:nil];
	}
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
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
            //			else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_ENABLE_SERVICE_UUID]]) { // 4
            //				// Read the value of the heart rate sensor
            //				UInt8 value = 0x01;
            //				NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
            //				[peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            //			}
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
    NSLog(@"---- didUpdateValueForCharacteristics");
	// Updated value for heart rate measurement received
	if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 1
		// Get the Heart Rate Monitor BPM
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
		self.BTLEheartRate = bpm;
        NSLog(@"%hu",self.BTLEheartRate);
        //		self.heartRateBPM.text = [NSString stringWithFormat:@"%i bpm", bpm];
        //		self.heartRateBPM.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:28];
        //		[self doHeartBeat];
        //		self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
	}
	return;
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
    [self.deviceList reloadData];
    
    self.finishedScan = NO;
    self.scanning = YES;
    self.connected = NO;
    self->counter = 0;
    
    if(self.bleShield.peripherals.count > 0 || [[self.rfduinoManager rfduinos] count] > 0) {
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
            for (int i = 0; i < self.bleShield.peripherals.count; i++) {
                CBPeripheral *p = [self.bleShield.peripherals objectAtIndex:i];
                [self.mDeviceDictionary setObject:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)] forKey:@"UUID"];
                [self.mDeviceDictionary setObject:@"Redbear" forKey:@"deviceType"];
                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
                
                [self.mDevices addObject:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)]];

                NSLog(@"adding BLE item to list %d",self->counter);
                self->counter++;
            }

            for (int i = 0; i < [[self.rfduinoManager rfduinos] count]; i++) {
                RFduino *rfduino = [self.rfduinoManager.rfduinos objectAtIndex:i];
                
                [self.mDeviceDictionary setObject:rfduino.UUID forKey:@"UUID"];
                [self.mDeviceDictionary setObject:@"RFDuino" forKey:@"deviceType"];
                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
                
                [self.mDevices addObject:rfduino.UUID];
                [self.mDeviceTypes addObject:@"RFDuino"];
                
                NSLog(@"adding RFDUINO item to list %d",self->counter);
                self->counter++;

            }
            [self.deviceList reloadData];
        }
    }
    
    [self showButtons:@"Finished Scan"];
    
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
        if (self.lastUUID.length > 0) self.uuidLabel.text = self.lastUUID;
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
            if (self.isFindingLast) {
                self.instructionLabel.text = @"Connecting";
            } else {
                self.instructionLabel.text = @"Select a device";
            }
        }
        self.ibiLabel.hidden = YES;
        NSLog(@"finished");
        
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
                        self.generateButton.hidden = true;
                    }
                    
                    NSString *ibi = [NSString stringWithFormat:@"Interval %d", interval];
                    self.ibiLabel.text = ibi;

                    [self.delegate setLabel:ibi];
                    NSLog(@"%@",ibi);

                    [self.mPDDRiver sendIBI:interval];
                    _bufferIndex = 0;
                    _inactivityCount = 0;
                    self.previousTimestamp = CFAbsoluteTimeGetCurrent();
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
    [self showButtons:@"Disconnected"];
}

-(void)bleDidConnect
{
    //Save UUID into system
    self.lastUUID = [SENUtilities getUUIDString:CFBridgingRetain(self.bleShield.activePeripheral.identifier)];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"%@",self.lastUUID);
    self.connected = YES;
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
    self.connected = YES;
    [self showButtons:@"Connected"];
    
}

- (void)didDisconnectRFduino:(RFduino *)rfduino
{
    self.connected_rfduino = NULL;
    NSLog(@"didDisconnectRFduino");
    self.connected = NO;
    self.disconnected = YES;
    [self showButtons:@"Disconnected"];
    
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
//    NSLog(@"ReceivedData");
    unsigned char *value = [data bytes];
    int length = [data length];
    [self processBluetoothData:value length:length];
}

#pragma mark -
#pragma mark XML

//-(void) sendUnsentSesions
//{
//    SENXmlDataGenerator* xmlDataGenerator = [[SENXmlDataGenerator alloc]init];
//    [xmlDataGenerator sendUnsentSesions];
//}

@end
