//
//  SENSettingsItem.h
//  BrightHeartsUIExperiment
//
//  Created by Jason McDermott on 11/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENSettingsItem : NSObject

@property (strong, nonatomic) NSString *itemName;
@property (nonatomic) BOOL selected;
@property (strong, nonatomic) NSString *textContent;

@end
