//
//  SENIBIData.m
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENIBIData.h"

@implementation SENIBIData
-(id) initWithValues:(int) index  ibi:(int)ibi
{
    self = [super init];
    _index = index;
    _ibi = ibi;
    _timestamp = [[NSDate alloc] init];
    return self;
}

-(int)getIndex
{
    return _index;
}

-(int)getibi
{
    return _ibi;
}

-(NSDate*) getTimestamp
{
    return _timestamp;
}

@end
