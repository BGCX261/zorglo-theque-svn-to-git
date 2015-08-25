//
//  ZTDeleteHandler.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 9/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZTAbstractNotificationHandler.h"

@class ZTNamedManagedObject;

@interface ZTDeleteHandler : ZTAbstractNotificationHandler {
	ZTNamedManagedObject *zDeletedSerie;
	NSManagedObjectContext *zMoc;
}

- (id) initWithSerie: (ZTNamedManagedObject *)deletedSerie inContext: (NSManagedObjectContext *) moc;

@end
