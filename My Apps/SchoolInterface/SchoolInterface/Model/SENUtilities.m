//
//  SENUtilities.m
//  HPV
//
//  Created by Jason McDermott on 24/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENUtilities.h"

@implementation SENUtilities

@synthesize school = _school;

- (NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (NSString*)getStringForKey:(NSString*)key
{
    NSString* val = @"";
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) val = [standardUserDefaults stringForKey:key];
    if (val == NULL) val = @"";
    return val;
}

- (void)setStringForKey:(NSString*)value withKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}


- (void)setIntForKey:(NSInteger)value withKey:(NSString*)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults)
    {
		[standardUserDefaults setInteger:value forKey:key];
		[standardUserDefaults synchronize];
	}
}


#pragma mark -
#pragma mark Methods Not Currently In Use

//- (void)readCoreDataStore
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
//                                    initWithEntityName:@"SENQuestionnaire"];
//    NSError *requestError = nil;
//    
//    /* And execute the fetch request on the context */
//    NSArray *questionnaires =
//    [self.managedObjectContext executeFetchRequest:fetchRequest
//                                             error:&requestError];
//    
//    /* Make sure we get the array */
//    if ([questionnaires count] > 0){
//        
//        /* Go through the persons array one by one */
//        NSUInteger counter = 1;
//        for (SENQuestionnaire *q in questionnaires) {
//            if ([q.writtenToDisk isEqualToString:@"YES"]){
//                // do nothing
//            } else {
//                NSLog(@"%lu age = %@",(unsigned long)counter,q.age);
//                NSLog(@"%lu birthDate = %@",(unsigned long)counter,q.birthDate);
//                NSLog(@"%lu gender = %@",(unsigned long)counter,q.gender);
//                NSLog(@"%lu school = %@",(unsigned long)counter,q.school);
//                NSLog(@"%lu uniqueID = %@",(unsigned long)counter,q.uniqueID);
//                NSLog(@"%lu vaccineTaken = %@",(unsigned long)counter,q.vaccineTaken);
//                NSLog(@"%lu didTakeVaccine = %@",(unsigned long)counter,q.didTakeVaccine);
//                NSLog(@"%lu didTakeOtherVaccine = %@",(unsigned long)counter,q.didTakeOtherVaccine);
//                NSLog(@"%lu submittedDateTime = %@",(unsigned long)counter,q.submittedDateTime);
//                
//                [self writeDictionaryToDisk:q];
//                q.writtenToDisk = @"YES";
//                NSLog(@"logged");
//            }
//            counter++;
//        }
//    } else {
//        NSLog(@"Could not find any Person entities in the context.");
//    }
//}

//- (void)writeDictionaryToDisk:(SENQuestionnaire *)q
//{
//    
//    NSDictionary *questionnaireDictionary =
//    @{
//      @"uniqueID" : q.uniqueID,
//      @"age" : q.age,
//      @"birthDate" : q.birthDate,
//      @"didTakeOtherVaccine" : q.didTakeOtherVaccine,
//      @"didTakeVaccine" : q.didTakeVaccine,
//      @"vaccineTaken" : q.vaccineTaken,
//      @"gender" : q.gender,
//      @"school" : q.school,
//      @"submittedDateTime" : q.submittedDateTime,
//      };
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//    
//    NSString *doc = [basePath stringByAppendingString:@"/"];
//    NSString *file = [doc stringByAppendingString:q.uniqueID];
//    NSString *filePath = [file stringByAppendingString:@".plist"];
//    
//    // plistDict is a NSDictionary
//    NSString *error;
//    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:questionnaireDictionary
//                                                                   format:NSPropertyListXMLFormat_v1_0
//                                                         errorDescription:&error];
//    if(plistData) {
//        [plistData writeToFile:filePath atomically:YES];
//    } else {
//        NSLog(@"%@",error);
//    }
//}

-(NSString*)readXMLFile:(NSString *)file
{
    // function not in use
    NSString *docFile = file;
    NSFileManager *filemgr;
    NSData *databuffer;
    filemgr = [NSFileManager defaultManager];
    databuffer = [filemgr contentsAtPath: docFile];
    return [[NSString alloc] initWithData:databuffer encoding:NSUTF16StringEncoding];
    NSString *a = @"";
    return a;
}

- (void)convertDictionaryToJSON:(NSDictionary *)dict
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:dict
                        options:NSJSONWritingPrettyPrinted
                        error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        
        NSLog(@"Successfully serialized the dictionary into data.");
        NSString *jsonString =
        [[NSString alloc] initWithData:jsonData
                              encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String = %@", jsonString);
    }
    else if ([jsonData length] == 0 && error == nil){
        NSLog(@"No data was returned after serialization.");
    }
    else if (error != nil){
        NSLog(@"An error happened = %@", error);
    }
}


@end
