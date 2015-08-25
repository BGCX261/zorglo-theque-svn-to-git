//
//  ZTTabsAbstract.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 14/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTTabsAbstract.h"

@implementation ZTTabInfo

- (id) initWithName: (NSString*) name andNib: (NSString*) nibName makeDefault: (BOOL) deflt {
	if ((self = [super init])) {
		zName = name;
		zNibName = nibName;
		zDefault = deflt;
	}
	return self;
}

- (id) initWithName: (NSString*) name andNib: (NSString*) nibName {
	return [self initWithName:name andNib:nibName makeDefault:NO];
}

@synthesize zName;
@synthesize zNibName;
@synthesize zDefault;

@end

@implementation ZTTabsAbstract

@synthesize iContents;

@end
