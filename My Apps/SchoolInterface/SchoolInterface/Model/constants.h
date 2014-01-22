//
//  constants.h
//  SchoolInterface
//
//  Created by Jason McDermott on 16/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#ifndef SchoolInterface_constants_h
#define SchoolInterface_constants_h

#define PI 3.14159265359

// define the messages that we send
//When three consecutive and reliable heart beats have been recorded, send this message
const char* const MSG_SESSION_START = "/oem/session/start"; //bang
//When no heart beats have been detected for 4 seconds, send this message	/oem/session/end	bang
const char* const MSG_SESSION_END = "/oem/session/end";

//Signal reliability status	/oem/sensor/reliability	1 true, 0 false
const char* const MSG_RELIABILITY = "/oem/sensor/reliability";

// Count of the number of heart beats since start of the session (no window size for this calculation)	/oem/ibi/raw/n	Integers
const char* const MSG_NUM_HEART_BEATS = "/oem/ibi-count/raw";

const char* const MSG_CLEAN_IBI = "/oem/ibi-ms/clean";

const char* const MSG_CLEAN_COUNT = "/oem/ibi-count/clean";

const char* const MSG_RAW_PULSE = "/oem/raw-pulse";

const char* const MSG_CURRENT_IBI = "/oem/ibi-ms/raw";
//The average of all the (clean) heartbeats so far in ms.	/oem/ibi/clean/mean/accum	Int, 300-15000
const char* const MSG_AVERAGE_IBI = "/oem/ibi/clean/mean/accum";

//Maximum (clean) IBI since start of session	/oem/ibi/clean/max/accum	Int, 300-15000
const char* const MSG_MAX_IBI = "/oem/ibi/clean/max/accum";

//Minimum (clean) IBI since start of session	/oem/ibi/clean/min/accum	Int, 200-1000
const char* const MSG_MIN_IBI = "/oem/ibi/clean/min/accum";

#endif
