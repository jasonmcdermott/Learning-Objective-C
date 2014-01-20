//
//  SENPulseReliability.h
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENPulseReliability : NSObject
{
    Boolean _reliable;
    NSDate* _timestamp;
    
}

-(id) initWithValues:(Boolean) reliable;
-(int)getReliability;
-(NSDate*) getTimestamp;

@end
