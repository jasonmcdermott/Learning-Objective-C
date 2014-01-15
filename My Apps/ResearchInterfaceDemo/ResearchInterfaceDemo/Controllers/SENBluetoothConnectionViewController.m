//
//  BluetoothConnectionViewController.m
//  StaticTableViewDemo
//
//  Created by Jason McDermott on 13/01/2014.
//  Copyright (c) 2014 Marty Dill. All rights reserved.
//

#import "SENBluetoothConnectionViewController.h"
#import "SENSettingsTableViewController.h"

@interface SENBluetoothConnectionViewController () {
    
}
@end

@implementation SENBluetoothConnectionViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.BLEDevices.count;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *tableIdentifier = @"Cell";
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier forIndexPath:indexPath];
//    cell.textLabel.text = [self.BLEDevices objectAtIndex:indexPath.row];
//    return cell;
    
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate didSelected:indexPath.row];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
