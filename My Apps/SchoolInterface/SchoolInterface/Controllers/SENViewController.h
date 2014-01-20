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
#import "RBLMainViewController.h"
#import "SENQuestionnaireTabViewController.h"
#import "SENUserDefaultsHelper.h"

#include "SENPDDriver.h"

@interface SENViewController : UIViewController <BLEDelegate, RBLMainViewControllerDelegate>
{
    
}

@property (strong, nonatomic) SENUserDefaultsHelper *SENUserDefaultsHelper;
@property (strong, nonatomic) BLE *bleShield;
@property (nonatomic) BOOL showQuestionnaire;

@property (strong, nonatomic) RBLMainViewController *RBLMainViewController;
@property (strong, nonatomic) SENQuestionnaireTabViewController *questionnaireViewController;


@end
