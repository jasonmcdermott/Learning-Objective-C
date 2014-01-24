////
////  SENXmlDataGenerator.m
////  HPV
////
////  Created by Jason McDermott on 23/01/2014.
////  Copyright (c) 2014 Sensorium Health. All rights reserved.
////
//
//#import "SENXmlDataGenerator.h"
//
//@implementation SENXmlDataGenerator
//
//NSString * const  XML_START = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
//NSString * const DEVICE_SESSION = @"devicesession";
//NSString * const DEV_ID = @"dev_id";
//NSString * const USERNAME = @"username";
//
//NSString * const AGE = @"age";
//NSString * const LOCATION = @"location";
//NSString * const PROC_TYPE = @"proc_type";
//
//NSString * const TIMEZONE = @"timezone";
//NSString * const SESSION_START = @"session_start";
//NSString * const SESSION_END = @"session_end";
//NSString * const DATE = @"date";
//NSString * const TIME = @"time";
//NSString * const TAG_IBI = @"ibi";
//NSString * const BEAT = @"beat";
//NSString * const COUNT = @"count";
//NSString * const VALUE = @"value";
//NSString * const TIMESTAMP = @"timestamp";
//NSString * const STATUS = @"status";
//NSString * const SENSOR_RELIABILITY = @"sensor_reliability";
//NSString * const SERVER_SUCCESS = @"Success";
//
//NSString* const QUESTIONNAIRE = @"questionnaire";
//NSString* const PAIN = @"pain";
//NSString* const FEAR = @"fear";
//NSString* const FORMONE = @"form_one";
//NSString* const FORMTWO = @"form_two";
//NSString* const SURVEY = @"survey";
//
//const char* BRIGHTHEART_UPLOAD_HOST = "https://www.smartcontroller.com.au/brighthearts/upload.php";
//
//-(id)init
//{
//    self = [super init];
//    
//    pthread_mutex_init(&file_delete_mutex, NULL);
//    write_buffer = [[NSMutableString alloc] initWithCapacity:0x1000000];
//    
//    NSString* directory = GetApplicationDocumentsDirectory();
//    
//    _xmlPath = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:@"sensorium"]];
//    
//    return self;
//}
//
//NSString* GetApplicationDocumentsDirectory() {
//    static NSString* documentsDirectory = nil;
//    if (documentsDirectory == nil) {
//        documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                                   NSUserDomainMask,
//                                                                   YES)
//                               objectAtIndex:0];
//    }
//    return documentsDirectory;
//}
//
//// Build text for the tag
//-(void)buildTagText:(NSString*) tag value:(NSString*) value
//{
//    [write_buffer appendString: [NSString stringWithFormat:@"\n<%@>%@</%@>", tag, value, tag]];
//}
//
//-(void)writeSesionText
//{
//    [self buildTagText:DEV_ID value:current_session.mDeviceID];
//    [self buildTagText:USERNAME value:current_session.mUsername];
////    [self buildTagText:AGE value:[current_session age]];
////    [self buildTagText:LOCATION value:[current_session location]];
////    [self buildTagText:PROC_TYPE value:[current_session proc_type]];
//    
//    NSDateFormatter *date_formater=[[NSDateFormatter alloc]init];
//    [date_formater setDateFormat:@"Z"];
//    NSString * tz=[date_formater stringFromDate:[NSDate date]];
//    
//    [self buildTagText:TIMEZONE value:tz];
//}
//
//
//-(void)writeDateTag:(NSDate*) date
//{
//    NSDateFormatter *date_formater=[[NSDateFormatter alloc]init];
//    [date_formater setDateFormat:@"d-MMM-yyyy"];
//    
//    NSString * text =[date_formater stringFromDate:date];
//    
//    [self buildTagText:DATE value:text];
//}
//
//-(void)writeTimeTag:(NSDate*) date
//{
//    NSDateFormatter *date_formater=[[NSDateFormatter alloc]init];
//    [date_formater setDateFormat:@"H:mm:ss.SSS"];
//    
//    NSString * text =[date_formater stringFromDate:date];
//    
//    [self buildTagText:TIME value:text];
//}
//
//-(void)writeSesionStart
//{
//    
//    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", SESSION_START]];
//    [self writeDateTag:current_session.mSesionStart];
//    [self writeTimeTag:current_session.mSesionStart];
//    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", SESSION_START]];
//    
//}
//
//-(void)writeSesionEnd
//{
//    
//    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", SESSION_END]];
//    [self writeDateTag:current_session.mSesionEnd];
//    [self writeTimeTag:current_session.mSesionEnd];
//    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", SESSION_END]];
//    
//}
//
//-(void) writeIBIData:(SENIBIData*)ibi
//{
//    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", BEAT]];
//    [self buildTagText:COUNT value:[NSString stringWithFormat:@"%d", ibi.getIndex]];
//    [self buildTagText:VALUE value:[NSString stringWithFormat:@"%d", ibi.getibi]];
//    [self writeTimeTag:ibi.getTimestamp];
//    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", BEAT]];
//}
//
//-(void) writeReliabilityData:(SENPulseReliability*)reliability
//{
//    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", SENSOR_RELIABILITY]];
//    [self buildTagText:VALUE value:[NSString stringWithFormat:@"%d", reliability.getReliability]];
//    [self writeTimeTag:reliability.getTimestamp];
//    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", SENSOR_RELIABILITY]];
//}
//
//-(void) writeIBIList
//{
//    NSMutableArray* ibi_list = current_session.mIBIList;
//    
//    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", TAG_IBI]];
//    
//    for (int i = 0; i < ibi_list.count; i++)
//    {
//        SENIBIData * current_ibi = [ibi_list objectAtIndex:i];
//        [self writeIBIData:current_ibi];
//    }
//    
//    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", TAG_IBI]];
//}
//
//-(void) writeReliabilityList
//{
//    NSMutableArray* reliability_list = current_session.mReliabilityList;
//    
//    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", STATUS]];
//    
//    for (int i = 0; i < reliability_list.count; i++)
//    {
//        SENPulseReliability * current_reliability = [reliability_list objectAtIndex:i];
//        [self writeReliabilityData:current_reliability];
//    }
//    
//    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>",STATUS]];
//}
//
//-(Boolean)createDataFolder
//{
//    static Boolean folder_created = false;
//    
//    if (!folder_created)
//    {
//        NSFileManager *filemgr;
//        
//        
//        filemgr =[NSFileManager defaultManager];
//        NSError * error = nil;
//        
//        [filemgr createDirectoryAtPath:self.xmlPath
//           withIntermediateDirectories:YES
//                            attributes:nil
//                                 error:&error];
//        if (error != nil) {
//            NSLog(@"error creating directory: %@", error);
//            //..
//        }
//        
//        else
//        {
//            folder_created = true;
//        }
//    }
//    
//    return folder_created;
//}
//
//
////-(NSString*)readXMLFile:(NSString *)filename
////{
////    NSString *docFile = [_xmlPath stringByAppendingPathComponent: filename];
////    
////    NSFileManager *filemgr;
////    NSData *databuffer;
////    
////    filemgr = [NSFileManager defaultManager];
////    
////    databuffer = [filemgr contentsAtPath: docFile];
////    
////    return [[NSString alloc] initWithData:databuffer encoding: nil];
////}
//
//-(NSArray *)listFileAtPath:(NSString *)path
//{
//    
//    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
//    
//    return directoryContent;
//}
//
//-(Boolean)sendUnsentSesions
//{
//    Boolean ret = false;
//    NSArray* file_list = [self listFileAtPath:_xmlPath];
//    int count;
//    
//    for (count = 0; count < (int)[file_list count]; count++)
//    {
//        NSMutableString* xml_text = [[NSMutableString alloc] initWithCapacity:0x1000000] ;
//        
//        NSString *next_file = [file_list objectAtIndex:count];
//        NSString * text = [self readXMLFile:next_file];
//        [xml_text setString:text ] ;
//        
//        NSLog(@"Send File: %@", next_file);
////        [self sendxmlToServer:xml_text filename:next_file];
//    }
//    
//    
//    return  ret;
//}
//
//-(void) doComplete:(NSString*)filename
//{
//    pthread_mutex_lock(&file_delete_mutex);
//    
//    NSString *target_file = [_xmlPath stringByAppendingPathComponent: filename];
//    
//    NSLog(@"Complete %@", filename);
//    
//    NSFileManager *filemgr;
//    
//    filemgr = [NSFileManager defaultManager];
//    
//    if ([filemgr removeItemAtPath:
//         target_file error: NULL]  == YES)
//        NSLog (@"Remove successful");
//    else
//        NSLog (@"Remove failed");
//    
//    pthread_mutex_unlock(&file_delete_mutex);
//    
//}
//
////-(void)sendxmlToServer:(NSMutableString*)text filename :(NSString*)filename
////{
////    Boolean ret = false;
////    // Network interaction code
////    // host is defined for the server hosting the PHP script to upload sessions
////    
////    NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
////    
////    NSString *hoststr = [[NSString alloc] initWithUTF8String:BRIGHTHEART_UPLOAD_HOST];
////    NSURL *url = [NSURL URLWithString:hoststr];
////    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
////    [request setPostValue: uuid forKey:@"uuid"];
////    
////    [request setPostValue:text forKey:@"datalog"];
////    
////    
////    [request setCompletionBlock:^{
////        // Use when fetching text data
////        NSString *responseString = [request responseString];
////        
////        NSLog(@"Response %@", responseString);
////        if ([responseString caseInsensitiveCompare:SERVER_SUCCESS] == NSOrderedSame)
////        {
////            [self doComplete:filename];
////        }
////        
////        // Use when fetching binary data
////        NSData *responseData = [request responseData];
////    }];
////    [request setFailedBlock:^{
////        NSError *error = [request error];
////        
////        NSLog(@" Error in sendxmlToServer %@", error);
////    }];
////    [request startAsynchronous];
////    
////    
////}
//
//-(Boolean)generateXML:(SENSessionData*)session filename:(NSString *)filename
//{
//    
//    [self createDataFolder];
//    current_session = session;
//    
//    //NSLog(_xmlPath);
//    
////    NSString *docFile = [_xmlPath stringByAppendingPathComponent: filename];
//    
//    // erase our buffer
//    [write_buffer setString:@""];
//    
//    [write_buffer appendString:XML_START];
//    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", DEVICE_SESSION]];
//    
//    [self writeSesionText];
//    [self writeSesionStart];
//    [self writeSesionEnd];
//    [self writeIBIList];
//    [self writeReliabilityList];
//    //questionnaire results
//    [self writeQuestionnaireResults];
//    
//    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", DEVICE_SESSION]];
////    [write_buffer writeToFile: docFile atomically: NO];
//    
////    [self sendxmlToServer:write_buffer filename:filename];
//    
//    NSLog(@"XML is %@" , write_buffer);
//    
//    return true;
//}
//
//-(void) writeQuestionnaireResults
//{
////    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", QUESTIONNAIRE]];
////    // The different forms have results stored in the appDelegate
////    SENAppDelegate *appDelegate = (SENAppDelegate *)[[UIApplication sharedApplication] delegate];
////    
////    //Pain
////    NSString *val = [NSString stringWithFormat:@"%d", appDelegate->pain_result];
////    [self buildTagText:PAIN value:val];
////    
////    //Fear
////    NSString *val2 = [NSString stringWithFormat:@"%d", appDelegate->fear_result];
////    [self buildTagText:FEAR value:val2];
////    
////    //Two forms, of 20 questions each
////    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", FORMONE]];
////    for (int i=0; i<20; i++) {
////        NSString *question_tag = [NSString stringWithFormat:@"question_%d", i+1];
////        NSString *answer = [NSString stringWithFormat:@"%d", appDelegate->form_one_results[i]];
////        [self buildTagText:question_tag value:answer];
////    }
////    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", FORMONE]];
////    
////    //second form
////    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", FORMTWO]];
////    for (int i=0; i<20; i++) {
////        NSString *question_tag = [NSString stringWithFormat:@"question_%d", i+1];
////        NSString *answer = [NSString stringWithFormat:@"%d", appDelegate->form_two_results[i]];
////        [self buildTagText:question_tag value:answer];
////    }
////    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", FORMTWO]];
////    
////    //Survey
////    [write_buffer appendString:[NSString stringWithFormat:@"\n<%@>", SURVEY]];
////    NSString *times_before = [NSString stringWithFormat:@"%d",appDelegate->times_before];
////    [self buildTagText:@"times_before" value:times_before];
////    
////    NSString *worried = [NSString stringWithFormat:@"%d",appDelegate->worried];
////    [self buildTagText:@"worried" value:worried];
////    
////    [self buildTagText:@"why_worried" value:appDelegate->why];
////    
////    NSString *help = [NSString stringWithFormat:@"%d",appDelegate->app_help];
////    [self buildTagText:@"app_help" value:help];
////    
////    [self buildTagText:@"like" value:appDelegate->like];
////    [self buildTagText:@"dislike" value:appDelegate->dislike];
////    
////    NSString *use_again = [NSString stringWithFormat:@"%d",appDelegate->use_again];
////    [self buildTagText:@"use_app_again" value:use_again];
////    
////    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", SURVEY]];
////    
////    //end questionnaire
////    [write_buffer appendString:[NSString stringWithFormat:@"\n</%@>", QUESTIONNAIRE]];
//}
//
//@end
