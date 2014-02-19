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

// will need these again, eventually
NSString * const  INACTIVITY_KEY = @"BrightheartsInactivity";
NSString * const  USERNAME_KEY = @"BrightheartsUsername";
//
//unsigned char const OEM_RELIABLE = 0xA0;
//unsigned char const OEM_UNRELIABLE = 0xA1;
//unsigned char const OEM_PULSE = 0xB0;
//unsigned char const SYNC_CHAR = 0xF9;

@interface BLEDevice()
@property (weak, nonatomic) IBOutlet UISegmentedControl *scanModeSelector;
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
    [self.scanModeSelector setSelectedSegmentIndex:(int)self.mode];
    [self.delegate changeBTMode:self.mode];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addStringToInterface:)
                                                 name:UI_NOTIFICATION_STRING
                                               object:nil];
    
    // want to move this back into the mainViewController
    self.mPDDRiver = [[SENPDDriver alloc] init];
    [self.mPDDRiver startSession];
    
    self.discoveredPeripherals = [[NSMutableArray alloc] init];
    self.statusString = [[NSMutableString alloc] init];
}

#pragma mark - Messaging

- (void)addStringToTextView:(NSString *)string
{
    [SENUtilities addMessageTextToString:self.statusString withString:string toTextView:self.statusTextView withGesture:self.touched];
}

- (void)addStringToInterface:(NSNotification *)note
{
    NSString *text = [[note userInfo] objectForKey:@"textConsole"];
    [self addStringToTextView:text];
}

#pragma mark - TODO connect BT connection state between BLEDevice and SENPulseTracker

- (void)checkBluetoothScanMode
{
    if (self.mode == scanModeAuto || self.mode == scanModePreviousDevice) {
        if (self.state != BTPulseTrackerConnectedState) {
            // is not connected
        } else {
            // is connected to BT device
        }
    } else if (self.mode == scanModeOff) {
//        [self addStringToTextView:@"Bluetooth Off"];
    }
}

#pragma mark - Interface

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touched = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touched = NO;
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

- (IBAction)selectScanMode:(UISegmentedControl *)sender
{
    self.mode = sender.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:self.mode forKey:scanModePrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.delegate changeBTMode:self.mode];
    
    if (self.mode == scanModeAuto) {
//        self.instructionLabel.text = @"Connect to the nearest Bluetooth device";
        if (self.state != BTPulseTrackerConnectedState) {
            [self addStringToTextView:@"Connecting to nearest device"];
        } else {
            [self addStringToTextView:[NSString stringWithFormat:@"Connected to %@", self.lastName]];
        }
    } else if (self.mode == scanModePreviousDevice) {
//        self.instructionLabel.text = @"Connect to previous device";
        if (self.state != BTPulseTrackerConnectedState) {
            [self addStringToTextView:@"Trying to connect to the previous device"];
        } else {
            [self addStringToTextView:[NSString stringWithFormat:@"Connected to %@", self.lastName]];
        }
    } else if (self.mode == scanModeOff) {
        [self addStringToTextView:@"Bluetooth off"];
//        self.instructionLabel.text = @"Bluetooth off";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scan

//- (void)tryConnect
//{
//    if (self.state == BTPulseTrackerConnectedState) {
//        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Already connected"] :self.statusTextView];
//    } else {
//        [self startScan];
//    }
//}

//- (void)startScan
//{
//    self.state = BTPulseTrackerScanState;
//    self.blePeripheral = nil;
//    self.manufacturer = @"";
//    self.heartRate = 0;
//
//    if (self.mode == scanModeAuto && !self.bestPeripheral) {
//        [SENUtilities addMessageText:self.statusString :@"Starting Scan" :self.statusTextView];
//        self.bestPeripheral = nil;
//        self.bestRSSI = -1e100;
//        self.waitingForBestRSSI = YES;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (SCAN_TIME * NSEC_PER_SEC)),
//                       dispatch_get_main_queue(),
//                       ^{ [self connectToBestSignal]; });
//    } else if (self.mode == scanModePreviousDevice) {
//        [SENUtilities addMessageText:self.statusString :@"Starting Scan" :self.statusTextView];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (SCAN_TIME * NSEC_PER_SEC)),
//                       dispatch_get_main_queue(),
//                       ^{ [self connectToPreviousDevice]; });
//    }
//    
////    UIDevice *currentDevice = [UIDevice currentDevice];
////    if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) {
//    
//        NSArray *serviceTypes = @[[CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"], [CBUUID UUIDWithString:@"180D"], [CBUUID UUIDWithString:@"180A"]];
//
//    #if TARGET_OS_IPHONE
//        [self.bleManager scanForPeripheralsWithServices:serviceTypes options:nil];
//    #else 
//        [self.bleManager scanForPeripheralsWithServices:nil options:nil];
//    #endif
//    
//}

//- (void)connectToBestSignal
//{
//    if (self.state == BTPulseTrackerScanState) {
//        self.waitingForBestRSSI = NO;
//        if (!self.blePeripheral && self.bestPeripheral) {
//            [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Best signal is %@", self.bestPeripheral.identifier.UUIDString] :self.statusTextView];
//            [self connectPeripheral:self.bestPeripheral];
//        
//        } else if (!self.bestPeripheral) {
//            [SENUtilities addMessageText:self.statusString :@"No devices found" :self.statusTextView];
//            self.bestPeripheral = nil;
//        }
//    }
//}

//- (void)connectToPreviousDevice
//{
//    if (self.state == BTPulseTrackerScanState) {
//        if (!self.lastPeripheral) {
//            [SENUtilities addMessageText:self.statusString :@"No previous device" :self.statusTextView];
//            
//        } else if (self.lastPeripheral) {
//            [SENUtilities addMessageText:self.statusString :@"Connecting to previous device" :self.statusTextView];
//            [self connectPeripheral:self.lastPeripheral];
//        }
//    }
//}

//- (void)showTableOfDevices
//{
//    if ([self.discoveredPeripherals count] > 0) {
//        self.deviceList.hidden = NO;
//        [self.deviceList reloadData];
//    }
//}

//- (void)connectPeripheral:(CBPeripheral*)peripheral
//{
//    if (!self.blePeripheral) {
//        self.blePeripheral = peripheral;
//        self.state = BTPulseTrackerConnectingState;
//        [self.bleManager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]]; // ??
//
//    }
//}

//- (void) disconnectPeripheral
//{
//    [self.bleManager cancelPeripheralConnection:self.blePeripheral];
//    [self.discoveredPeripherals removeAllObjects];
//}

//- (void) stopScan
//{
//    [self.bleManager stopScan];
//}

//- (NSString *)connectionStatus {
//    switch (self.state) {
//        case BTPulseTrackerScanState:
//            return [NSString stringWithFormat:@"Scanning for heart rate monitor"];
//        case BTPulseTrackerConnectingState:
//            return [NSString stringWithFormat:@"Connecting"];
//        case BTPulseTrackerConnectedState:
//            return [NSString stringWithFormat:@"Connected"];
//        case BTPulseTrackerStoppedState:
//            return [NSString stringWithFormat:@"Stopped"];
//        default:
//            return nil;
//    }
//}

//- (NSString *)connectionStatusWithDuration {
//    NSString *status = self.connectionStatus;
////    if (self.lastStateChangeTime != 0 && doubletime() - self.lastStateChangeTime > 2.0) {
////        status = [self.connectionStatus stringByAppendingFormat:@" for %@",
////                  printDuration(doubletime() - self.lastStateChangeTime)];
////    }
//    return status;
//}

//- (void)setState:(BTPulseTrackerState)state {
//    if (self.state != state) {
//        NSLog(@"changing state from %d to %d", _state, state);
//        if (self.lastStateChangeTime != 0 && [SENUtilities doubleTime] - self.lastStateChangeTime > 2.0) {
//            // should I do something here?
//        }
//        _state = state;
//        self.lastStateChangeTime = [SENUtilities doubleTime];
//    }
//}


#pragma mark - BTLE Utilities

//- (void)centralManagerDidUpdateState:(CBCentralManager *)central
//{
//    [self checkBluetooth];
//}

//- (BOOL) checkBluetooth
//{
//    NSString * state = nil;
//    switch ([self.bleManager state]) {
//        case CBCentralManagerStateUnsupported:
//            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
//            break;
//        case CBCentralManagerStateUnauthorized:
//            state = @"The app is not authorized to use Bluetooth Low Energy.";
//            break;
//        case CBCentralManagerStatePoweredOff:
//            state = @"Bluetooth is currently powered off.";
//            break;
//        case CBCentralManagerStatePoweredOn:
//            return TRUE;
//        case CBCentralManagerStateUnknown:
//        default:
//            state = @"Something is wrong with Bluetooth Low Energy support.";
//    }
//    NSLog(@"Central manager state: %@", state);
//    return FALSE;
//}

//- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
//{    
//    double rssi = [RSSI doubleValue];
//    if (self.waitingForBestRSSI) {
//        self.nickname = [SENUtilities getNickname:peripheral];
//        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Found %@ with signal strength %g", peripheral.identifier.UUIDString, rssi] :self.statusTextView];
//        if (!self.bestPeripheral || rssi > self.bestRSSI) {
//            self.bestPeripheral = peripheral;
//            self.bestRSSI = rssi;
//        }
//
//    } else {
//        if (self.mode == scanModePreviousDevice) {
//            if ([peripheral.identifier.UUIDString isEqualToString:self.lastUUID]) {
//                self.lastPeripheral = peripheral;
//            }
//        }
//    }
////    [central cancelPeripheralConnection:peripheral];
//}

//- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
//{
//    self.lastBeatTimeValid = false;
//    if (self.connectMode == kConnectUUIDMode && self.connectIdentifier != peripheral.identifier) {
//        [self disconnectPeripheral];
//    } else if (peripheral != self.blePeripheral) {
//        [self disconnectPeripheral];
//    } else {
//        self.state = BTPulseTrackerConnectedState;
//        [peripheral discoverServices:nil];
//        NSLog(@"trying to discover services");
//        
//        self.lastUUID = peripheral.identifier.UUIDString;
//        self.lastName = [SENUtilities getNickname:peripheral];
//        [[NSUserDefaults standardUserDefaults] setObject:self.lastName forKey:NamePrefKey];
//        [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [SENUtilities addMessageText:self.statusString :[NSString stringWithFormat:@"Connected to %@, %@", self.lastName, peripheral.identifier.UUIDString] :self.statusTextView];
//        self.uuidLabel.text = [NSString stringWithFormat:@"Connected to: %@", self.lastName];
//        
//    }
//    [self stopScan];
//}

//- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    self.state = BTPulseTrackerScanState;
//    [self.connectionButton setTitle:@"Scan" forState:UIControlStateNormal];
//    [SENUtilities addMessageText:self.statusString :@"Disconnected" :self.statusTextView];
//    self.uuidLabel.text = [NSString stringWithFormat:@"Last device: %@", self.lastName];
//}

//-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
//{
//    for(CBService* service in peripheral.services)
//    {
//        if(service.characteristics) {
//            NSLog(@"already discovered");
//            [self peripheral:peripheral didDiscoverCharacteristicsForService:service error:nil]; //already discovered characteristic before, DO NOT do it again
//        } else {
//            [peripheral discoverCharacteristics:nil
//                                     forService:service]; //need to discover characteristics
//        }
//    }
//}

//- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
//{
//    NSLog(@"discovered, bro!");
//    for (CBCharacteristic *ch in service.characteristics)
//    {
//        unsigned long long serviceID = (u64(service.UUID) << 32) | u64(ch.UUID);
//        if (ch.properties & CBCharacteristicPropertyRead) {
//            NSLog(@"Requesting read of %llX", serviceID);
//            [peripheral readValueForCharacteristic:ch];
//        }
//        if (ch.properties & CBCharacteristicPropertyNotify) {
//            NSLog(@"Requesting notification for %llX", serviceID);
//            [peripheral setNotifyValue:YES forCharacteristic:ch];
//        }
//    }
//}

// Instance method to get the heart rate BPM information
//- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
//{
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
//}

//- (void) getManufacturerName:(CBCharacteristic *)characteristic
//{
//    NSLog(@"---- getManName");
//    NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//    self.BTLEmanufacturer = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerName];
//    return;
//}

//- (void) getBodyLocation:(CBCharacteristic *)characteristic
//{
//    NSLog(@"---- getBodyLoc");
//    NSData *sensorData = [characteristic value];
//    uint8_t *bodyData = (uint8_t *)[sensorData bytes];
//    if (bodyData ) {
//        uint8_t bodyLocation = bodyData[0];
//        self.BTLEbodyData = [NSString stringWithFormat:@"Body Location: %@", bodyLocation == 1 ? @"Chest" : @"Undefined"];
//    }
//    else {
//        self.BTLEbodyData = [NSString stringWithFormat:@"Body Location: N/A"];
//    }
//    return;
//}

#pragma mark - Redbear & RFduino Periphery

//- (void)logDeviceWithUUID:(NSString *)uuid withName:(NSString *)name withDeviceType:(NSString *)type withOriginalIndex:(int)originalIndex
//{
//    CBPeripheral *peripheral = (__bridge CBPeripheral *)((void*)&device);  // cool, but not worthwhile
//    [self.mDeviceDictionary setObject:uuid forKey:@"UUID"];
//    [self.mDeviceDictionary setObject:name forKey:@"deviceName"];
//    [self.mDeviceDictionary setObject:type forKey:@"deviceType"];
//    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:originalIndex] forKey:@"originalArrayIndex"];
//    [self.mDeviceDictionary setObject:[NSNumber numberWithInt:counter] forKey:@"aggregatedArrayIndex"];
//    [self.mDevices addObject:uuid];
//    [self.mDeviceNames addObject:name];
//    self->counter++;
//}

// Merge two bytes to integer value
//unsigned int mergeBytes (unsigned char lsb, unsigned char msb)
//{
//    unsigned int ret = msb & 0xFF;
//    ret = ret << 7;
//    ret = ret + lsb;
//    return ret;
//}

//// we received data from BLE - process it
//-(void)bleDidReceiveData:(unsigned char *)data length:(int)length
//{
//    [self processBluetoothData:data length:length];
//}


//-(void)processBluetoothData:(unsigned char *)data length:(int)length
//{
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
//}

//- (void)handleIBIData:(unsigned)interval
//{
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
//}

#pragma mark - BLE Mini
//- (void)bleDidDisconnect
//{
//    [self showButtons:@"Disconnected"];
//}

//-(void)bleDidConnect
//{
//    [self updateLastDevice:[SENUtilities getUUIDString:CFBridgingRetain(self.bleShield.activePeripheral.identifier)] withName:@"BLE Mini"];
//    [self showButtons:@"Connected"];
//}

//-(void) bleDidUpdateRSSI:(NSNumber *)rssi
//{
//    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
//}


#pragma mark - RFDUINO
//- (void)didReceive:(NSData *)data
//{
////    NSLog(@"ReceivedData");
//    unsigned char *value = [data bytes];
//    int length = [data length];
//    [self processBluetoothData:value length:length];
//}

//- (void)updateLastDevice:(NSString *)uuid withName:(NSString *)name
//{
//    self.lastUUID = uuid;
//    self.lastName = name;
//    [[NSUserDefaults standardUserDefaults] setObject:self.lastName forKey:NamePrefKey];
//    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    self.uuidLabel.text = self.lastName;
//}

#pragma mark - TableView

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.discoveredPeripherals.count;
//    NSLog(@"%lu discovered peripherals",(unsigned long)self.discoveredPeripherals.count);
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return @"Available Devices";
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *tableIdentifier = @"BLEDeviceList";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier forIndexPath:indexPath];
//    if ([self.discoveredPeripherals count] > 0) {
//        CBPeripheral *peripheral = [self.discoveredPeripherals objectAtIndex:indexPath.row];
//        cell.textLabel.text = peripheral.identifier.UUIDString;
//    } else {
//        cell.textLabel.text = @"";
//    }
//    return cell;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
////    [self didSelected:indexPath.row];
////    NSLog(@"picked %ld",(long)indexPath.row);
////    [self addMessageText:@"picked"];
////    [self showButtons:@"Picked Device From List"];
//}

//- (void)checkIntervalTime
//{
//    if (self.connected) {
//        CFTimeInterval frameDuration = CFAbsoluteTimeGetCurrent() - self.previousTimestamp;
//        NSLog(@"Frame duration: %f", frameDuration);
//        //        if (frameDuration > 5) {
//        //            [self showButtons:@"Connected but no ibi data"];
//        //        }
//    }
//}

@end
