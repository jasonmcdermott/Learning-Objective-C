//
//  SENBLESessionData.m
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENBLESessionData.h"
#import "SENIBIData.h"
#import "SENPulseReliability.h"

@implementation SENBLESessionData

-(id)init
{
    self = [super init];
    self.mIBIList = [[NSMutableArray alloc] init];
    self.mReliabilityList = [[NSMutableArray alloc] init];
    
    return self;
}


//-(void)dealloc
//{
//    [self clearSesionLists];
//    [_mSesionEnd release];
//    [_mIBIList release];
//    [_mReliabilityList release];
//    [_mSesionStart release];
//    [_mDeviceID release];
//    [_mUsername release];
//    
//    [super dealloc];
//}

//Add the IBI intervl to our list
-(void) addIbi:(int) interval
{
    // create and store an IBI data to our list
    SENIBIData* ibi_data = [[SENIBIData alloc] initWithValues :ibi_index ibi:interval];
    [_mIBIList addObject:ibi_data];
    
    ibi_index++;
}

// Add relibility to our list
-(void)addReliability:(Boolean)reliability
{
    // Store our reliability
    SENPulseReliability* reliabile = [[SENPulseReliability alloc] initWithValues :reliability];
    [_mReliabilityList addObject:reliabile];
}

//Clear all our session data
- (void)clearSesionLists
{
    for (int i = 0; i < _mIBIList.count; i++)
    {
//        [[_mIBIList objectAtIndex:i] release];
    }
    
    [_mIBIList removeAllObjects];
    
    for (int i = 0; i < _mReliabilityList.count; i++)
    {
//        [[_mReliabilityList objectAtIndex:i] release];
    }
    
    [_mReliabilityList removeAllObjects];
    
    ibi_index = 0;
}

-(void)setStartSesion
{
//    [_mSesionStart release];
    _mSesionStart = [[NSDate alloc]init];
}

-(void)setSessionEnd
{
//    [_mSesionEnd release];
    _mSesionEnd = [[NSDate alloc]init];
}

@end
