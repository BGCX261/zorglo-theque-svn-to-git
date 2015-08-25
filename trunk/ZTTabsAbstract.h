//
//  ZTTabsAbstract.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 14/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ZTTabInfo : NSObject {
	NSString	*zName;
	NSString	*zNibName;
	BOOL		zDefault;
}

@property (nonatomic, readonly, getter=name) NSString* zName;
@property (nonatomic, readonly, getter=nibName) NSString* zNibName;
@property (nonatomic, readonly, getter=isDefault) BOOL zDefault;

- (id) initWithName: (NSString*) name andNib: (NSString*) nibName;
- (id) initWithName: (NSString*) name andNib: (NSString*) nibName makeDefault: (BOOL) deflt;

@end

@interface ZTTabsAbstract : NSObject {
	IBOutlet NSArray	*iContents;
}

@property (nonatomic, readonly, getter=contents) NSArray* iContents;

@end
