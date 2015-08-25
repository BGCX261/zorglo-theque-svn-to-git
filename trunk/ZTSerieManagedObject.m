//
//  ZTSerieManagedObject.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 1/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTSerieManagedObject.h"
#import "ZTNamedManagedObject.h"
#import "ZTVolumeManagedObject.h"


@implementation ZTSerieManagedObject

- (NSString *) myKey
{
	return @"serie";
}

- (NSString*) firstDefinedCover
{
	NSSet *vols = self.volumes;
	__block NSString *myResult = nil;
	[vols enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		ZTVolumeManagedObject *vol = (ZTVolumeManagedObject*)obj;
		if (vol && vol.coverFileName) {
			myResult = vol.coverFileName;
			*stop = YES;
		}
	}];
	if (!myResult) {
		myResult = @"no-cover.png";
	}
	return myResult;
}


@end

