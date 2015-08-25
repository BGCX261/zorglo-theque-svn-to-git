//
//  ZTAbstractNotificationHandler.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 9/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZTNotificationOwner.h"

@class ZTNotificationOwner;

@interface ZTAbstractNotificationHandler : NSObject {

}

- (void) confirmAction: (id) sender owner: (ZTNotificationOwner *)owner forSelection: (NSString *) selected;
- (void) cancelAction: (id) sender owner: (ZTNotificationOwner *)owner forSelection: (NSString *) selected;

@end
