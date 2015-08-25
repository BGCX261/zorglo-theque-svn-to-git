//
//  ZTAutoCompleteDataSource.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 27/02/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTAutoCompleteDataSource.h"
#import "ZTSerieManagedObject.h"


@implementation ZTAutoCompleteDataSource

- (id) init
{
	if ((self = [super init])) {
		zManagedObjectContext = [[NSApp delegate] managedObjectContext];
		zResults = nil;
	}
		
	return self;
}


- (id) initForEntityName: (NSString *) entityName {
	if ((self = [self init])) {
		zEntityName = entityName;
	}
	return self;
}

- (NSInteger) rowCount
{
	if (!zResults)
		return 0;
	
	return [zResults count];
}

- (void) doSearch: (NSString *) value
{
	if (!zManagedObjectContext) return;
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:zEntityName 
														 inManagedObjectContext:zManagedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name CONTAINS[cd] %@", value];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error;
	zResults = nil;
	zResults = [zManagedObjectContext executeFetchRequest:request error:&error];
	if (zResults == nil)
	{
		NSLog (@"Failed fetch: %@", error);
	}
}

- (id) resultForRow:(int)aRow columnIdentifier:(NSString *)aColumnIdentifier
{
	if ((zResults == nil)) return @"";
	ZTSerieManagedObject *result = [zResults objectAtIndex:aRow];
	return result.name;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [self rowCount];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [self resultForRow:rowIndex columnIdentifier:[aTableColumn identifier]];
}


@end
