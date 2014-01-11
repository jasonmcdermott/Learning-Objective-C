//
//  APAppDelegate.h
//  APDynamicTableLayout
//
//  Created by Adam Talcott on 3/15/12.
//  Copyright (c) 2012 Atomic Powered. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APSharingTableViewController;

@interface APAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) APSharingTableViewController *viewController;

@end
