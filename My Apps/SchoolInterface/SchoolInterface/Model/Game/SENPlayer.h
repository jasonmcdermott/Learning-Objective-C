//
//  SENPlayer.h
//  HPV
//
//  Created by Jason McDermott on 22/01/2014.
//  Copyright (c) 2014 Sensorium Health. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SENPlayer : NSObject

@property (strong, nonatomic) NSString *playerName;
@property (strong, nonatomic) NSString *nickname;

@property (strong, nonatomic) NSString *uniqueIdentifier;

@property (nonatomic) NSInteger globalRank;
@property (nonatomic) NSInteger gameScore;

@property (nonatomic) NSInteger gamesPlayed;
@property (nonatomic) NSInteger highScore;

@end
