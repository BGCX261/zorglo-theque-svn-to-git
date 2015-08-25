//
//  ZTNotificationOwner.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 7/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZTNotificationArea.h"
#import "ZTAbstractNotificationHandler.h"

@class ZTAbstractNotificationHandler;


@interface ZTNotificationOwner : NSObject {
	// Notification area outlets
	IBOutlet ZTNotificationArea* zNotificationView;
	IBOutlet NSButton* zCancelAction;
	IBOutlet NSButton* zConfirmAction;
	IBOutlet NSPopUpButton* zAdditionalChoices;
	IBOutlet NSTextField* zNotificationText;
	
	// Main window outlets
	IBOutlet NSView* zMainView;
	
	ZTAbstractNotificationHandler *zHandler;
}

@property (nonatomic, readonly) ZTNotificationArea *zNotificationView;

- (IBAction) cancelAction: (id) anObject;
- (IBAction) confirmAction: (id) anObject;

- (void) showNotificationWithText: (NSString *) title 
					   cancelText: (NSString *) cancel 
					  confirmText: (NSString *) confirm 
					  withHandler: (ZTAbstractNotificationHandler *) handler 
				   withDataSource: (id) dataSource;
- (void) restoreMainView;



@end
