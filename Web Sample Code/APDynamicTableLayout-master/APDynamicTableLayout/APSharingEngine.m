//
//  APSharingEngine.m
//  APDynamicTableLayout
//
//  Created by Adam Talcott on 3/15/12.
//  Copyright (c) 2012 Atomic Powered. All rights reserved.
//

#import "APSharingEngine.h"

static APSharingEngine *_sharingEngine = nil;

@implementation APSharingEngine

@synthesize areSocialNetworksAvailable = _areSocialNetworksAvailable;
@synthesize facebookAvailable = _facebookAvailable;
@synthesize googlePlusAvailable = _googlePlusAvailable;
@synthesize twitterAvailable = _twitterAvailable;

+ (APSharingEngine *)sharedInstance
{
    @synchronized(self)
    {
        if (_sharingEngine == nil)
            _sharingEngine = [[self alloc] init];
    }
    
    return(_sharingEngine);
}

- (id)init
{
    self = [super init];
    if ( self ) {
        
        self.facebookAvailable = YES;
        self.googlePlusAvailable = NO;
        self.twitterAvailable = YES;
    }
    
    return self;
}

- (BOOL)areSocialNetworksAvailable
{
    return (self.isFacebookAvailable || self.isGooglePlusAvailable || self.isTwitterAvailable);
}

@end
