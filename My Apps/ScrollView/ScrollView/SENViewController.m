//
//  SENViewController.m
//  ScrollView
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENViewController.h"

@interface SENViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *baseScrollView;
@property (weak, nonatomic) IBOutlet UITextView *baseTextView;
@property (weak, nonatomic) IBOutlet UILabel *scrollViewLabel;

@end

@implementation SENViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _baseScrollView.contentSize = CGSizeMake(2000,2000);
    [_baseScrollView addSubview:_baseTextView];
    [_baseScrollView addSubview:_scrollViewLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
