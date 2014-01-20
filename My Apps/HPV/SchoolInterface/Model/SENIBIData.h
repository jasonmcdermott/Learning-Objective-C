//
//  SENIBIData.h
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENIBIData : NSObject
{
    int _ibi;
    int _index;
    NSDate* _timestamp;
    
}

-(id) initWithValues:(int) index ibi:(int)ibi;
-(int)getIndex;
-(int)getibi;
-(NSDate*) getTimestamp;

@end
