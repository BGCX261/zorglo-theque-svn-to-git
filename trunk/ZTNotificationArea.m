//
//  ZTNotificationArea.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 2/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTNotificationArea.h"


@implementation ZTNotificationArea

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.400 
																		 green:0.600 
																		  blue:0.540 
																		 alpha:1.000] 
								   endingColor:[NSColor colorWithCalibratedRed:0.400 
																		 green:0.730 
																		  blue:0.540 
																		 alpha:1.000]]
	 drawInRect: dirtyRect angle: 270];
	
	 [super drawRect:dirtyRect];
}


@end
