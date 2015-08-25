//
//  ZTBottomBar.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 14/05/10.
//  Copyright 2010 Zorglo Software. All rights reserved.
//

#import "ZTBottomBar.h"


@implementation ZTBottomBar

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

- (BOOL)mouseDownCanMoveWindow {
	return NO;
}

@end
