//
//  ZTSourceItemView.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 10/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZTSourceItemView : NSTextFieldCell {
	NSImage *zImage;
}

- (void)setImage:(NSImage *)anImage;
- (NSImage*)image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView;
- (NSSize)cellSize;

@end
