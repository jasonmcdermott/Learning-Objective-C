//
//  SENGraphicsViewController.m
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENGraphicsViewController.h"

@interface SENGraphicsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *bluetoothButton;
@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UILabel *ibiLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic) NSInteger mode;
@property (nonatomic) NSNumber* num;
@property (strong, nonatomic) NSString *chosenMode;
@end

@implementation SENGraphicsViewController



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
    NSLog(@"num: %@",_chosenMode);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    self.SENUserDefaultsHelper = [[SENUserDefaultsHelper alloc] init];
    self.showQuestionnaire = [self.SENUserDefaultsHelper getBoolForKey:@"questionnaire_enabled_preference"];
    
    self.chosenMode = [self.SENUserDefaultsHelper getStringForKey:@"appMode"];
    NSLog(@"mode: %ld", (long)self.mode);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main_iPad" bundle:[NSBundle mainBundle]];
    
    if ([self.chosenMode isEqualToString:@"Questionnaire"] || [self.chosenMode isEqualToString:@"Both"]) {
        self.settingsButton.hidden = NO;
        self.questionnaireViewController = [storyboard instantiateViewControllerWithIdentifier:@"questionnaire"];
        [self.view addSubview:self.questionnaireViewController.view];
        self.questionnaireViewController.view.hidden = YES;
        // likely we'll need to do some delegate method action for the questionnaire here.
    } else {
        self.settingsButton.hidden = YES;
    }

    if ([self.chosenMode isEqualToString:@"Sensor"] || [self.chosenMode isEqualToString:@"Both"]) {
        self.RBLMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"Redbear"];
        [self.view addSubview:self.RBLMainViewController.view];
        self.RBLMainViewController.view.hidden = YES;
        self.RBLMainViewController.delegate = self;
    } else {
        self.bluetoothButton.hidden = YES;
    }

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
    self.RBLMainViewController.view.hidden = NO;
}

@end
