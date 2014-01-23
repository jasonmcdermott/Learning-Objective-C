//
//  SENXmlDataGenerator.h
//  HPV
//
//  Created by Jason McDermott on 23/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SENSessionData.h"
#include <pthread.h>
#import "SENIBIData.h"
#import "SENPulseReliability.h"
#import "SENAppDelegate.h"


@interface SENXmlDataGenerator : NSObject
{
    SENSessionData *current_session;
    NSMutableString* write_buffer;
    pthread_mutex_t file_delete_mutex;
}

@property (strong,nonatomic) NSString *xmlPath;

-(Boolean) generateXML:(SENSessionData*)session filename: (NSString*)filename;

-(Boolean) createDataFolder;

-(NSString*) readXMLFile:(NSString*)filename;
-(Boolean)sendUnsentSesions;
@end
