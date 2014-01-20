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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    showQuestionnaire ? (self.settingsButton.hidden = NO) : (self.settingsButton.hidden = YES);
    
    self.SENUserDefaultsHelper = [[SENUserDefaultsHelper alloc] init];
    self.showQuestionnaire = [self.SENUserDefaultsHelper getBoolForKey:@"questionnaire_enabled_preference"];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main_iPad" bundle:[NSBundle mainBundle]];
    
    if (self.showQuestionnaire) {
        self.settingsButton.hidden = NO;
        self.questionnaireViewController = [storyboard instantiateViewControllerWithIdentifier:@"questionnaire"];
        [self.view addSubview:self.questionnaireViewController.view];
        self.questionnaireViewController.view.hidden = YES;
        // likely we'll need to do some delegate method action for the questionnaire here.
    } else {
        self.settingsButton.hidden = YES;
    }

    self.RBLMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"Redbear"];
    [self.view addSubview:self.RBLMainViewController.view];
    self.RBLMainViewController.view.hidden = YES;
    self.RBLMainViewController.delegate = self;

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
