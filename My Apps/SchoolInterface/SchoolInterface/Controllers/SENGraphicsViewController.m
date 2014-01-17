//
//  SENGraphicsViewController.m
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENGraphicsViewController.h"
#import "RBLMainViewController.h"

@interface SENGraphicsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loadSettingsButton;
@property (weak, nonatomic) IBOutlet UIButton *bluetoothButton;
@property (strong, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIView *redView;

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
	// Do any additional setup after loading the view.
    
    

//    // this method works, i.e. loads a tabbar view, but doesn't do much more than that (returns error regarding view hierarchy)
//    UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
//    tbc.selectedIndex=1;
//    [self.view addSubview:tbc.view];
//    tbc.selectedIndex = 0;
//    [self.view addSubview:tbc.view];
//    [self presentViewController:tbc animated:YES completion:nil];
    

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]];
    self.RBLMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"blueNav"];
    [self.view addSubview:self.RBLMainViewController.view];
//    self.RBLMainViewController.view.hidden = TRUE;
    
//    self.RBLMainViewController = [[RBLMainViewController alloc] init];
//    self.RBLMainViewController.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
//    [self.view addSubview:self.RBLMainViewController.view];
//    self.RBLMainViewController.view.hidden = FALSE;

    //    self.bleShield = [[BLE alloc] init];
    //    [self.bleShield controlSetup];
    //    self.bleShield.delegate = self;
}

#pragma mark -
#pragma mark Navigation Interface

- (IBAction)clickBluetoothButton:(id)sender {
    self.RBLMainViewController.view.hidden = FALSE;
}

//- (IBAction)backToViewControllerOne:(UIStoryboardSegue *)segue
//{
//    NSLog(@"from segue id: %@", segue.identifier);
//    if ([segue.sourceViewController isKindOfClass:[RBLMainViewController class]]) {
//
//        
//        RBLMainViewController *rbl = segue.sourceViewController;
//        self.bleShield = rbl.bleShield;
//        NSLog(@"from RBL main view controller");
//        rbl.passedToParent = YES;
//    }
//}

-(UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    NSLog(@"I %@ will be asked for the destination", self);
    UIViewController* vc = [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
    NSLog(@"I %@ was asked for the destination, and I am returning %@", self, vc);
    return vc;
}

-(UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    NSLog(@"I %@ will be asked for the segue", self);
    UIStoryboardSegue* seg = [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
    NSLog(@"I %@ was asked for the segue, and I am returning %@ %@", self, seg, seg.identifier);
    return seg;
}


-(BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    NSLog(@"I %@ am being asked can perform from %@, and my background is %@", self, fromViewController, self.view.backgroundColor);
    return [super canPerformUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}

-(IBAction) doUnwind: (UIStoryboardSegue*) seg {
    NSLog(@"I %@ was asked to unwind %@ %@", self, seg, seg.identifier);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"I %@ was asked to prepare for segue %@", self, segue);
}

@end
