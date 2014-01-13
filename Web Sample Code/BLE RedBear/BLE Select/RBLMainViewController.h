//
//  RBLMainViewController.h
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "RBLDetailViewController.h"

typedef struct
{
    unsigned char data [4];
}charbuff;


@interface RBLMainViewController : UIViewController <BLEDelegate, RBLDetailViewControllerDelegate>
{
    BLE *bleShield;
    bool isFindingLast;
    volatile unsigned _bufferIndex;
    charbuff _oemBuffer;
    volatile unsigned _inactivityCount;
    IBOutlet UILabel *intervalLabel;
    IBOutlet UILabel *sesionStatuLabel;
}

@property (strong,nonatomic) NSMutableArray *mDevices;
@property (strong,nonatomic) NSString *lastUUID;

- (IBAction)btnExit:(id)sender;

@end
