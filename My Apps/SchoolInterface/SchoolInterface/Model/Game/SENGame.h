//
//  SENGame.h
//  HPV
//
//  Created by Jason McDermott on 22/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SENPlayer.h"
#import "SENRuleSet.h"

@interface SENGame : NSObject

@property (nonatomic, readonly) NSInteger score;
@property (strong, nonatomic) SENPlayer *player;
@property (strong, nonatomic) SENRuleSet *rules;

- (instancetype) initWithPlayer:(SENPlayer *)player
                    withRuleSet:(SENRuleSet *)rules;

- (instancetype) initWithPlayer:(SENPlayer *)player;

@end
