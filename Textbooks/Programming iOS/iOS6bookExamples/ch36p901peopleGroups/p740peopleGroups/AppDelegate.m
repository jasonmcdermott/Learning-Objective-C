

#import "AppDelegate.h"

#import "DocumentLister.h"

@implementation AppDelegate

/*
 This app comes in two flavors: Normal, and iCloud-enabled.
 So how do you enable it for iCloud?
 
 When you switch on Use Entitlements File in the target summmary,
 everything just springs to life: the entitlements file is added to the project and
 the Enable iCloud checkbox is enabled, and you just check it as well.
 You then also add one ubiquity container, which is automatically assigned your bundle id.
 
 You must also create an iCloud-enabled development provisioning profile and download it
 (and open it with Xcode).
 If you don't, you'll have invalid entitlements (your entitlements claim
 won't match your provisioning).
 
 Well covered here:
 http://developer.apple.com/library/mac/#documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html
  
 Note that it is up to you to inform the user that your app uses iCloud and ask that it be turned on.
 That's omitted from this example. We assume iCloud is turned on and Documents and Data is enabled.
 */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:[DocumentLister new]];
    self.window.rootViewController = nav;
    
    // this is the other part of iCloud-enablement
    // if we get a ubiquity container, we are good to go!
    // other classes will see that we have set ubiq and will use it
    // NOTE: screwed this up in previous edition: we are asked to do this on a background thread
    // NB new in iOS 6, should start by asking for the file manager's ubiquityIdentityToken
    // if it doesn't exist, there is no iCloud account
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager* fm = [NSFileManager new];
        NSURL* ubiq = [fm URLForUbiquityContainerIdentifier:nil];
        NSLog(@"ubiq: %@", ubiq);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ubiq = ubiq;
        });
    });
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

/*
 An incoherency I have not taken care of here is what should happen if the user switches on iCloud
 in midstream, while using the app or between uses of the app. We should detect this, and we should
 move the documents between worlds. When we detect that iCloud has been switched from off to on, 
 we can call setUbiquitous:itemAtURL:destinationURL:error: to make this move.
 However, it is not so obvious what to do if iCloud is switched from on to off,
 as the document is now no longer available to us to rescue. Again, see
 http://developer.apple.com/library/mac/#documentation/General/Conceptual/iCloudDesignGuide/Chapters/iCloudFundametals.html
 which discusses how to detect changes in status.
 */


@end
