//
//  RBLMainViewController.h
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "BLE.h"
//#import "SENXmlDataGenerator.h"
#import "SENSessionData.h"
#import "SENPDDriver.h"

#import "SENConstants.h"

#import <CoreBluetooth/CoreBluetooth.h>

#import "RFduinoManager.h"
#import "RFduino.h"

#import "SENUtilities.h"
#include "Nickname.h"

#define HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define HRM_ENABLE_SERVICE_UUID @"2A39"
#define HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define HRM_BODY_LOCATION_UUID @"2A38"
#define HRM_MANUFACTURER_NAME_UUID @"2A29"

#define RBL_SERVICE_UUID                         "713D0000-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_TX_UUID                         "713D0002-503E-4C75-BA94-3148F18D941E"
#define RBL_CHAR_RX_UUID                         "713D0003-503E-4C75-BA94-3148F18D941E"

#define BT_NOTIFICATION_PULSE @"bt_pulse_notification"
#define BT_NOTIFICATION_HR_DATA @"bt_hr_data_notification"

//@class RFduinoManager;
//@class RFduino;


typedef struct
{
    unsigned char data [4];
}charbuff;

//@protocol BTPulseTrackerDelegate;
@protocol BLEDeviceDelegate;

@interface BLEDevice : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    int counter, BTLECounter, scannedDevices;
    volatile unsigned _bufferIndex;
    charbuff _oemBuffer;
    volatile unsigned _inactivityCount;
    unsigned _max_inactivity;
    volatile bool _started;
    volatile bool _reliable;
}

@property (nonatomic, weak) id <BLEDeviceDelegate> delegate;

#pragma mark - pulse logic code
 @property (strong) NSTimer *pulseTimer;
@property (assign) BOOL autoConnect;

typedef enum {
    kConnectBestSignalMode = 0,
    kConnectUUIDMode = 1
} BTPulseTrackerConnectMode;

typedef enum {
    BTPulseTrackerScanState = 0,
    BTPulseTrackerConnectingState = 1,
    BTPulseTrackerConnectedState = 2,
    BTPulseTrackerStoppedState = 3
} BTPulseTrackerState;

@property BTPulseTrackerConnectMode connectMode;
@property (strong, nonatomic) NSString *connectIdentifer;
@property double lastStateChangeTime;
@property (nonatomic) BTPulseTrackerState state;

@property (readonly) NSString *connectionStatus;
@property (readonly) NSString *connectionStatusWithDuration;
@property (readonly) NSString *receivedStatusWithDuration;

@property (readonly) NSString *peripheralNickname;
@property (copy) NSString *manufacturer;

@property (assign) double heartRate;
@property (assign) double r2r;
@property (assign) double lastBeatTime;
@property (assign) BOOL lastBeatTimeValid;
@property (readonly) BOOL connected;
@property double lastHRDataReceived;
@property BOOL waitingForBestRSSI;
@property double bestRSSI;
@property (strong) CBPeripheral *bestPeripheral;
@property (strong) NSMutableArray *discoveredPeripherals;


- (void)tryConnect;
- (void)disconnect;
- (BOOL)checkBluetooth;

@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;

#pragma mark - Necessary

@property (strong, nonatomic) SENPDDriver *mPDDRiver;
@property (nonatomic) BOOL showTable;

#pragma mark - old BLE code. Not sure if necessary


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
//@property (nonatomic, retain) NSTimer    *pulseTimer;

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error;

// Instance methods to grab device Manufacturer Name, Body Location
- (void) getManufacturerName:(CBCharacteristic *)characteristic;
- (void) getBodyLocation:(CBCharacteristic *)characteristic;
@property (strong, nonatomic) NSMutableArray *BTLEDevices;


//@property(strong, nonatomic) RFduino *connected_rfduino;
//@property (strong, nonatomic) RFduinoManager *rfduinoManager;
//@property (strong, nonatomic) BLE *bleShield;



@property (strong, nonatomic) NSMutableDictionary *mDeviceDictionary;
@property (nonatomic) BOOL scanning, scanForNewDevices, finishedScan, disconnected, passedToParent;
@property (strong, nonatomic) NSArray *deviceAliases, *knownDevices;
@property (strong,nonatomic) NSMutableArray *mDevices, *mDeviceTypes, *mDeviceNames;
@property (strong,nonatomic) NSString *username, *lastUUID, *lastName;
@property (strong, nonatomic) SENSessionData * mSesionData;

@property (retain, nonatomic) IBOutlet UITextField *sessionStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *sessionStartLabel;
@property (retain, nonatomic) IBOutlet UITextField *usernameLabel;
@property (retain, nonatomic) IBOutlet UITextField *intervalLabel;

@property (nonatomic) CFTimeInterval previousTimestamp;
@property (strong, nonatomic) NSMutableArray *tempDevices;
@property (strong, nonatomic) NSMutableString *statusString;

@end


@protocol BLEDeviceDelegate <NSObject>

- (void) setLabel:(NSString *)label;
- (void) startGLView;
- (void)onPulseTrackerNoBluetooth:(BLEDevice *)aTracker reason:(NSString *)reason;
- (void)onPulseTrackerConnected:(BLEDevice *)aTracker;
- (void)onPulseTrackerDisconnected:(BLEDevice *)aTracker;
- (void)onPulse:(BLEDevice *)aTracker;

@end
