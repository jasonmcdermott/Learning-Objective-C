
#import "AppDelegate.h"
#import "Dog.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // showing that instance variables and accessors work
    Dog* fido = [[Dog alloc] init];
    [fido setNumber: 42];
    int n = [fido number];
    NSLog(@"sure enough, n is now %i!", n);
    
    // showing that key-value coding also works
    // note that this corrects an error in the book (also corrected in second printing)
    NSNumber* num = [NSNumber numberWithInt:4242];
    [fido setValue: num forKey: @"number"];
    num = [fido valueForKey: @"number"];
    n = [num intValue];

    NSLog(@"sure enough, n is now %i!", n);

    // no memory management needed
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [UIViewController new]; // silence new annoying runtime warning
    [self.window makeKeyAndVisible];
    return YES;
}


@end
