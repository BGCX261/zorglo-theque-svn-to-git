//
//  ZorgloThe_que_AppDelegate.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 24/02/10.
//  Copyright Banque Centrale Européenne 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZTAutoCompleteTextField.h"
#import "ZTNotificationOwner.h"

@interface ZorgloThe_que_AppDelegate : NSObject 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	IBOutlet ZTNotificationOwner *notificationArea;
	IBOutlet NSOutlineView* zOutlineView;
	
	// Storage
	NSURL *zStorageURL;
}

@property (nonatomic) IBOutlet NSWindow *window;

@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) ZTNotificationOwner *notificationArea;
@property (nonatomic, getter=storageURL, readonly) NSURL *zStorageURL;

- (IBAction)saveAction:sender;

@end
