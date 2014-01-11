//
//  APSharingTableViewController.h
//  APDynamicTableLayout
//
//  Created by Adam Talcott on 3/15/12.
//  Copyright (c) 2012 Atomic Powered. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APSharingTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSInteger numberOfSections;
    
    NSInteger socialNetworksSectionNumber;
    NSInteger socialNetworksSectionNumberOfRows;
    NSInteger socialNetworksFacebookRowNumber;
    NSInteger socialNetworksGooglePlusRowNumber;
    NSInteger socialNetworksTwitterRowNumber;
    
    NSInteger emailSectionNumber;
    NSInteger emailSectionNumberOfRows;
    NSInteger emailSectionGmailRowNumber;
    NSInteger emailSectionYahooRowNumber;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *googlePlusSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *twitterSwitch;

- (IBAction)handleDidChangeValueOfSwitch:(UISwitch *)theSwitch;

@end
