//
//  AppDelegate.m
//  Exiting Threads and Timers
//
//  Created by Vandad NP on 24/06/2013.
//  Copyright (c) 2013 Pixolity Ltd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSThread *myThread;
@end

@implementation AppDelegate

//- (void) threadEntryPoint{
//    
//    @autoreleasepool {
//        NSLog(@"Thread Entry Point");
//        while ([[NSThread currentThread] isCancelled] == NO){
//            [NSThread sleepForTimeInterval:4];
//            NSLog(@"Thread Loop");
//        }
//        NSLog(@"Thread Finished");
//    }
//    
//}
//
//- (void) stopThread{
//    
//    NSLog(@"Cancelling the Thread");
//    [self.myThread cancel];
//    NSLog(@"Releasing the thread");
//    self.myThread = nil;
//    
//}
//
//- (BOOL)            application:(UIApplication *)application
//  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
//    
//    self.myThread = [[NSThread alloc]
//                     initWithTarget:self
//                     selector:@selector(threadEntryPoint)
//                     object:nil];
//    
//    [self performSelector:@selector(stopThread)
//               withObject:nil
//               afterDelay:3.0f];
//    
//    [self.myThread start];
//    
//    self.window = [[UIWindow alloc] initWithFrame:
//                   [[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//    return YES;
//}

/* 2 */
- (void) threadEntryPoint{
    
    @autoreleasepool {
        NSLog(@"Thread Entry Point");
        while ([[NSThread currentThread] isCancelled] == NO){
            [NSThread sleepForTimeInterval:4];
            if ([[NSThread currentThread] isCancelled] == NO){
                NSLog(@"Thread Loop");
            }
        }
        NSLog(@"Thread Finished");
    }
    
}

- (void) stopThread{
    
    NSLog(@"Cancelling the Thread");
    [self.myThread cancel];
    NSLog(@"Releasing the thread");
    self.myThread = nil;
    
}

- (BOOL)            application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    self.myThread = [[NSThread alloc]
                     initWithTarget:self
                     selector:@selector(threadEntryPoint)
                     object:nil];
    
    [self performSelector:@selector(stopThread)
               withObject:nil
               afterDelay:3.0f];
    
    [self.myThread start];
    
    self.window = [[UIWindow alloc] initWithFrame:
                   [[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
