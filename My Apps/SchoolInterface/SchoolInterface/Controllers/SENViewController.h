//
//  SENGraphicsViewController.h
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>

#import "BLE.h"
#import "SENConstants.h"
#import "SENPDDriver.h"
#import "BLEDevice.h"
#import "SENQuestionnaireTabViewController.h"
#import "SENUserDefaultsHelper.h"
#import "SENRing.h"
#import "SENUtilities.h"
#include "SENPDDriver.h"
#import "SENPulseTracker.h"

#import "PdBase.h"
#import "PdAudioController.h"
//#import "PdDispatcher.h"
//#import "SampleListener.h"


//@interface SENViewController : UIViewController <BLEDelegate, BLEDeviceDelegate, GLKViewDelegate, QuestionnaireDelegate, PdReceiverDelegate>
@interface SENViewController : UIViewController <BLEDelegate, GLKViewDelegate, QuestionnaireDelegate, PdReceiverDelegate>
{
    
}

@property (strong, nonatomic) SENUserDefaultsHelper *SENUserDefaultsHelper;
//@property (strong, nonatomic) BLE *bleShield;

//@property (strong, nonatomic) BLEDevice *BLEDevice;
@property (strong, nonatomic) SENQuestionnaireTabViewController *questionnaireViewController;
@property (strong, nonatomic) NSString *appID;

@property (strong, nonatomic) SENPulseTracker *pulseTracker;

@property (strong, nonatomic) NSMutableArray *rings;
@property (nonatomic) BOOL glviewIsDisplaying;
@property (strong, nonatomic) CADisplayLink *link;
//@property (strong, nonatomic) PdDispatcher *dispatcher;
@property (nonatomic, retain) PdAudioController *audioController;

@property (strong, nonatomic) UIStoryboard *storyboard;

@end


