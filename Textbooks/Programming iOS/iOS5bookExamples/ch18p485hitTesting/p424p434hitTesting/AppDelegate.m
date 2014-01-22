

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

// tap a planet

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    UITapGestureRecognizer* t1 = [[UITapGestureRecognizer alloc] 
                                  initWithTarget:self 
                                  action:@selector(singleTap:)];
    [self.window addGestureRecognizer:t1];
    
    
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

// the gesture recognizer is on the window
// but the window can use hit testing to determine where the tap really was

- (void) singleTap: (UIGestureRecognizer*) g {
    CGPoint p = [g locationOfTouch:0 inView:self.window];
    UIView* v = [self.window hitTest:p withEvent:nil];
    if (v && [v isKindOfClass:[UIImageView class]]) {
        [UIView animateWithDuration:0.2 
                              delay:0 
                            options:UIViewAnimationOptionAutoreverse 
                         animations:^(void) {
                             v.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         } completion:^ (BOOL b) {
                             v.transform = CGAffineTransformIdentity;
                         }];
    }
}



@end
