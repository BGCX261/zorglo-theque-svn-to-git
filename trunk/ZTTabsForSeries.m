//
//  ZTTabsForSeries.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 13/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTTabsForSeries.h"




@implementation ZTTabsForSeries


- (id) init
{
	if ((self = [super init])) {
		iContents = [[NSArray alloc] initWithObjects:	[[ZTTabInfo alloc] initWithName:@"Details" andNib:@"SeriesDetails" makeDefault: YES],
														[[ZTTabInfo alloc] initWithName:@"Volumes" andNib:@"SeriesVolumes"], nil];
	}
	return self;
}

@end

