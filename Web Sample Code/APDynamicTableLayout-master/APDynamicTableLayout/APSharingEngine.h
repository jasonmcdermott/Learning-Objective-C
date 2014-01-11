//
//  APSharingEngine.h
//  APDynamicTableLayout
//
//  Created by Adam Talcott on 3/15/12.
//  Copyright (c) 2012 Atomic Powered. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APSharingEngine : NSObject

@property (readonly, nonatomic) BOOL areSocialNetworksAvailable;
@property (assign, nonatomic, getter = isFacebookAvailable) BOOL facebookAvailable;
@property (assign, nonatomic, getter = isGooglePlusAvailable) BOOL googlePlusAvailable;
@property (assign, nonatomic, getter = isTwitterAvailable) BOOL twitterAvailable;

+ (APSharingEngine *)sharedInstance;

@end
