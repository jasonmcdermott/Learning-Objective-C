

#import "APLRegion.h"
#import "APLTimeZoneWrapper.h"


@interface APLRegion ()
@property (nonatomic) NSMutableArray *mutableTimeZoneWrappers;
@end


@implementation APLRegion


static NSMutableArray *knownRegions = nil;


+ (NSArray *)knownRegions {
	
	if (knownRegions == nil) {
		[self setUpKnownRegions];
	}
	return knownRegions;
	
}


-(NSArray *)timeZoneWrappers {
    return _mutableTimeZoneWrappers;
}


#pragma mark -  Private methods for setting up the regions.

- (instancetype)initWithName:(NSString *)regionName {
	
	self = [super init];

    if (self) {
		_name = [regionName copy];
		_mutableTimeZoneWrappers = [[NSMutableArray alloc] init];
	}
	return self;
}


+ (void)setUpKnownRegions {
	
	NSArray *knownTimeZoneNames = [NSTimeZone knownTimeZoneNames];
	
	NSMutableArray *regions = [[NSMutableArray alloc] initWithCapacity:[knownTimeZoneNames count]];
	
	for (NSString *timeZoneName in knownTimeZoneNames) {
		
		NSArray *nameComponents = [timeZoneName componentsSeparatedByString:@"/"];
		NSString *regionName = [nameComponents objectAtIndex:0];
		
		// Get the region  with the region name, or create it if it doesn't exist.
		APLRegion *region = nil;
		
		for (APLRegion *aRegion in regions) {
			if ([aRegion.name isEqualToString:regionName]) {
				region = aRegion;
				break;
			}
		}
		
		if (region == nil) {
			region = [[APLRegion alloc] initWithName:regionName];
			[regions addObject:region];
		}
		
		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:timeZoneName];
		APLTimeZoneWrapper *timeZoneWrapper = [[APLTimeZoneWrapper alloc] initWithTimeZone:timeZone nameComponents:nameComponents];
		[region addTimeZoneWrapper:timeZoneWrapper];
	}
	
	// Sort the time zones by locale name.
    NSSortDescriptor *localeNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localeName" ascending:YES comparator:^(id name1, id name2) {

        return [(NSString *)name1 localizedStandardCompare:(NSString *)name2];
    }];

	for (APLRegion *aRegion in regions) {
        [aRegion.mutableTimeZoneWrappers sortUsingDescriptors:@[localeNameSortDescriptor]];
	}
	
    // Sort the regions by name.
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES comparator:^(id name1, id name2) {

        return [(NSString *)name1 localizedStandardCompare:(NSString *)name2];
    }];

    [regions sortUsingDescriptors:@[nameSortDescriptor]];
	
	knownRegions = regions;
}	


- (void)addTimeZoneWrapper:(APLTimeZoneWrapper *)timeZoneWrapper {
	[self.mutableTimeZoneWrappers addObject:timeZoneWrapper];
}


@end
