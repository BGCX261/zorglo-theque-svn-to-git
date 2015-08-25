//
//  ZTRenameHandler.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 9/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTRenameHandler.h"
#import "ZTNamedManagedObject.h"


@implementation ZTRenameHandler


- (id) initWithSerie: (ZTNamedManagedObject *)deletedSerie andOldName: (NSString *) oldName {
	if ((self = [super init])) {
		zDeletedSerie = deletedSerie;
		zOldName = oldName;
	}
	
	return self;	
}

- (void) cancelAction: (id) sender owner: (ZTNotificationOwner *)owner forSelection: (NSString *) selected {
	if (zDeletedSerie != nil && zOldName != nil) {
		zDeletedSerie.name = zOldName;
	}
	[owner restoreMainView];
}

@end
