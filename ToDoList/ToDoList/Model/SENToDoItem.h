//
//  SENToDoItem.h
//  ToDoList
//
//  Created by Jason McDermott on 9/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENToDoItem : NSObject

@property (strong, nonatomic) NSString *itemName;
@property (nonatomic) BOOL completed;
@property (readonly) NSDate *creationDate;

- (void)markAsCompleted:(BOOL)isComplete;

@end
