//
//  SENPDDriver.h
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENPDDriver : NSObject

-(void) startSession;
-(void) endSession;
-(void) rawPulse;
-(void) sendtoPDBaseReliability:(int) signal;
-(void) sendIBI:(int) signal;

@end
