//
//  SENPulseReliability.m
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENPulseReliability.h"

@implementation SENPulseReliability

//-(void)dealloc
//{
//    [_timestamp release];
//    [super dealloc];
//}

-(id) initWithValues:(Boolean) reliable
{
    self = [super init];
    
    _reliable = reliable;
    _timestamp = [[NSDate alloc] init];
    return self;
}

-(int)getReliability
{
    if(_reliable)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

-(NSDate*) getTimestamp
{
    return _timestamp;
}

@end
