//
//  BluetoothConnectionViewController.h
//  StaticTableViewDemo
//
//  Created by Jason McDermott on 13/01/2014.
//  Copyright (c) 2014 Marty Dill. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SENBluetoothConnectionViewControllerDelegate <NSObject>

- (void) didSelected:(NSInteger)selected;

@end

@interface SENBluetoothConnectionViewController : UITableViewController
{
    int selected;
}

@property (strong,nonatomic) NSArray *BLEDevices;

@property (nonatomic, weak) id <SENBluetoothConnectionViewControllerDelegate> delegate;


@end
