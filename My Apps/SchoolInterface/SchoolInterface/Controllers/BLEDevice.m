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
NSString * const scanModePrefKey = @"scanModePrefKey";
NSString * const  INACTIVITY_KEY = @"BrightheartsInactivity";
NSString * const  USERNAME_KEY = @"BrightheartsUsername";

unsigned char const OEM_RELIABLE = 0xA0;
unsigned char const OEM_UNRELIABLE = 0xA1;
unsigned char const OEM_PULSE = 0xB0;
unsigned char const SYNC_CHAR = 0xF9;

@interface BLEDevice()
@property (weak, nonatomic) IBOutlet UITableView *deviceList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scanModeSelector;

@property (weak, nonatomic) IBOutlet UIButton *connectionButton;

@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;

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
    
    self.mode = [[NSUserDefaults standardUserDefaults] integerForKey:scanModePrefKey];
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    self.lastName = [[NSUserDefaults standardUserDefaults] objectForKey:NamePrefKey];
    
//    if (!self.lastName) {
//        self.uuidLabel.text = @"Previous device: none";
//    } else {
//        self.uuidLabel.text = @"Previous device: none";
//    }
    
    [self.scanModeSelector setSelectedSegmentIndex:(int)self.mode];
    
    self.mPDDRiver = [[SENPDDriver alloc] init];
    [self.mPDDRiver startSession];
    
    self.discoveredPeripherals = [[NSMutableArray alloc] init];
    self.bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.statusString = [[NSMutableString alloc] init];

    [NSTimer scheduledTimerWithTimeInterval:SCAN_TIME target:self selector:@selector(checkBluetoothScanMode) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:(float)10.0 target:self selector:@selector(checkIntervalTime) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(scrollTextViewToBottom) userInfo:nil repeats:YES];
}

- (void)scrollTextViewToBottom
{
    // not happy with that
}

- (void)checkBluetoothScanMode
{
    if (self.mode == scanModeAuto) {
        if (self.state != BTPulseTrackerConnectedState) {
            [self tryConnect];
        } else {
            // do nothing
        }
    } else if (self.mode == scanModePreviousDevice) {
        [self tryConnect];
    } else if (self.mode == scanModeOff) {
        if (self.blePeripheral) {
            [self disconnectPeripheral];
            [self.discoveredPeripherals removeAllObjects];
            [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Bluetooth Off"] :self.statusTextView];
        }
    }
}

- (IBAction)selectScanMode:(UISegmentedControl *)sender
{
    self.mode = sender.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:self.mode forKey:scanModePrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"blah again %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:scanModePrefKey]);
    self.deviceList.hidden = YES;
    
    if (sender.selectedSegmentIndex == 0) {
        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Connecting to nearest device"] :self.statusTextView];
        self.instructionLabel.text = @"Connect to nearest Bluetooth device";
    } else if (sender.selectedSegmentIndex == 1) {
        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Scanning for new devices"] :self.statusTextView];
        self.instructionLabel.text = @"Scanning for new devices";
    } else if (sender.selectedSegmentIndex == 2) {
        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Trying to connect to previous sensor"] :self.statusTextView];
        self.instructionLabel.text = @"Connect to previous device";
    } else if (sender.selectedSegmentIndex == 3) {
        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Bluetooth off"] :self.statusTextView];
        self.instructionLabel.text = @"Bluetooth off";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scan

- (void)tryConnect
{
    if (self.state == BTPulseTrackerConnectedState) {
        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Already connected"] :self.statusTextView];
    } else {
        [self startScan];
        [SENUtilities addMessageText:self.statusString :@"Starting Scan" :self.statusTextView];
    }
}

- (void)startScan
{
    self.state = BTPulseTrackerScanState;
    self.blePeripheral = nil;
    self.manufacturer = @"";
    self.heartRate = 0;

    if (self.mode == scanModeAuto) {
        self.bestRSSI = -1e100;
        self.waitingForBestRSSI = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (SCAN_TIME * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),
                       ^{ [self connectToBestSignal]; });
    } else if (self.mode == scanModePreviousDevice) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (SCAN_TIME * NSEC_PER_SEC)),
                       dispatch_get_main_queue(),
                       ^{ [self connectToPreviousDevice]; });
    }
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) {
        NSArray *serviceTypes = @[[CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"], [CBUUID UUIDWithString:@"180D"]];
        [self.bleManager scanForPeripheralsWithServices:serviceTypes options:nil];
    } else {
        // running in Simulator
    }
    
    
}

- (void)connectToBestSignal
{
    if (self.state == BTPulseTrackerScanState) {
        self.waitingForBestRSSI = NO;
        if (!self.blePeripheral && self.bestPeripheral) {
            [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Best signal is %@", self.bestPeripheral.identifier.UUIDString] :self.statusTextView];
            [self connectPeripheral:self.bestPeripheral];
        
        } else if (!self.bestPeripheral) {
            [SENUtilities addMessageText:self.statusString :@"No devices found" :self.statusTextView];
            self.bestPeripheral = nil;
        }
    }
}

- (void)connectToPreviousDevice
{
    if (self.state == BTPulseTrackerScanState) {
        if (!self.lastPeripheral) {
            [SENUtilities addMessageText:self.statusString :@"No previous device" :self.statusTextView];
            
        } else if (self.lastPeripheral) {
            [SENUtilities addMessageText:self.statusString :@"Connecting to previous device" :self.statusTextView];
            [self connectPeripheral:self.lastPeripheral];
        }
    }
}

- (void)showTableOfDevices
{
    if ([self.discoveredPeripherals count] > 0) {
        self.deviceList.hidden = NO;
        [self.deviceList reloadData];
    }
}

- (void)connectPeripheral:(CBPeripheral*)peripheral
{
    if (!self.blePeripheral) {
        self.blePeripheral = peripheral;
        self.state = BTPulseTrackerConnectingState;
        [self.bleManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        self.bestPeripheral = nil;
    }
}

- (void) disconnectPeripheral
{
    [self.bleManager cancelPeripheralConnection:self.blePeripheral];
}

- (void) stopScan
{
    [self.bleManager stopScan];
}

- (NSString *)connectionStatus {
//    NSString *nickname = self.peripheralNickname;
    switch (self.state) {
        case BTPulseTrackerScanState:
            return [NSString stringWithFormat:@"Scanning for heart rate monitor"];
        case BTPulseTrackerConnectingState:
            return [NSString stringWithFormat:@"Connecting"];
        case BTPulseTrackerConnectedState:
            return [NSString stringWithFormat:@"Connected"];
        case BTPulseTrackerStoppedState:
            return [NSString stringWithFormat:@"Stopped"];
        default:
            return nil;
    }
}
- (NSString *)connectionStatusWithDuration {
    NSString *status = self.connectionStatus;
//    if (self.lastStateChangeTime != 0 && doubletime() - self.lastStateChangeTime > 2.0) {
//        status = [self.connectionStatus stringByAppendingFormat:@" for %@",
//                  printDuration(doubletime() - self.lastStateChangeTime)];
//    }
    return status;
}

- (void)setState:(BTPulseTrackerState)state {
    if (self.state != state) {
        NSLog(@"changing state from %d to %d", _state, state);
        if (self.lastStateChangeTime != 0 && [SENUtilities doubleTime] - self.lastStateChangeTime > 2.0) {
            // should I do something here?
        }
        _state = state;
        self.lastStateChangeTime = [SENUtilities doubleTime];
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

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self checkBluetooth];
}

- (BOOL) checkBluetooth
{
    NSString * state = nil;
    switch ([self.bleManager state]) {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            state = @"Something is wrong with Bluetooth Low Energy support.";
    }
    NSLog(@"Central manager state: %@", state);
    return FALSE;
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{    
    double rssi = [RSSI doubleValue];
    if (self.waitingForBestRSSI) {
        self.nickname = [SENUtilities getNickname:peripheral];
        
//        for (CBPeripheral *p in self.discoveredPeripherals) {
//            NSLog(@"%@ and %@",peripheral.identifier.UUIDString,p.identifier.UUIDString);
//            
//            if ([peripheral.identifier.UUIDString isEqualToString:p.identifier.UUIDString]){
//                NSLog(@"%@ and %@",peripheral.identifier.UUIDString,p.identifier.UUIDString);
//                addToList = NO;
//            } else {
//                NSLog(@"%@ and %@",peripheral.identifier.UUIDString,p.identifier.UUIDString);
//                addToList = YES;
//            }
//        }
//        if (addToList) {
            [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Found %@ with signal strength %g", peripheral.identifier.UUIDString, rssi] :self.statusTextView];
            if (!self.bestPeripheral || rssi > self.bestRSSI) {
                self.bestPeripheral = peripheral;
                self.bestRSSI = rssi;
            }
//        }

    } else {
        if (self.mode == scanModePreviousDevice) {
            if ([peripheral.identifier.UUIDString isEqualToString:self.lastUUID]) {
                self.lastPeripheral = peripheral;
            }
        }
        
//        if (self.connectMode == kConnectUUIDMode && peripheral.identifier && peripheral.identifier != self.connectIdentifier) {
//            // Not the device we're looking for
//            [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Found device %@", peripheral.identifier] :self.statusTextView];
//        } else {
//            [self connectPeripheral:peripheral];
//        }
    }

}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.lastBeatTimeValid = false;
    if (self.connectMode == kConnectUUIDMode && self.connectIdentifier != peripheral.identifier) {
        [self disconnectPeripheral];
    } else if (peripheral != self.blePeripheral) {
        [self disconnectPeripheral];
    } else {
        self.state = BTPulseTrackerConnectedState;
        self.connectionButton.enabled = YES;
        [self.connectionButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Connected to %@", peripheral.identifier.UUIDString] :self.statusTextView];
        [peripheral discoverServices:nil];
    }
    [self stopScan];
    
    self.lastUUID = peripheral.identifier.UUIDString;
    self.lastName = peripheral.name;
    [[NSUserDefaults standardUserDefaults] setObject:self.lastName forKey:NamePrefKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.uuidLabel.text = [NSString stringWithFormat:@"Connected to: %@", self.lastName];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.state = BTPulseTrackerScanState;
    [self.connectionButton setTitle:@"Scan" forState:UIControlStateNormal];
    [SENUtilities addMessageText:self.statusString :@"Disconnected" :self.statusTextView];
    self.uuidLabel.text = [NSString stringWithFormat:@"Last device: %@", self.lastName];
}


// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [SENUtilities addMessageText:self.statusString :@"Discovered Service" :self.statusTextView];
    NSLog(@"---- didDiscoverServices");
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
//    NSLog(@"says we've discovered characteristics %hhd",self.BTLEConnectionFlag);
//    NSLog(@"---- didDiscoverCharacteristicsForServices");
//    if ([service.UUID isEqual:[CBUUID UUIDWithString:HRM_HEART_RATE_SERVICE_UUID]])  {  // 1
//        for (CBCharacteristic *aChar in service.characteristics)
//        {
//            // Request heart rate notifications
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 2
//                [self.heartRateMonitorPeripheral setNotifyValue:YES forCharacteristic:aChar];
//            }
//            // Request body sensor location
//            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HRM_BODY_LOCATION_UUID]]) { // 3
//                [self.heartRateMonitorPeripheral readValueForCharacteristic:aChar];
//            }
//        }
//    }
//    // Retrieve Device Information Services for the Manufacturer Name
//    if ([service.UUID isEqual:[CBUUID UUIDWithString:HRM_DEVICE_INFO_SERVICE_UUID]])  { // 5
//        for (CBCharacteristic *aChar in service.characteristics)
//        {
//            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HRM_MANUFACTURER_NAME_UUID]]) {
//                [self.heartRateMonitorPeripheral readValueForCharacteristic:aChar];
//                NSLog(@"Found a Device Manufacturer Name Characteristic");
//            }
//        }
//    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSLog(@"says we've updated values %hhd",self.BTLEConnectionFlag);
//    NSLog(@"---- didUpdateValueForCharacteristics");
//    // Updated value for heart rate measurement received
//    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 1
//        // Get the Heart Rate Monitor BPM
//        NSLog(@"getting bpm");
//        [self getHeartBPMData:characteristic error:error];
//    }
//    // Retrieve the characteristic value for manufacturer name received
//    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_MANUFACTURER_NAME_UUID]]) {  // 2
//        [self getManufacturerName:characteristic];
//    }
//    // Retrieve the characteristic value for the body sensor location received
//    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_BODY_LOCATION_UUID]]) {  // 3
//        [self getBodyLocation:characteristic];
//    }
//    // Add our constructed device information to our UITextView
//    //	self.BTLEdeviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", self.connected, self.bodyData, self.manufacturer];  // 4
}

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSLog(@"---- getHeartBPMData");
//    // Get the Heart Rate Monitor BPM
//    NSData *data = [characteristic value];      // 1
//    const uint8_t *reportData = [data bytes];
//    uint16_t bpm = 0;
//    
//    if ((reportData[0] & 0x01) == 0) {          // 2
//        // Retrieve the BPM value for the Heart Rate Monitor
//        bpm = reportData[1];
//    }
//    else {
//        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
//    }
//    // Display the heart rate value to the UI if no error occurred
//    if( (characteristic.value)  || !error ) {   // 4
//        [self handleIBIData:bpm];
//        //        NSLog(@"%hu",self.BTLEheartRate);
//        //		self.heartRateBPM.text = [NSString stringWithFormat:@"%i bpm", bpm];
//        //		self.heartRateBPM.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:28];
//        //		[self doHeartBeat];
//        //		self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
//    }
//    return;
}

- (void) getManufacturerName:(CBCharacteristic *)characteristic
{
    NSLog(@"---- getManName");
    NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    self.BTLEmanufacturer = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerName];
    return;
}

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


// Called when scan period is over 
-(void)connectionTimer:(NSTimer *)timer
{
//    [self addMessageText:@"scan finished"];
//    [self.BTLEcentralManager stopScan];

//    self.finishedScan = NO;
//    self.scanning = YES;
//    self.connected = NO;
//
//    [self.rfduinoManager stopScan];
//    
////    if (self->counter > 0) {
//        NSLog(@"---- we've made it this far");
//        if (self.scanForNewDevices == NO) {
//            NSLog(@"---- not scanning for new devices");
//            // check last UUID against all BLEMini device UUIDs found
//            for (int i = 0; i < self.bleShield.peripherals.count; i++) {
//                CBPeripheral *p = [self.bleShield.peripherals objectAtIndex:i];
//                if (p.identifier != NULL) {
//                    // Compare UUIDs and call connectPeripheral if matched
//                    if([self.lastUUID isEqualToString:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)]]) {
//                        [self.bleShield connectPeripheral:p];
//                    }
//                }
//            }
//            
//            // also check last UUID against all rfduino device UUIDs found
//            for(int i = 0; i < [[self.rfduinoManager rfduinos] count]; i++) {
//                RFduino *rfduino = [self.rfduinoManager.rfduinos objectAtIndex:i];
//                if([self.lastUUID isEqualToString:rfduino.UUID]) {
//                    RFduino *rfduino = [[self.rfduinoManager rfduinos] objectAtIndex:i];
//                    if (!rfduino.outOfRange) {
//                        [self.rfduinoManager connectRFduino:rfduino];
//                        [self.spinner stopAnimating];
//                    }
//                }
//            }
//            for (int i=0;i<[self.BTLEDevices count];i++) {
//                // this needs to be done.
//            }
//
//        // We're scanning for new devices now
//        } else if (self.scanForNewDevices == YES) {
//            NSLog(@"---- we are scanning for new devices");
//            for (int i = 0; i < self.bleShield.peripherals.count; i++) {
//                CBPeripheral *peripheral = [self.bleShield.peripherals objectAtIndex:i];
//                [self logDeviceWithUUID:[SENUtilities getUUIDString:CFBridgingRetain(peripheral.identifier)] withName:peripheral.name withDeviceType:@"BLE Mini" withOriginalIndex:i];
//                NSLog(@"found this guy %@",peripheral);
//                
////                [self.mDeviceDictionary setObject:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)] forKey:@"UUID"];
////                [self.mDeviceDictionary setObject:@"BLEMini" forKey:@"deviceType"];
////                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
////                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
//                
////                [self.mNames addObject:p.name];
////                [self.mDevices addObject:[SENUtilities getUUIDString:CFBridgingRetain(p.identifier)]];
////                [self.mDeviceTypes addObject:@"BLEMini"];
////                NSLog(@"adding BLE item to list %d",self->counter);
//            }
//
//            for (int i = 0; i < [[self.rfduinoManager rfduinos] count]; i++) {
//                RFduino *rfduino = [self.rfduinoManager.rfduinos objectAtIndex:i];
//                [self logDeviceWithUUID:rfduino.UUID withName:rfduino.name withDeviceType:@"RFDuino" withOriginalIndex:i];
////                [self.mDeviceDictionary setObject:rfduino.UUID forKey:@"UUID"];
////                [self.mDeviceDictionary setObject:@"RFDuino" forKey:@"deviceType"];
////                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:i] forKey:@"originalArrayIndex"];
////                [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
////                
////                [self.mDevices addObject:rfduino.UUID];
////                [self.mDeviceTypes addObject:@"RFDuino"];
////                
////                NSLog(@"adding RFDUINO item to list %d",self->counter);
//            }
//        }
////    }
//    NSLog(@"here you go");
//    [self.deviceList reloadData];
//    [self showButtons:@"Finished Scan"];
}

- (void)logDeviceWithUUID:(NSString *)uuid withName:(NSString *)name withDeviceType:(NSString *)type withOriginalIndex:(int)originalIndex
{
//    CBPeripheral *peripheral = (__bridge CBPeripheral *)((void*)&device);  // cool, but not worthwhile
//    [self.mDeviceDictionary setObject:uuid forKey:@"UUID"];
//    [self.mDeviceDictionary setObject:name forKey:@"deviceName"];
//    [self.mDeviceDictionary setObject:type forKey:@"deviceType"];
//    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:originalIndex] forKey:@"originalArrayIndex"];
//    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
//    [self.mDevices addObject:uuid];
//    [self.mDeviceNames addObject:name];
//    self->counter++;
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
//    [self processBluetoothData:data length:length];
}


-(void)processBluetoothData:(unsigned char *)data length:(int)length
{
////    if (self.passedToParent == NO) {
//    for (int i = 0; i < length && _bufferIndex < 4; i++) {
//        unsigned char b = data[i];
//        
//        // we will force resynchronisation
//        if (b == OEM_PULSE || b == SYNC_CHAR || b == OEM_RELIABLE || b == OEM_UNRELIABLE) _bufferIndex = 0;
//        
//        _oemBuffer.data[_bufferIndex] = b;
//        _bufferIndex++;
//        
//        switch (_oemBuffer.data[0]) {
//            case OEM_PULSE:
//                if (_bufferIndex == NUM_PULSE_BYTES) {
//                    unsigned char lsb = _oemBuffer.data[1];
//                    unsigned char msb = _oemBuffer.data[2];
//                    
//                    unsigned interval = mergeBytes(lsb, msb);
//                    
//                    
//                    if (!_started) {
//                        [self.mSesionData clearSesionLists];
//                        [self.mSesionData setStartSesion];
//                        self.mSesionData.mUsername = self.username;
//                        self.mSesionData.mDeviceID = self.lastUUID;
//                        
////                        [self displaySesionStart];
//                        
////                        self.sessionStatusLabel.text = @"Sesion Started";
//                        _started = true;
//                        
//                        [self.mPDDRiver startSession];
////                        self.generateButton.hidden = true;
//                    }
//
//                    [self handleIBIData:(unsigned)interval];
//                }
//                
//                break;
//                
//            case SYNC_CHAR:
//                _bufferIndex = 0;
//                
//                
//                break;
//                
//            case OEM_RELIABLE:
//                _bufferIndex = 0;
//                _reliable = true;
//                
//                [self.mPDDRiver sendtoPDBaseReliability:1];
//                self.sessionStatusLabel.text = @"Reliable";
//                _inactivityCount = 0;
//                
//                [self.mSesionData addReliability:true];
//                
//                break;
//                
//            case OEM_UNRELIABLE:
//                _bufferIndex = 0;
//                _reliable = false;
//                
////                [self.mPDDRiver sendtoPDBaseReliability:0];
//                self.sessionStatusLabel.text = @"Unreliable";
//                _inactivityCount = 0;
//                
//                [self.mSesionData addReliability:false];
//                
//                
//                break;
//                
//            default:
//                _bufferIndex = 0; // we are not going to accept other values
//                break;
//        }
//    }
//    _inactivityCount++;
//    
//    if (_inactivityCount >= MAX_INACTIVITY) {
//        self.intervalLabel.text = @"";
//        self.sessionStatusLabel.text = @"session Ended";
//        if (_started) {
//            _started = false;
//            [self.mPDDRiver endSession];
//            
//            [self.mSesionData setSessionEnd];
//            self.sessionStatusLabel.text = @"Uploaded";
//            
////            XMLDataGenerator* xml = [[XMLDataGenerator alloc]init];
////            NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
//            
////            [xml generateXML:self.mSesionData filename: [NSString stringWithFormat:@"%@.xml", uuid]];
////            [xml release];
//        }
//    }
////    }
}

- (void)handleIBIData:(unsigned)interval
{
//    NSString *ibi = [NSString stringWithFormat:@"Interval %u", interval];
//    self.ibiLabel.text = ibi;
//    
//    [self.delegate setLabel:ibi];
//    NSLog(@"%@",ibi);
//    
//    [self.mPDDRiver sendIBI:interval];
//    _bufferIndex = 0;
//    _inactivityCount = 0;
//    self.previousTimestamp = CFAbsoluteTimeGetCurrent();
//    [self.mSesionData addIbi:interval];
}

#pragma mark - BLE Mini
- (void)bleDidDisconnect
{
//    [self showButtons:@"Disconnected"];
}

-(void)bleDidConnect
{
//    [self updateLastDevice:[SENUtilities getUUIDString:CFBridgingRetain(self.bleShield.activePeripheral.identifier)] withName:@"BLE Mini"];
//    [self showButtons:@"Connected"];
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
//    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
}


#pragma mark - RFDUINO
- (void)didReceive:(NSData *)data
{
////    NSLog(@"ReceivedData");
//    unsigned char *value = [data bytes];
//    int length = [data length];
//    [self processBluetoothData:value length:length];
}

- (void)updateLastDevice:(NSString *)uuid withName:(NSString *)name
{
//    self.lastUUID = uuid;
//    self.lastName = name;
//    [[NSUserDefaults standardUserDefaults] setObject:self.lastName forKey:NamePrefKey];
//    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    self.uuidLabel.text = self.lastName;
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.discoveredPeripherals.count;
    NSLog(@"%lu discovered peripherals",(unsigned long)self.discoveredPeripherals.count);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Available Devices";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"BLEDeviceList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier forIndexPath:indexPath];
    if ([self.discoveredPeripherals count] > 0) {
        CBPeripheral *peripheral = [self.discoveredPeripherals objectAtIndex:indexPath.row];
        cell.textLabel.text = peripheral.identifier.UUIDString;
    } else {
        cell.textLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self didSelected:indexPath.row];
//    NSLog(@"picked %ld",(long)indexPath.row);
//    [self addMessageText:@"picked"];
//    [self showButtons:@"Picked Device From List"];
}

- (void)checkIntervalTime
{
    if (self.connected) {
        CFTimeInterval frameDuration = CFAbsoluteTimeGetCurrent() - self.previousTimestamp;
        NSLog(@"Frame duration: %f", frameDuration);
        //        if (frameDuration > 5) {
        //            [self showButtons:@"Connected but no ibi data"];
        //        }
    }
}

@end
