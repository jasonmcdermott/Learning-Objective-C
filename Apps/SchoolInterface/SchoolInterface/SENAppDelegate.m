//
//  SENAppDelegate.m
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENAppDelegate.h"
#import <HockeySDK/HockeySDK.h>

@implementation SENAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSDictionary* defaults = @{@"appMode": @"1"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

//    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"a34f08894c9a2cb5a85a62e7a914de63" delegate:self];
//    [[BITHockeyManager sharedHockeyManager].authenticator setIdentificationType:BITAuthenticatorIdentificationTypeDevice];
//    [[BITHockeyManager sharedHockeyManager] startManager];

    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"a34f08894c9a2cb5a85a62e7a914de63" delegate:nil];
    [[BITHockeyManager sharedHockeyManager].authenticator setAuthenticationSecret:@"2638c1a5ab2da35580a1586d825919e8"];
    [[BITHockeyManager sharedHockeyManager].authenticator setIdentificationType:BITAuthenticatorIdentificationTypeHockeyAppEmail];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if( [[BITHockeyManager sharedHockeyManager].authenticator handleOpenURL:url
                                                          sourceApplication:sourceApplication
                                                                 annotation:annotation]) {
        return YES;
    }
    
    /* Your own custom URL handlers */
    
    return NO;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"becoming active");
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
