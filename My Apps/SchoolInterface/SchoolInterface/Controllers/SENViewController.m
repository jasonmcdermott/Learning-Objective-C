//
//  SENGraphicsViewController.m
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENViewController.h"

@interface SENViewController ()

@property (weak, nonatomic) IBOutlet UIButton *bluetoothButton;
@property (weak, nonatomic) IBOutlet UILabel *ibiLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic) NSInteger mode;
@property (nonatomic) NSNumber* num;
@property (strong, nonatomic) NSString *chosenMode;
@end

@implementation SENViewController

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
    [self registerDefaultsFromSettingsBundle];

    self.SENUserDefaultsHelper = [[SENUserDefaultsHelper alloc] init];
    
    self.chosenMode = [self.SENUserDefaultsHelper getStringForKey:@"appMode"];
    self.ibiLabel.text = self.chosenMode;
    self.appVersion = [self getVersion];
    NSLog(@"%@",self.appVersion);
    [self setSettingsValues];
    
    [self createViewControllers];
    [self setVisibility];
}

- (void)createViewControllers
{
    self.utilities = [[SENUtilities alloc] init];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main_iPad" bundle:[NSBundle mainBundle]];
    self.questionnaireViewController = [storyboard instantiateViewControllerWithIdentifier:@"questionnaire"];
    [self.view addSubview:self.questionnaireViewController.view];
    self.questionnaireViewController.view.hidden = YES;
    
    // see if a unique app value has been set before.
    // if not, set a new unique app value. 
    if ([[self.utilities getStringForKey:@"appUniqueID"] isEqualToString:@""]) {
        self.appID = [self.utilities getUUID];
    } else {
        self.appID = [self.utilities getStringForKey:@"appUniqueID"];
    }
    self.questionnaireViewController.appID = self.appID;
    
    self.BLEDevice = [storyboard instantiateViewControllerWithIdentifier:@"Redbear"];
    [self.view addSubview:self.BLEDevice.view];
    self.BLEDevice.view.hidden = YES;
    self.BLEDevice.delegate = self;

}

- (void)setVisibility
{
    if ([self.chosenMode isEqualToString:@"Questionnaire"] || [self.chosenMode isEqualToString:@"Both"]) {
        self.settingsButton.hidden = NO;
    } else {
        self.settingsButton.hidden = YES;
    }
    
    if ([self.chosenMode isEqualToString:@"Sensor"] || [self.chosenMode isEqualToString:@"Both"]) {
        self.bluetoothButton.hidden = NO;
    } else {
        self.bluetoothButton.hidden = YES;
    }
    self.ibiLabel.text = _chosenMode;
}

#pragma mark -
#pragma mark Navigation Interface

- (void)setLabel:(NSString *)label
{
    self.ibiLabel.text = label;
}

- (IBAction)touchSettingsButton:(UIButton *)sender
{
    NSLog(@"pressed into service");
    self.questionnaireViewController.view.hidden = NO;
}


- (IBAction)clickBluetoothButton:(UIButton *)sender
{
    NSLog(@"pressed into service");
    self.BLEDevice.view.hidden = NO;
}

#pragma mark -
#pragma mark Settings Bundle

- (void)registerDefaultsFromSettingsBundle {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAutoUpdateSettingsForNotificaiton:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultsFromPlistNamed:@"Root"]];
}

- (NSDictionary *)defaultsFromPlistNamed:(NSString *)plistName {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    NSAssert(settingsBundle, @"Could not find Settings.bundle while loading defaults.");
    
    NSString *plistFullName = [NSString stringWithFormat:@"%@.plist", plistName];
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:plistFullName]];
    NSAssert1(settings, @"Could not load plist '%@' while loading defaults.", plistFullName);
    
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSAssert1(preferences, @"Could not find preferences entry in plist '%@' while loading defaults.", plistFullName);
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        id value = [prefSpecification objectForKey:@"DefaultValue"];
        if(key && value) {
            [defaults setObject:value forKey:key];
        }
        
        NSString *type = [prefSpecification objectForKey:@"Type"];
        if ([type isEqualToString:@"PSChildPaneSpecifier"]) {
            NSString *file = [prefSpecification objectForKey:@"File"];
            NSAssert1(file, @"Unable to get child plist name from plist '%@'", plistFullName);
            [defaults addEntriesFromDictionary:[self defaultsFromPlistNamed:file]];
        }
    }
    
    return defaults;
}

-(void)viewWillActive:(id)sender{
    _chosenMode = [[SENUserDefaultsHelper sharedManager] appMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setVisibility];
    NSLog(@"num: %@",_chosenMode);
}

- (void)checkAutoUpdateSettingsForNotificaiton:(NSNotification *)aNotification
{
    self.chosenMode = [self.SENUserDefaultsHelper getStringForKey:@"appMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"checked auto update");
}

- (NSString*) getVersion {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"%@ build %@", version, build];
}

- (void)setSettingsValues
{
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //Get the bundle file
    NSString *bPath = [[NSBundle mainBundle] bundlePath];
    NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];

    //Get the Preferences Array from the dictionary
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"Preference Items"];

    //Save default value of "version_number" in preference to NSUserDefaults
    for(NSDictionary * item in preferencesArray) {
        if([[item objectForKey:@"key"] isEqualToString:@"version_number"]) {
            NSString * defaultValue = [item objectForKey:@"DefaultValue"];
            [[NSUserDefaults standardUserDefaults] setObject:defaultValue forKey:@"version_number"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }

    //Save your real version number to NSUserDefaults
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"version_number"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"version %@",version);
}
@end
