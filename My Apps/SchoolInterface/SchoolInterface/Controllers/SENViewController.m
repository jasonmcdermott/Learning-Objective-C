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


- (void)registerDefaultsFromSettingsBundle {
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerDefaultsFromSettingsBundle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewWillActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAutoUpdateSettingsForNotificaiton:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    self.SENUserDefaultsHelper = [[SENUserDefaultsHelper alloc] init];
//    self.showQuestionnaire = [self.SENUserDefaultsHelper getBoolForKey:@"questionnaire_enabled_preference"];
    
    self.chosenMode = [self.SENUserDefaultsHelper getStringForKey:@"appMode"];
    NSLog(@"mode: %ld", (long)self.chosenMode);
    self.ibiLabel.text = self.chosenMode;
    
    [self createViewControllers];
    [self setVisibility];
}

- (void)createViewControllers
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main_iPad" bundle:[NSBundle mainBundle]];
    self.questionnaireViewController = [storyboard instantiateViewControllerWithIdentifier:@"questionnaire"];
    [self.view addSubview:self.questionnaireViewController.view];
    self.questionnaireViewController.view.hidden = YES;
    
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

@end
