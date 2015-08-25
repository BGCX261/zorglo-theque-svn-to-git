//
//  ZTDeleteHandler.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 9/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTDeleteHandler.h"
#import "ZTNamedManagedObject.h"


@implementation ZTDeleteHandler

- (id) initWithSerie: (ZTNamedManagedObject *)deletedSerie inContext: (NSManagedObjectContext *) moc {
	if ((self = [super init])) {
		zDeletedSerie = deletedSerie;
		zMoc = moc;
	}
	
	return self;	
}

- (void) cancelAction: (id) sender owner: (ZTNotificationOwner *)owner forSelection: (NSString *) selected {
	if (zDeletedSerie) {
		NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
		[moc insertObject:[[ZTNamedManagedObject alloc] initWithObject:zDeletedSerie insertIntoManagedObjectContext:moc]];
	}
	[owner restoreMainView];
}

@end
