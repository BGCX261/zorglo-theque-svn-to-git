//
//  ZTTabView.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 13/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZTTabView : NSView {
	IBOutlet NSView				*iTabContentView;
	IBOutlet NSArrayController	*iController;
	IBOutlet NSView			*iLoadedView;
	IBOutlet NSArrayController *seriesArrayController;
	
	NSButton		*zSelectedButton;
	NSArray			*zTabsNames;
	NSMutableArray	*zTabs;
	BOOL			zLoaded;
	
	NSView			*zCurrentView;
	
	
	NSManagedObjectContext* managedObjectContext;
}

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSArrayController *seriesArrayController;

@end
