
#import "RootViewController.h"

@implementation RootViewController

- (IBAction)doButton:(id)sender {
    UILocalNotification* ln = [UILocalNotification new];
    ln.alertBody = @"Time for another cup of coffee!";
    //ln.alertAction = @"What";
    ln.hasAction = YES; // try NO; has no effect
    ln.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
    ln.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:ln];
}

@end
