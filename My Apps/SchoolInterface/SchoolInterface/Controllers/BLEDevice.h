//
//  RBLMainViewController.h
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BLE.h"
#import "SENSessionData.h"
#import "SENPDDriver.h"
#import "SENXmlDataGenerator.h"
#import "constants.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "RFduinoManager.h"
#import "RFduino.h"

#import "SENUtilities.h"

#define HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define HRM_ENABLE_SERVICE_UUID @"2A39"
#define HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define HRM_BODY_LOCATION_UUID @"2A38"
#define HRM_MANUFACTURER_NAME_UUID @"2A29"

@class RFduinoManager;
@class RFduino;


typedef struct
{
    unsigned char data [4];
}charbuff;

@protocol BLEDeviceDelegate <NSObject>

- (void) setLabel:(NSString *)label;
- (void) startGLView;

@end

@interface BLEDevice : UIViewController <BLEDelegate, RFduinoManagerDelegate, RFduinoDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    int counter, BTLECounter, scannedDevices;
    volatile unsigned _bufferIndex;
    charbuff _oemBuffer;
    volatile unsigned _inactivityCount;
    unsigned _max_inactivity;
    volatile bool _started;
    volatile bool _reliable;
}

@property (nonatomic, strong) CBCentralManager *BTLEcentralManager;
@property (nonatomic, strong) CBPeripheral     *heartRateMonitorPeripheral;

// Properties to hold data characteristics for the peripheral device
@property (nonatomic, strong) NSString   *BTLEconnected;
@property (nonatomic, strong) NSString   *BTLEbodyData;
@property (nonatomic, strong) NSString   *BTLEmanufacturer;
@property (nonatomic, strong) NSString   *BTLEdeviceData;
@property (assign) uint16_t BTLEheartRate;
@property (strong, nonatomic) CBPeripheral *BTLEPeripheral;
@property (nonatomic) BOOL BTLEConnectionFlag;

// Properties to handle storing the BPM and heart beat
@property (nonatomic, strong) UILabel    *heartRateBPM;
@property (nonatomic, retain) NSTimer    *pulseTimer;

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error;

// Instance methods to grab device Manufacturer Name, Body Location
- (void) getManufacturerName:(CBCharacteristic *)characteristic;
- (void) getBodyLocation:(CBCharacteristic *)characteristic;
@property (strong, nonatomic) NSMutableArray *BTLEDevices;

@property (nonatomic, weak) id <BLEDeviceDelegate> delegate;

@property(strong, nonatomic) RFduino *connected_rfduino;
@property (strong, nonatomic) RFduinoManager *rfduinoManager;

@property (strong, nonatomic) SENPDDriver *mPDDRiver;

@property (strong, nonatomic) NSMutableDictionary *mDeviceDictionary;

@property (nonatomic) BOOL scanning, connected, scanForNewDevices, finishedScan, disconnected, passedToParent;

@property (strong, nonatomic) BLE *bleShield;
@property (strong, nonatomic) NSArray *deviceAliases, *knownDevices;

@property (strong,nonatomic) NSMutableArray *mDevices, *mDeviceTypes, *mDeviceNames;

@property (strong,nonatomic) NSString *username, *lastUUID, *lastName;
@property (strong, nonatomic) SENSessionData * mSesionData;

@property (retain, nonatomic) IBOutlet UITextField *sessionStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *sessionStartLabel;
@property (retain, nonatomic) IBOutlet UITextField *usernameLabel;
@property (retain, nonatomic) IBOutlet UITextField *intervalLabel;

@property (nonatomic) CFTimeInterval previousTimestamp;
@end


