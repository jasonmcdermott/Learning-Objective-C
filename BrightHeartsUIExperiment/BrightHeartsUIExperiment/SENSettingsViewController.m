//
//  SENSettingsViewController.m
//  BrightHeartsUIExperiment
//
//  Created by Jason McDermott on 11/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENSettingsViewController.h"
#import "SENSettingsItem.h"
#import "Constants.h"

#define kSliderHeight			7.0
#define kProgressIndicatorSize	40.0

#define kUIProgressBarWidth		160.0
#define kUIProgressBarHeight	24.0

#define kViewTag				1		// for tagging our embedded controls for removal at cell recycle time

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kLabelKey = @"labelKey";
static NSString *kSourceKey = @"sourceKey";
static NSString *kViewKey = @"viewKey";

// tableView cell id constants
static NSString *kDisplayCellID = @"DisplayCellID";
static NSString *kSourceCellID = @"SourceCellID";


#pragma mark -

@interface SENSettingsViewController ()
@property NSMutableArray *settingsItems;
@property (nonatomic, strong) UISwitch *questionnaireSwitchCtl;
@property (nonatomic, strong) NSArray *dataSourceArray;
@end

@implementation SENSettingsViewController

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
    
	self.title = NSLocalizedString(@"Settings B", @"");
    
	self.dataSourceArray = @[
                             @{  kSectionTitleKey:@"UISwitch",
                                 kLabelKey:@"Standard Switch",
                                 kSourceKey:@"SENSettingsViewController.m:\r-(UISwitch *)switchCtl",
                                 kViewKey:self.switchCtl },
                             
                             //                            @{  kSectionTitleKey:@"UISlider",
                             //                                kLabelKey:@"Standard Slider",
                             //                                kSourceKey:@"ControlsViewController.m:\r-(UISlider *)sliderCtl",
                             //                                kViewKey:self.sliderCtl },
                             //
                             //                            @{  kSectionTitleKey:@"UISlider",
                             //                                kLabelKey:@"Customized Slider",
                             //                                kSourceKey:@"ControlsViewController.m:\r-(UISlider *)customSlider",
                             //                                kViewKey:self.customSlider },
                             //
                             //							@{  kSectionTitleKey:@"UIPageControl",
                             //                                kLabelKey:@"Ten Pages",
                             //                                kSourceKey:@"ControlsViewController.m:\r-(UIPageControl *)pageControl",
                             //                                kViewKey:self.pageControl },
                             //
                             //							@{  kSectionTitleKey:@"UIActivityIndicatorView",
                             //                                kLabelKey:@"Style Gray",
                             //                                kSourceKey:@"ControlsViewController.m:\r-(UIActivityIndicatorView *)progressInd",
                             //                                kViewKey:self.progressInd },
                             //
                             //                            @{  kSectionTitleKey:@"UIProgressView",
                             //                                kLabelKey:@"Style Default",
                             //                                kSourceKey:@"ControlsViewController.m:\r-(UIProgressView *)progressBar",
                             //                                kViewKey:self.progressBar },
                             //
                             //                            @{  kSectionTitleKey:@"UIStepper",
                             //                                kLabelKey:@"Stepper 1 to 10",
                             //                                kSourceKey:@"ControlsViewController.m:\r-(UIStepper *)stepper",
                             //                                kViewKey:self.stepper }
                             ];
    
    //    // add tint bar button
    //    UIBarButtonItem *tintButton = [[UIBarButtonItem alloc] initWithTitle:@"Tinted"
    //                                                                   style:UIBarButtonItemStyleBordered
    //                                                                  target:self
    //                                                                  action:@selector(tintAction:)];
    //    self.navigationItem.rightBarButtonItem = tintButton;
    
    // register our cell IDs for later when we are asked for UITableViewCells
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDisplayCellID];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSourceCellID];
}


- (void)loadInitialData
{
    

    
    
//    SENSettingsItem *item1 = [[SENSettingsItem alloc] init];
//    item1.itemName = @"Questionnaire";
//    [self.settingsItems addObject:item1];
    
//    SENToDoItem *item2 = [[SENToDoItem alloc] init];
//    item2.itemName = @"Buy eggs";
//    [self.toDoItems addObject:item2];
//    
//    SENToDoItem *item3 = [[SENToDoItem alloc] init];
//    item3.itemName = @"Read a book";
//    [self.toDoItems addObject:item3];

    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.dataSourceArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.dataSourceArray objectAtIndex: section] valueForKey:kSectionTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ([indexPath row] == 0) ? 50.0 : 38.0;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
    
	if ([indexPath row] == 0)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kDisplayCellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *viewToRemove = nil;
        viewToRemove = [cell.contentView viewWithTag:kViewTag];
        if (viewToRemove)
            [viewToRemove removeFromSuperview];
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex:indexPath.section] valueForKey:kLabelKey];
		
		UIControl *control = [[self.dataSourceArray objectAtIndex:indexPath.section] valueForKey:kViewKey];
        
        // make sure this control is right-justified to the right side of the cell
        CGRect newFrame = control.frame;
        newFrame.origin.x = CGRectGetWidth(cell.contentView.frame) - CGRectGetWidth(newFrame) - 10.0;
        control.frame = newFrame;
        
        // if the cell is ever resized, keep the control over to the right
        control.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
		[cell.contentView addSubview:control];
        
        //        if (control == (UIControl *)self.progressInd)
        //        {
        //            [self.progressInd startAnimating];  // UIActivityIndicatorView needs to re-animate
        //        }
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.opaque = NO;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:12.0];
		
		cell.textLabel.text = [[self.dataSourceArray objectAtIndex:indexPath.section] valueForKey:kSourceKey];
	}
    
	return cell;
}

- (void)switchAction:(id)sender
{
	// NSLog(@"switchAction: value = %d", [sender isOn]);
}



//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self.settingsItems count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"ListPrototypeCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    SENSettingsItem *settingItem = [self.settingsItems objectAtIndex:indexPath.row];
//    cell.textLabel.text = settingItem.itemName;
////    if (toDoItem.completed) {
////        cell.accessoryType = UITableViewCellAccessoryCheckmark;
////    } else {
////        cell.accessoryType = UITableViewCellAccessoryNone;
////    }
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    [tableView deselectRowAtIndexPath:indexPath animated:NO];
////    SENSettingsItem *tappedItem = [self.toDoItems objectAtIndex:indexPath.row];
////    tappedItem.completed = !tappedItem.completed;
////    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//}

#pragma mark - Lazy creation of controls

- (UISwitch *)switchCtl
{
    if (_questionnaireSwitchCtl == nil)
    {
        CGRect frame = CGRectMake(0.0, 12.0, 94.0, 27.0);
        _questionnaireSwitchCtl = [[UISwitch alloc] initWithFrame:frame];
        [_questionnaireSwitchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        _questionnaireSwitchCtl.backgroundColor = [UIColor clearColor];
		
		[_questionnaireSwitchCtl setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
		
		_questionnaireSwitchCtl.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    }
    return _questionnaireSwitchCtl;
}



@end