//
//  SENSettingsItem.m
//  BrightHeartsUIExperiment
//
//  Created by Jason McDermott on 11/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENSettingsItem.h"

@implementation SENSettingsItem

- (void)markAsSelected:(BOOL)isSelected
{
    self.selected = isSelected;
}

- (void)setTextContent:(NSString *)textContent
{
    self.textContent = textContent;
}

@end


