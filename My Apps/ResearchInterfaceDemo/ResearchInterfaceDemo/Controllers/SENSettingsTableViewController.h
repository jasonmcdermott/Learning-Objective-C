//
//  StaticTableViewController.h
//  StaticTableViewDemo
//
//  Created by Marty Dill on 12-02-28.
//  Copyright (c) 2012 Marty Dill. All rights reserved.
//
#pragma once
#import <UIKit/UIKit.h>
#import "BLE.h"
#import "SENBluetoothConnectionViewController.h"


@interface SENSettingsTableViewController : UITableViewController <BLEDelegate, SENBluetoothConnectionViewControllerDelegate>
{
    BLE *bleShield;
    bool isFindingLast;
}

@property (strong,nonatomic) NSMutableArray *mDevices;
@property (strong,nonatomic) NSString *lastUUID;

@end
