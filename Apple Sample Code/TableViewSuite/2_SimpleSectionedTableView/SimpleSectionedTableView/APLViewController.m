
#import "APLViewController.h"
#import "APLAppDelegate.h"
#import "APLRegion.h"
#import "APLTimeZoneWrapper.h"


NSString *localeNameForTimeZoneNameComponents(NSArray *nameComponents);
NSMutableDictionary *regionDictionaryWithNameInArray(NSString *name, NSArray *array);


@implementation APLViewController


#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Number of sections is the number of regions.
	return [self.regions count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Number of rows is the number of time zones in the region for the specified section.
	APLRegion *region = [self.regions objectAtIndex:section];
	return [region.timeZoneWrappers count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the region at the section index.
	APLRegion *region = self.regions[section];
	return region.name;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *MyIdentifier = @"MyIdentifier";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

	// Get the section index, and so the region for that section.
	APLRegion *region = self.regions[indexPath.section];
	APLTimeZoneWrapper *timeZoneWrapper = [region.timeZoneWrappers objectAtIndex:indexPath.row];

	// Set the cell's text to the name of the time zone at the row
	cell.textLabel.text = timeZoneWrapper.localeName;
	return cell;
}


@end
