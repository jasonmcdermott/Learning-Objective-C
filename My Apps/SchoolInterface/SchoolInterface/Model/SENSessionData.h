//
//  SENBLESessionData.h
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENBLESessionData : NSObject
{
    int ibi_index;
}

@property (strong, nonatomic) NSDate* mSesionStart;
@property (strong, nonatomic) NSDate* mSesionEnd;
@property (strong, nonatomic) NSString *mUsername;
@property (strong, nonatomic) NSString* mDeviceID;

@property (strong,nonatomic) NSMutableArray *mIBIList;
@property (strong,nonatomic) NSMutableArray *mReliabilityList;

- (void)clearSesionLists;

-(void) addIbi:(int) interval;
-(void)addReliability:(Boolean)reliability;
-(void)setStartSesion;
-(void)setSessionEnd;

@end
