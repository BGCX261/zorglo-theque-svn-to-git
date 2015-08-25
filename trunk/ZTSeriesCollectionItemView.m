//
//  ZTSeriesCollectionItemView.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 14/04/10.
//  Copyright 2010 Zorglo Software. All rights reserved.
//

#import "ZTSeriesCollectionItemView.h"
#import "ZTSerieVolumesDelegate.h"
#import "ZTEditSerieDelegate.h"
#import "NSButton_Extensions.h"
#import "ZTSerieManagedObject.h"


@interface ZTSeriesCollectionItemView (Private)

- (void) expandSerieVolumes;
- (void) addInfoButton;
- (void) allowEditingTitle;

@end


@implementation ZTSeriesCollectionItemView

@synthesize zVolumeViewDel;
@synthesize zEditViewDel;
@synthesize bSerie;

- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self addInfoButton];
		zEditingTitle = NO;
	}
	return self;
}

- (NSUInteger) nbOfShadows
{
	if ([((ZTSerieManagedObject*)self.serie).volumes count] <= 1)
		return 0;
	else if ([((ZTSerieManagedObject*)self.serie).volumes count] <= 1)
		return 3;
	else
		return 2;
}

- (void) addInfoButton
{
	// As of the copy of the view, an IBAction is linked to the wrong instance
	// So we do it ourselves after the copy
	zInfoButton = [[NSButton alloc] initWithFrame:NSMakeRect(139, 0, 19, 19)];
	[zInfoButton setBezelStyle:NSRecessedBezelStyle];
	[zInfoButton setButtonType:NSMomentaryLightButton];
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *boldItalic = [fontManager fontWithFamily:@"Times New Roman"
											  traits:NSBoldFontMask|NSItalicFontMask
											  weight:0
												size:14];
	[zInfoButton setFont:boldItalic];
	[zInfoButton setTitle:@"i"];
	[zInfoButton setTarget:self];
	[zInfoButton setAction:@selector(getInfo:)];
	[zInfoButton setTextColor:[NSColor whiteColor]];
	
	[self addSubview:zInfoButton];
}

- (void) awakeFromNib
{
	if (!zAwokeFromNib) {
		[self bind:@"bSerieTitle" toObject:iCollectionViewItem withKeyPath:@"representedObject.name" options:nil];
		[self bind:@"bSerieCoverFile" toObject:iCollectionViewItem withKeyPath:@"representedObject.firstDefinedCover" options:nil];
		[self bind:@"serie" toObject:iCollectionViewItem withKeyPath:@"representedObject" options:nil];
		[super awakeFromNib];
	}
	
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	[zInfoButton removeFromSuperview];
	[self addSubview:zInfoButton];
}

- (BOOL) shadowed {
	return YES;
}

- (void) expandSerieVolumes
{
	if (!self.volumeViewDel) {
		self.volumeViewDel = [[ZTSerieVolumesDelegate alloc] initWithItem:self];
	}
	[NSBundle loadNibNamed:@"SerieView" owner:self.volumeViewDel];
	[self.volumeViewDel loadVolumesViewInto: [self superview]];
}

- (void) allowEditingTitle 
{
	zEditingTitle = YES;
	
	// Style
	zEditTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(zSerieTitleLayer.frame.origin.x, zSerieTitleLayer.frame.origin.y, zSerieTitleLayer.frame.size.width, zSerieTitleLayer.frame.size.height)];
	[zEditTitle setEditable:YES];
	[zEditTitle setBezelStyle:NSShadowlessSquareBezelStyle];
	[zEditTitle setDrawsBackground:NO];
	[zEditTitle setBordered:NO];
	[zEditTitle setTextColor:[NSColor whiteColor]];
	[zEditTitle performSelector:@selector(selectText:) withObject:self afterDelay:0];
	
	// Bind
	[zEditTitle bind:@"value" toObject:self.serie withKeyPath:@"name" options:nil];
	
	// Registre for notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(textDidEndEditing:) name:NSControlTextDidEndEditingNotification object:nil];
	
	// Display
	zSerieTitleLayer.hidden = YES;
	[self addSubview:zEditTitle];
}

- (void)mouseDown:(NSEvent *)theEvent {
	if ([theEvent clickCount] == 2) {
		NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView: nil];
		CALayer *currentLayer = [zSerieTitleLayer hitTest:CGPointMake(location.x, location.y)];
		
		if (currentLayer == zSerieTitleLayer) {
			[self allowEditingTitle];
		}
		else {
			// Now expands to the Series's volumes view
			[self expandSerieVolumes];
		}

	}
	[super mouseDown:theEvent];
}

- (IBAction) getInfo: (id) sender
{
	if (!self.editViewDel) {
		self.editViewDel = [[ZTEditSerieDelegate alloc] initWithItem:self];
	}
	if ([NSBundle loadNibNamed:@"EditSerie" owner:self.editViewDel]) {
		[self.editViewDel showPanel];
	}
}

#pragma mark Title Field Editing Notifications

- (void)textDidEndEditing:(NSNotification *)aNotification
{
	[zEditTitle removeFromSuperview];
	zEditTitle = nil;
	zSerieTitleLayer.hidden = NO;
	zEditTitle = NO;
}

@end


