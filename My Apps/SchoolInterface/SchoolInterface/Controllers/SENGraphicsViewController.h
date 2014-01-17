//
//  SENGraphicsViewController.h
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "RBLDetailViewController.h"
#import "SENPDDriver.h"
#import "RBLMainViewController.h"

#include "SENPDDriver.h"

@interface SENGraphicsViewController : UIViewController <BLEDelegate>
{
    
    
}

@property (strong, nonatomic) BLE *bleShield;

@property (strong, nonatomic) RBLMainViewController *RBLMainViewController;
@property (strong, nonatomic) UITabBarController *tabBar;

//@property (strong, nonatomic) UIViewController *RBLMainViewController;

@end
