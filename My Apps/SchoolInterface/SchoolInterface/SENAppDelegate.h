//
//  SENAppDelegate.h
//  SchoolInterface
//
//  Created by Jason McDermott on 15/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SENSessionEntity.h"
#import "SENLoggingUtils.h"

#import "PdAudioController.h"
#import "PdDispatcher.h"
#import "PdBase.h"

@interface SENAppDelegate : UIResponder <UIApplicationDelegate, PdReceiverDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) SENSessionEntity *currentSessionEntity;

@property (strong, nonatomic) PdAudioController *audioController;

@end
