//
//  SENToDoItem.m
//  ToDoList
//
//  Created by Jason McDermott on 9/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENToDoItem.h"

@interface SENToDoItem()
@property NSDate *markedCompleteDate;

@end

@implementation SENToDoItem

- (void)markAsCompleted:(BOOL)isComplete
{
    self.completed = isComplete;
    [self setCompletionDate];
}


- (void)setCompletionDate
{
    if(self.completed) {
        self.markedCompleteDate = [NSDate date];
    } else {
        self.markedCompleteDate = nil;
    }
}

@end
