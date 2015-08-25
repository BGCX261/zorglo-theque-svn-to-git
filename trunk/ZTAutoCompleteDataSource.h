//
//  ZTAutoCompleteDataSource.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 27/02/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZTAutoCompleteDataSource : NSObject<NSTableViewDataSource> {
	NSManagedObjectContext*	zManagedObjectContext;
	NSArray*				zResults;
	NSString*				zEntityName;
}

- (id) init;
- (id) initForEntityName: (NSString *) entityName;

- (NSInteger) rowCount;
- (void) doSearch: (NSString *) value;
- (id) resultForRow:(int)aRow columnIdentifier:(NSString *)aColumnIdentifier;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;

@end
