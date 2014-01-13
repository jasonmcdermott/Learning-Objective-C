

@import Foundation;

@interface APLRegion : NSObject

@property (nonatomic, copy) NSString *name;
- (NSArray *)timeZoneWrappers;

+ (NSArray *)knownRegions;

@end
