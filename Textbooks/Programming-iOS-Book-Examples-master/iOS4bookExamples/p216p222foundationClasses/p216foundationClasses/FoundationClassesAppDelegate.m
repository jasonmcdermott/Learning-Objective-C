

#import "FoundationClassesAppDelegate.h"

@implementation FoundationClassesAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSString* f = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"txt"];
    NSError* err = nil;
    NSString* s = [NSString stringWithContentsOfFile:f 
                                            encoding:NSUTF8StringEncoding 
                                               error:&err];
    // error-checking omitted
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    for (NSString* line in [s componentsSeparatedByString:@"\n"]) {
        NSArray* items = [line componentsSeparatedByString:@"\t"];
        NSInteger chnum = [[items objectAtIndex: 0] integerValue];
        NSNumber* key = [NSNumber numberWithInteger:chnum];
        NSMutableArray* marr = [d objectForKey: key];
        if (!marr) { // no such key, create key–value pair
            marr = [NSMutableArray array];
            [d setObject: marr forKey: key];
        }
        // marr is now a mutable array, empty or otherwise
        NSString* picname = [items objectAtIndex: 1];
        [marr addObject: picname];
    }
    NSLog(@"%@", d); // look at the log to see how we've parsed the text file into a dictionary
    
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
