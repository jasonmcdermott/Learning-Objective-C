

#import "RootViewController.h"
#import "MyCell.h"

@interface RootViewController ()

@end

@implementation RootViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel* lab = cell.theLabel;
    lab.text = [NSString stringWithFormat:@"This is row %d of section %d",
                indexPath.row, indexPath.section];
    if (lab.tag != 999) {
        lab.tag = 999;
        NSLog(@"%@", @"New cell");
    }
    
    UIImageView* iv = cell.theImageView;
    
    // missing constraint: make the image view a square (can't say that in the nib, alas)
    if (!iv.constraints.count) {
        [iv addConstraint:
         [NSLayoutConstraint
          constraintWithItem:iv attribute:NSLayoutAttributeWidth relatedBy:0 toItem:iv attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    }
    
    // shrink apparent size of image
    UIImage* im = [UIImage imageNamed:@"moi.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36,36), YES, 0.0);
    [im drawInRect:CGRectMake(0,0,36,36)];
    UIImage* im2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    iv.image = im2;
    iv.contentMode = UIViewContentModeCenter;
    
    return cell;
}


@end
