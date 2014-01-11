//
//  APSharingTableViewController.m
//  APDynamicTableLayout
//
//  Created by Adam Talcott on 3/15/12.
//  Copyright (c) 2012 Atomic Powered. All rights reserved.
//

#import "APSharingTableViewController.h"

#import "APSharingEngine.h"

@interface APSharingTableViewController ()

- (void)computeTableViewSectionsAndRows;

@end

@implementation APSharingTableViewController

@synthesize tableView = _tableView;
@synthesize facebookSwitch = _facebookSwitch;
@synthesize googlePlusSwitch = _googlePlusSwitch;
@synthesize twitterSwitch = _twitterSwitch;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    APSharingEngine *sharingEngine = [APSharingEngine sharedInstance];
    self.facebookSwitch.on = sharingEngine.isFacebookAvailable;
    self.googlePlusSwitch.on = sharingEngine.isGooglePlusAvailable;
    self.twitterSwitch.on = sharingEngine.isTwitterAvailable;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark Private Instance Methods

- (void)computeTableViewSectionsAndRows
{
    numberOfSections = 0;
    
    socialNetworksSectionNumber = ([APSharingEngine sharedInstance].areSocialNetworksAvailable ? numberOfSections++ : NSNotFound);
    socialNetworksSectionNumberOfRows = 0;
    socialNetworksFacebookRowNumber = ([APSharingEngine sharedInstance].isFacebookAvailable ? socialNetworksSectionNumberOfRows++ : NSNotFound);
    socialNetworksGooglePlusRowNumber = ([APSharingEngine sharedInstance]. isGooglePlusAvailable ? socialNetworksSectionNumberOfRows++ : NSNotFound);
    socialNetworksTwitterRowNumber = ([APSharingEngine sharedInstance].isTwitterAvailable ? socialNetworksSectionNumberOfRows++ : NSNotFound);
    
    emailSectionNumber = numberOfSections++;
    emailSectionNumberOfRows = 0;
    emailSectionGmailRowNumber = emailSectionNumberOfRows++;
    emailSectionYahooRowNumber = emailSectionNumberOfRows++;
}

#pragma mark -
#pragma mark Action Methods

- (IBAction)handleDidChangeValueOfSwitch:(UISwitch *)theSwitch
{
    APSharingEngine *sharingEngine = [APSharingEngine sharedInstance];
    
    if ( theSwitch == self.facebookSwitch ) {
        
        sharingEngine.facebookAvailable = self.facebookSwitch.on;
        
    } else if ( theSwitch == self.googlePlusSwitch ) {
        
        sharingEngine.googlePlusAvailable = self.googlePlusSwitch.on;
        
    } else if ( theSwitch == self.twitterSwitch ) {
        
        sharingEngine.twitterAvailable = self.twitterSwitch.on;
    }
    
    [self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [self computeTableViewSectionsAndRows];
    return numberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titleForHeaderInSection = nil;
    
    if ( section == socialNetworksSectionNumber ) {
        
        titleForHeaderInSection = @"Social Networks";
        
    } else if ( section == emailSectionNumber ) {
        
        titleForHeaderInSection = @"Email";
    }
    
    return titleForHeaderInSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    if ( section == socialNetworksSectionNumber ) {
        
        numberOfRowsInSection = socialNetworksSectionNumberOfRows;
        
    } else if ( section == emailSectionNumber ) {
        
        numberOfRowsInSection = emailSectionNumberOfRows;
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure cell here
    if ( indexPath.section == socialNetworksSectionNumber ) {
        
        if ( indexPath.row == socialNetworksFacebookRowNumber ) {
            
            cell.textLabel.text = @"Facebook";
            
        } else if ( indexPath.row == socialNetworksGooglePlusRowNumber ) {
            
            cell.textLabel.text = @"Google+";
            
        } else if ( indexPath.row == socialNetworksTwitterRowNumber ) {
            
            cell.textLabel.text = @"Twitter";
        }
        
    } else if ( indexPath.section == emailSectionNumber ) {
        
        if ( indexPath.row == emailSectionGmailRowNumber ) {
            
            cell.textLabel.text = @"Gmail";
            
        } else if ( indexPath.row == emailSectionYahooRowNumber ) {
            
            cell.textLabel.text = @"Yahoo!";
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
