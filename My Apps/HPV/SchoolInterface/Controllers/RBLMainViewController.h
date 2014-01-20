//
//  RBLMainViewController.h
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BLE.h"
//#import "RBLDetailViewController.h"
#import "SENPDDriver.h"
#import "SENBLESessionData.h"

#include "SENPDDriver.h"

typedef struct
{
    unsigned char data [4];
}charbuff;

@protocol RBLMainViewControllerDelegate <NSObject>

- (void) setLabel:(NSString *)label;

@end



@interface RBLMainViewController : UIViewController <BLEDelegate>
{
    SENPDDriver *mPDDRiver;
//    BLE *bleShield;
    bool isFindingLast;
    volatile unsigned _bufferIndex;
    charbuff _oemBuffer;
    volatile unsigned _inactivityCount;
    unsigned _max_inactivity;
    volatile bool _started;
    volatile bool _reliable;
}

@property (nonatomic, weak) id <RBLMainViewControllerDelegate> delegate;

//- (void)showAll;

@property (nonatomic) BOOL passedToParent;
@property (strong, nonatomic) BLE *bleShield;
@property (strong,nonatomic) NSString *username;

@property (strong,nonatomic) NSMutableArray *mDevices;
@property (strong,nonatomic) NSString *lastUUID;

@property (retain, nonatomic) IBOutlet UITextField *sessionStatusLabel;
@property (retain, nonatomic) IBOutlet UILabel *sessionStartLabel;
@property (retain, nonatomic) IBOutlet UITextField *usernameLabel;
@property (retain, nonatomic) IBOutlet UITextField *intervalLabel;

@property (retain, nonatomic) IBOutlet UIButton *generateButton;

@end