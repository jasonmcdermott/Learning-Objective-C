//
//  SENGame.m
//  HPV
//
//  Created by Jason McDermott on 22/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import "SENGame.h"

@implementation SENGame

- (SENPlayer *)player
{
    if (!_player) _player = [[SENPlayer alloc] init];
    return _player;
}

- (SENRuleSet *)rules
{
    if (!_rules) _rules = [[SENRuleSet alloc] init];
    return _rules;
}

- (instancetype)initWithPlayer:(SENPlayer *)player
                   withRuleSet:(SENRuleSet *)ruleSet
{
    self = [super init];
    if (self) {
        self.player = player;
        self.rules = ruleSet;
    }
    return self;
}

- (instancetype)initWithPlayer:(SENPlayer *)player
{
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

@end
