//
//  ZTSerieTitleView.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 1/05/10.
//  Copyright 2010 Zorglo Software. All rights reserved.
//

#import "ZTSerieTitleView.h"


@implementation ZTSerieTitleView

@synthesize zType;
@synthesize zAlpha;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        zType = 0;
		zAlpha = 100;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    switch (zType) {
		case 0:
			[[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.859 alpha:(0.01 * zAlpha)] 
										   endingColor: [NSColor colorWithCalibratedRed:0.585 green:0.581 blue:0.585 alpha:(0.01 * zAlpha)]] 
			 drawInRect:dirtyRect angle:270];
			break;
		case 1:
			[[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:(0.01 * zAlpha)] 
										   endingColor: [NSColor colorWithCalibratedWhite:0.150 alpha:(0.01 * zAlpha)]] 
			 drawInRect:dirtyRect angle:90];
		default:
			break;
	}
	
	[super drawRect:dirtyRect];
}

@end
