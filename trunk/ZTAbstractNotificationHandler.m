//
//  ZTAbstractNotificationHandler.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 9/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTAbstractNotificationHandler.h"


@implementation ZTAbstractNotificationHandler

- (void) confirmAction: (id) sender owner: (ZTNotificationOwner *)owner forSelection: (NSString *) selected {
	// By default, simply dismiss the notification area
	[owner restoreMainView];
}

- (void) cancelAction: (id) sender owner: (ZTNotificationOwner *)owner forSelection: (NSString *) selected {
	// No default for the cancel
	// It is mandatory to override it
	[self doesNotRecognizeSelector:_cmd];
}

@end
