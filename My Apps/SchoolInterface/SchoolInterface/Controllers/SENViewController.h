//
//  SENGraphicsViewController.h
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "constants.h"
#import "SENPDDriver.h"
#import "BLEDevice.h"
#import "SENQuestionnaireTabViewController.h"
#import "SENUserDefaultsHelper.h"


#include "SENPDDriver.h"

@interface SENViewController : UIViewController <BLEDelegate, BLEDeviceDelegate>
{
    
}

@property (strong, nonatomic) SENUserDefaultsHelper *SENUserDefaultsHelper;
@property (strong, nonatomic) BLE *bleShield;

@property (strong, nonatomic) BLEDevice *BLEDevice;
@property (strong, nonatomic) SENQuestionnaireTabViewController *questionnaireViewController;
@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) SENUtilities *utilities;

@end
