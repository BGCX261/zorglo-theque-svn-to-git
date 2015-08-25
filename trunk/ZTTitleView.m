//
//  ZTTitleView.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 14/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTTitleView.h"


@implementation ZTTitleView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.300 
																		green:0.600 
																		 blue:0.920 
																		alpha:1.000] 
								  endingColor:[NSColor colorWithCalibratedRed:0.060 
																		green:0.370 
																		 blue:0.850 
																		alpha:1.000]]
	 drawInRect: [self bounds] angle: 270];
	[super drawRect:dirtyRect];
}

@end
