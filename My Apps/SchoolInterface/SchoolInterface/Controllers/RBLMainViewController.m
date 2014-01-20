//
//  RBLMainViewController.m
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import "RBLMainViewController.h"


unsigned char const OEM_RELIABLE = 0xA0;
unsigned char const OEM_UNRELIABLE = 0xA1;
unsigned char const OEM_PULSE = 0xB0;
unsigned char const SYNC_CHAR = 0xF9;
unsigned const NUM_PULSE_BYTES = 3;
unsigned const DEF_MAX_INACTIVITY = 8;
NSString * const  UUIDPrefKey = @"UUIDPrefKey";
NSString * const  INACTIVITY_KEY = @"BrightheartsInactivity";
NSString * const  USERNAME_KEY = @"BrightheartsUsername";


@interface RBLMainViewController ()

@property (nonatomic) BOOL showTable;
@property (weak, nonatomic) IBOutlet UITableView *deviceList;

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
- (IBAction)scanClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
- (IBAction)lastClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic)SENBLESessionData * mSesionData;

@property (strong, nonatomic) NSMutableArray *tempDevices;
@end



@implementation RBLMainViewController

#pragma mark Init
#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    NSLog(@"RBLMainViewController didLoad");
    self.passedToParent = NO;
    self.bleShield = [[BLE alloc] init];
    [self.bleShield controlSetup];
    self.bleShield.delegate = self;
    _max_inactivity = DEF_MAX_INACTIVITY;
    
    
    
    //Retrieve saved UUID from system
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    
    if (self.lastUUID.length > 0)
    {
        self.uuidLabel.text = self.lastUUID;
        self.scanButton.hidden = true;
    }
    else
    {
        self.scanButton.hidden = false;
        self.lastButton.hidden = true;
    }
    
    self.mDevices = [[NSMutableArray alloc] init];
    self.tempDevices = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView
#pragma mark -


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mDevices.count;
    NSLog(@"%lu",(unsigned long)self.mDevices.count);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Available Devices";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"BLEDeviceList";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.mDevices objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelected:indexPath.row];
}

#pragma mark Interface Elements
#pragma mark -

- (IBAction)scanClick:(id)sender
{

    if (self.bleShield.activePeripheral)
    {
        if (self.bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
            return;
        }
    }
    
    if (self.bleShield.peripherals)
        self.bleShield.peripherals = nil;
    
    [self.bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];

    
    isFindingLast = false;
    self.lastButton.hidden = true;
    self.scanButton.hidden = true;
    [self.spinner startAnimating];
    
}


- (IBAction)lastClick:(id)sender
{
    [self.bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
   
    isFindingLast = true;
    self.lastButton.hidden = true;
    self.scanButton.hidden = true;
    [self.spinner startAnimating];
}

//Show device list for user selection
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDevice"])
    {
        //        RBLDetailViewController *vc =[segue destinationViewController] ;
        //        vc.BLEDevices = self.mDevices;
        //        vc.delegate = self;
    }
}

- (void)didSelected:(NSInteger)index
{
    self.scanButton.hidden = true;
    [self.bleShield connectPeripheral:[self.bleShield.peripherals objectAtIndex:index]];
}

-(void) displaySesionStart
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *stringFromDate = [formatter stringFromDate:self.mSesionData.mSesionStart];
    [self.sessionStartLabel setText:stringFromDate];
    //    [formatter release];
}

- (void)hideAll
{
    NSLog(@"hiding");
    self.view.hidden = YES;
}

- (IBAction)touchCloseButton:(UIButton *)sender
{
    [self hideAll];
}

#pragma mark Bluetooth Periphery
#pragma mark -

// Called when scan period is over 
-(void) connectionTimer:(NSTimer *)timer
{
    if(self.bleShield.peripherals.count > 0) {
        //to connect to the peripheral with a particular UUID
        if(isFindingLast)
        {
            int i;
            for (i = 0; i < self.bleShield.peripherals.count; i++)
            {
                CBPeripheral *p = [self.bleShield.peripherals objectAtIndex:i];
                
                if (p.identifier != NULL)
                {
                    //Comparing UUIDs and call connectPeripheral is matched
                    if([self.lastUUID isEqualToString:[self getUUIDString:CFBridgingRetain(p.identifier)]])
                    {
                        [self.bleShield connectPeripheral:p];
                    }
                }
            }
        }
        //Scan for all BLE in range and prepare a list
        else
        {
            [self.mDevices removeAllObjects];
            
            int i;
            for (i = 0; i < self.bleShield.peripherals.count; i++)
            {
                CBPeripheral *p = [self.bleShield.peripherals objectAtIndex:i];
                
                if (p.identifier != NULL)
                {
                    [self.mDevices insertObject:[self getUUIDString:CFBridgingRetain(p.identifier)] atIndex:i];
                }
                else
                {
                    [self.mDevices insertObject:@"NULL" atIndex:i];
                }
            }
            
            //Show the list for user selection
            _showTable = YES;
            self.deviceList.hidden = NO;
            [self.deviceList reloadData];
//                [self performSegueWithIdentifier:@"showDevice" sender:self];
        }
    } else {
        [self.spinner stopAnimating];
        
        if (self.lastUUID.length == 0)
        {
            self.lastButton.hidden = true;
        }
        else
        {
            self.lastButton.hidden = false;
        }
        
        self.scanButton.hidden = false;
    }
}


// Merge two bytes to integre value
unsigned int mergeBytes (unsigned char lsb, unsigned char msb)
{
    unsigned int ret = msb & 0xFF;
    ret = ret << 7;
    
    ret = ret + lsb;
    
    return ret;
}


-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    if (self.passedToParent == NO) {
        for (int i = 0; i < length && _bufferIndex < 4; i++)
        {
            unsigned char b = data[i];
            
            // we will force resynchronisation
            if (b == OEM_PULSE || b == SYNC_CHAR || b == OEM_RELIABLE || b == OEM_UNRELIABLE)
            {
                _bufferIndex = 0;
            }
            
            _oemBuffer.data[_bufferIndex] = b;
            _bufferIndex++;
            
            switch (_oemBuffer.data[0]) {
                case OEM_PULSE:
                    if (_bufferIndex == NUM_PULSE_BYTES)
                    {
                        unsigned char lsb = _oemBuffer.data[1];
                        unsigned char msb = _oemBuffer.data[2];
                        
                        unsigned interval = mergeBytes(lsb, msb);
                        
                        
                        if (!_started)
                            
                        {
                            [self.mSesionData clearSesionLists];
                            [self.mSesionData setStartSesion];
                            self.mSesionData.mUsername = self.username;
                            self.mSesionData.mDeviceID = self.lastUUID;
                            
                            [self displaySesionStart];
                            
                            self.sessionStatusLabel.text = @"Sesion Started";
                            _started = true;
//                            [mPDDRiver startSession]; // need to get this working.
                            self.generateButton.hidden = true;
                        }

                        [self.delegate setLabel:[NSString stringWithFormat:@"Interval %d", interval]];
//                        [mPDDRiver sendIBI:interval]; // need to get this working.
                        _bufferIndex = 0;
                        _inactivityCount = 0;
                        
                        [self.mSesionData addIbi:interval];
                    }
                    
                    break;
                    
                case SYNC_CHAR:
                    _bufferIndex = 0;
                    
                    
                    break;
                    
                case OEM_RELIABLE:
                    _bufferIndex = 0;
                    _reliable = true;
//                    [mPDDRiver sendtoPDBaseReliability:1];  // need to get this working.
                    self.sessionStatusLabel.text = @"Reliable";
                    _inactivityCount = 0;
                    
                    [self.mSesionData addReliability:true];
                    
                    break;
                    
                case OEM_UNRELIABLE:
                    _bufferIndex = 0;
                    _reliable = false;
//                    [mPDDRiver sendtoPDBaseReliability:0]; // need to get this working
                    self.sessionStatusLabel.text = @"Unreliable";
                    _inactivityCount = 0;
                    
                    [self.mSesionData addReliability:false];
                    
                    
                    break;
                    
                default:
                    _bufferIndex = 0; // we are not going to accept other values
                    break;
            }
        }
        _inactivityCount++;
        
        if (_inactivityCount >= _max_inactivity)
        {
            self.intervalLabel.text = @"";
            self.sessionStatusLabel.text = @"session Ended";
            if (_started)
            {
                _started = false;
//                [mPDDRiver endSession]; // need to get this working.
                self.generateButton.hidden = true; // JASON
                
                [self.mSesionData setSessionEnd];
                self.sessionStatusLabel.text = @"Uploaded";
                
    //            XMLDataGenerator* xml = [[XMLDataGenerator alloc]init];
    //            NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
                
    //            [xml generateXML:self.mSesionData filename: [NSString stringWithFormat:@"%@.xml", uuid]];
    //            [xml release];
            }
        }
    }
}


- (void) bleDidDisconnect
{
    self.lastButton.hidden = false;
    self.rssiLabel.hidden = true;
    [self.scanButton setTitle:@"Scan All" forState:UIControlStateNormal];

}

-(void) bleDidConnect
{
    //Save UUID into system
    self.lastUUID = [self getUUIDString:CFBridgingRetain(self.bleShield.activePeripheral.identifier)];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.spinner stopAnimating];
    self.lastButton.hidden = true;
    self.scanButton.hidden = false;
    self.uuidLabel.text = self.lastUUID;
    self.rssiLabel.text = @"RSSI: ?";
    self.rssiLabel.hidden = false;
    [self.scanButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
}


-(NSString*)getUUIDString:(CFUUIDRef)ref
{
    NSString *str = [NSString stringWithFormat:@"%@",ref];
    return [[NSString stringWithFormat:@"%@",str] substringWithRange:NSMakeRange(str.length - 36, 36)];
}




@end
