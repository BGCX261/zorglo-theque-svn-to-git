//
//  ZTSourcesDataSource.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 9/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZTSourceNode.h";

@class ZTSourceNode;

@interface ZTSourcesDataSource : NSObject {
	ZTSourceNode *zRoot;
	NSMutableArray *contents;
	BOOL zBuildingOutlineView;
	BOOL zBuilt;
	
	IBOutlet NSOutlineView *zOutlineView;
	IBOutlet NSTreeController	*zTreeController;
	
	IBOutlet NSView *zContentView;
	IBOutlet NSView *zVolumesView;
	IBOutlet NSView *zSeriesView;
	IBOutlet NSView *zEditorsView;
	IBOutlet NSView *zAuthorsView;
	
	NSManagedObjectContext* managedObjectContext;
	
	NSMutableArray* zLoadedViews;
	
	NSIndexPath* zListsIndexPath;
}

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (void) addSourceNamed: (NSString*) name linkedTo: (NSString*) nibName atIndex: (NSIndexPath*) indexPath withLogo: (NSString*) logoFileName;

@end
