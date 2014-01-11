

#import "ViewController.h"
#import "MyView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    MyView* mv = [MyView new];
    [self.view addSubview: mv];
    
    mv.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray* cons;
    NSLayoutConstraint* con;
    cons = [NSLayoutConstraint
            constraintsWithVisualFormat:@"H:|-25-[v]-25-|"
            options:0 metrics:nil
            views:@{@"v":mv}];
    [mv.superview addConstraints:cons];
    cons = [NSLayoutConstraint
            constraintsWithVisualFormat:@"V:[v(150)]"
            options:0 metrics:nil
            views:@{@"v":mv}];
    [mv addConstraints:cons];
    // I don't think we can say this in the visual format language
    con = [NSLayoutConstraint
           constraintWithItem:mv
           attribute:NSLayoutAttributeCenterY
           relatedBy:NSLayoutRelationEqual
           toItem:mv.superview
           attribute:NSLayoutAttributeCenterY
           multiplier:1 constant:0];
    [mv.superview addConstraint:con];
    
    
    return; // comment this out to experiment with resizing
    
    void (^resize) (void) = ^{
        CGRect f = mv.bounds; // mv is the MyView instance
        f.size.height *= 2;
        mv.bounds = f;
    };
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), resize);


}



@end
