//
//  HRMViewController.h
//  HeartMonitor
//
//  Created by Steven F. Daniel on 30/11/13.
//  Copyright (c) 2013 GENIESOFT STUDIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>


#define HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define HRM_ENABLE_SERVICE_UUID @"2A39"
#define HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define HRM_BODY_LOCATION_UUID @"2A38"
#define HRM_MANUFACTURER_NAME_UUID @"2A29"


@interface HRMViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *heartRateMonitorPeripheral;

// Properties for our Object controls
@property (nonatomic, strong) IBOutlet UIImageView *heartImage;
@property (nonatomic, strong) IBOutlet UITextView  *deviceInfo;

// Properties to hold data characteristics for the peripheral device
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, strong) NSString   *bodyData;
@property (nonatomic, strong) NSString   *manufacturer;
@property (nonatomic, strong) NSString   *deviceData;
@property (assign) uint16_t heartRate;

// Properties to handle storing the BPM and heart beat
@property (nonatomic, strong) UILabel    *heartRateBPM;
@property (nonatomic, retain) NSTimer    *pulseTimer;

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error;

// Instance methods to grab device Manufacturer Name, Body Location
- (void) getManufacturerName:(CBCharacteristic *)characteristic;
- (void) getBodyLocation:(CBCharacteristic *)characteristic;

// Instance method to perform heart beat animations
- (void) doHeartBeat;

@end