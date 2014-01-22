
#import "Empty_WindowAppDelegate.h"
#import "MyClass.h"

@implementation Empty_WindowAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    MyClass* mc = [[MyClass alloc] init]; 
    [[NSBundle mainBundle] loadNibNamed:@"MyNib" owner:mc options:nil]; 
    UILabel* lab = [mc valueForKey: @"theLabel"]; 
    [self.window addSubview: lab]; 
    lab.center = CGPointMake(100,100);
    
    // memory management (even though we won't discuss this until Chapter 12)
    [mc release];
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
