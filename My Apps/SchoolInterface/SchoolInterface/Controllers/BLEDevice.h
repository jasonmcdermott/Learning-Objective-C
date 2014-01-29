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

typedef struct
{
    unsigned char data [4];
}charbuff;

@protocol BLEDeviceDelegate <NSObject>

- (void) setLabel:(NSString *)label;
- (void) startGLView;

@end

@interface BLEDevice : UIViewController <BLEDelegate>
{
//    SENPDDriver *mPDDRiver;
//    BLE *bleShield;
    bool isFindingLast;
    volatile unsigned _bufferIndex;
    charbuff _oemBuffer;
    volatile unsigned _inactivityCount;
    unsigned _max_inactivity;
    volatile bool _started;
    volatile bool _reliable;
}

@property (nonatomic, weak) id <BLEDeviceDelegate> delegate;

//- (void)showAll;

@property (strong, nonatomic) SENPDDriver *mPDDRiver;

@property (nonatomic) BOOL passedToParent;
@property (strong, nonatomic) BLE *bleShield;
@property (strong,nonatomic) NSString *username;
@property (strong, nonatomic) NSArray *knownDevices;
@property (strong, nonatomic) NSArray *deviceAliases;

@property (strong,nonatomic) NSMutableArray *mDevices;
@property (strong,nonatomic) NSString *lastUUID;
@property (strong, nonatomic) SENSessionData * mSesionData;

@property (retain, nonatomic) IBOutlet UITextField *sessionStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *sessionStartLabel;
@property (retain, nonatomic) IBOutlet UITextField *usernameLabel;
@property (retain, nonatomic) IBOutlet UITextField *intervalLabel;

@property (retain, nonatomic) IBOutlet UIButton *generateButton;

@end