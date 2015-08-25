//
//  ZTSourceItemView.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 10/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//


#import "ZTSourceItemView.h"
#import "ZTSourceNode.h"

@implementation ZTSourceItemView

#define z_IconImageSize		24.0

#define z_ImageOriginXOffset 3
#define z_ImageOriginYOffset 2

#define z_TextOriginXOffset	2
#define z_TextOriginYOffset	2
#define z_TextHeightAdjust	4


- (id)init
{
	self = [super init];
	
	// we want a smaller font
	//[self setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
	return self;
}


- (id)copyWithZone:(NSZone*)zone
{
    ZTSourceItemView *cell = (ZTSourceItemView*)[super copyWithZone:zone];
    cell->zImage = zImage;
    return cell;
}

- (void)setImage:(NSImage*)theImage
{
    if (zImage != theImage)
	{
		zImage = theImage;
		[zImage setSize:NSMakeSize(z_IconImageSize, z_IconImageSize)];
    }
}

- (NSImage*)image
{
    return zImage;
}

- (BOOL)isGroupCell
{
   	return ([self image] == nil && [[self title] length] > 0);
}

- (NSRect)titleRectForBounds:(NSRect)cellRect
{	
	// the cell has an image: draw the normal item cell
	NSSize imageSize;
	NSRect imageFrame;
	
	imageSize = [zImage size];
	NSDivideRect(cellRect, &imageFrame, &cellRect, 3 + imageSize.width, NSMinXEdge);
	
	imageFrame.origin.x += z_ImageOriginXOffset;
	imageFrame.origin.y -= z_ImageOriginYOffset;
	imageFrame.size = imageSize;
	
	imageFrame.origin.y += ceil((cellRect.size.height - imageFrame.size.height) / 2);
	
	NSRect newFrame = cellRect;
	newFrame.origin.x += z_TextOriginXOffset;
	newFrame.origin.y += z_TextOriginYOffset;
	newFrame.size.height -= z_TextHeightAdjust;
	
	return newFrame;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject event:(NSEvent*)theEvent
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	if (zImage != nil)
	{
		// the cell has an image: draw the normal item cell
		NSSize imageSize;
        NSRect imageFrame;
		
        imageSize = [zImage size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
		
        imageFrame.origin.x += z_ImageOriginXOffset;
		imageFrame.origin.y -= z_ImageOriginYOffset;
        imageFrame.size = imageSize;
		
        if ([controlView isFlipped])
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        else
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
		[zImage compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
		
		NSRect newFrame = cellFrame;
		newFrame.origin.x += z_TextOriginXOffset;
		newFrame.origin.y += z_TextOriginYOffset;
		newFrame.size.height -= z_TextHeightAdjust;
		[super drawWithFrame:newFrame inView:controlView];
    }
	else
	{
		if ([self isGroupCell])
		{
			// Center the text in the cellFrame, and call super to do thew ork of actually drawing. 
			CGFloat yOffset = floor((NSHeight(cellFrame) - [[self attributedStringValue] size].height) / 2.0);
			cellFrame.origin.y += yOffset;
			cellFrame.size.height -= (z_TextOriginYOffset*yOffset);
			[super drawWithFrame:cellFrame inView:controlView];
		}
	}
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (zImage ? [zImage size].width : 0) + 3;
    return cellSize;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
	NSInteger result = NSCellHitContentArea;
	
	NSOutlineView* hostingOutlineView = (NSOutlineView*)[self controlView];
	if (hostingOutlineView)
	{
		NSInteger selectedRow = [hostingOutlineView selectedRow];
		ZTSourceNode* node = [[hostingOutlineView itemAtRow:selectedRow] representedObject];
		
		if (![node isDraggable])
			result = NSCellHitTrackableArea;
	}
	
	return result;
}

@end
