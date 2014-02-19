//
//  SENPulseTracker.h
//  HPV
//
//  Created by Jason McDermott on 18/02/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

#import "SENConstants.h"
#import "SENUtilities.h"

#define BT_NOTIFICATION_PULSE @"bt_pulse_notification"
#define BT_NOTIFICATION_HR_DATA @"bt_hr_data_notification"
#define UI_NOTIFICATION_STRING @"ui_notification_string"

@protocol SENPulseTrackerDelegate;

@interface SENPulseTracker : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (weak) id<SENPulseTrackerDelegate> delegate;  /// Delegate receives notifications on peripheral connection changes, as well as pulse changes.
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

typedef enum {
    scanModeAuto = 0,
    scanModePreviousDevice = 1,
    scanModeOff = 2
} scanMode;

@property scanMode mode;

@property BTPulseTrackerConnectMode connectMode;
@property (nonatomic) NSUUID *connectUUID;
@property (strong,nonatomic) NSString *lastUUID, *lastName;
@property (strong) CBPeripheral *lastPeripheral;

@property double lastStateChangeTime;
@property (nonatomic) BTPulseTrackerState state;

// TODO(rsargent): honor the "enabled" property
@property (nonatomic) BOOL enabled;

@property (nonatomic) BOOL heartbeatSoundEnabled;

@property (readonly) NSString *connectionStatus;
@property (readonly) NSString *connectionStatusWithDuration;
@property (readonly) NSString *receivedStatusWithDuration;
@property (readonly) BOOL connected;
@property (readonly) NSString *peripheralNickname;

@property (copy) NSString *manufacturer;

@property (assign) double heartRate;
@property (assign) double r2r;
@property (assign) double lastBeatTime;
@property (assign) BOOL lastBeatTimeValid;
@property double lastHRDataReceived;

- (void)tryConnect;
- (void)disconnect;
- (BOOL)checkBluetooth;
- (void)changeMode:(scanMode)mode;

@end


@protocol SENPulseTrackerDelegate <NSObject>
- (void)sendMessageForBLEInterface:(NSString *)string;
@optional
- (void)onPulseTrackerNoBluetooth:(SENPulseTracker *)aTracker reason:(NSString *)reason;
- (void)onPulseTrackerConnected:(SENPulseTracker *)aTracker;
- (void)onPulseTrackerDisconnected:(SENPulseTracker *)aTracker;
- (void)onPulse:(SENPulseTracker *)aTracker;
@end


