//
//  Person.h
//  Saving Objects to Files
//
//  Created by Vandad Nahavandipoor on 13/08/2012.
//  Copyright (c) 2012 Pixolity Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject <NSCoding>

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@end
