//
//  SENViewController.m
//  tableView
//
//  Created by Jason McDermott on 10/02/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENViewController.h"

@interface SENViewController ()
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation SENViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
//    return self.mDevices.count;
//    NSLog(@"%lu",(unsigned long)self.mDevices.count);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Available Devices";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"Table";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier forIndexPath:indexPath];
    cell.textLabel.text = @"text";
    
    //    NSLog(@"is this doing anything?");
    //    for (int i=0;i<[self.mDeviceDictionary count];i++) {
    //        if (indexPath.row == i) {
    //            cell.textLabel.text = [self.mDeviceDictionary objectForKey:@"deviceName"];
    //            NSLog(@"%@",[self.mDeviceDictionary objectForKey:@"deviceName"]);
    //        }
    //    }
    //
    //    NSArray *keyArray =  [self.mDeviceDictionary allKeys];
    //    int count = [keyArray count];
    //    for (int i=0; i < count; i++) {
    //        NSDictionary *tmp = [self.mDeviceDictionary objectForKey:[ keyArray objectAtIndex:i]];
    //        for (id key in tmp) {
    //            NSLog(@"key: %@, value: %@ \n", key, [tmp objectForKey:key]);
    //        }
    //        if (i == indexPath.row) {
    //            NSLog(@"row row your boat");
    //        }
    //    }
    
    
    //    NSLog(@"key is status, value is %@",[self.mDeviceDictionary objectForKey:@"name"]);
    
    //    for (id device in self.mDeviceDictionary) {
    //        NSNumber *aggregatedArrayIndex = [self.mDeviceDictionary objectForKey:@"aggregatedArrayIndex"];
    //        if (indexPath.row == [aggregatedArrayIndex integerValue]) {
    //            NSString *deviceType = [self.mDeviceDictionary objectForKey:@"deviceType"];
    //            NSLog(@"%@, %ld",deviceType, (long)indexPath.row);
    //            cell.textLabel.text = deviceType;
    //        }
    //    }
    //    for (int i=0;i<[self.knownDevices count];i++) {
    //        if ([[self.mDevices objectAtIndex:indexPath.row] isEqualToString:[self.knownDevices objectAtIndex:i]]){
    //            cell.textLabel.text = [self.deviceAliases objectAtIndex:i];
    //        } else {
    //            cell.textLabel.text = @"New Sensor Device";
    //            cell.textLabel.text = [self.mDevices objectAtIndex:i]; // for the time being
    //        }
    //    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self didSelected:indexPath.row];
    NSLog(@"picked %ld",(long)indexPath.row);
//    [self addMessageText:@"picked"];
//    [self showButtons:@"Picked Device From List"];
}


@end
