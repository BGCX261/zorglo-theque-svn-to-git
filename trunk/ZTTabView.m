//
//  ZTTabView.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 13/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTTabView.h"
#import "ZTTabsForSeries.h"

@interface ZTTabView (Private)
- (void) populateTabs;
- (void) shiftTabs: (NSRect) newRect;
- (void)changeView;
- (void)updateSelection: (NSButton *)newSelection;
@end

@implementation ZTTabView

#define z_ButtonHeight	25
#define z_ButtonWidth	90
#define z_ButtonOverlap	10

@synthesize seriesArrayController;


- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    return [[NSApp delegate] managedObjectContext];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		zTabs = [[NSMutableArray alloc] init];
		zLoaded = NO;
    }
    return self;
}
- (void)awakeFromNib
{
	if (!zLoaded) {
		[self bind:@"zTabsNames" toObject:iController withKeyPath:@"arrangedObjects" options:nil];
		[self populateTabs];
	}
}

- (void) populateTabs
{	
	if ([zTabsNames count] > 0) {
		NSButton *tab;
		zLoaded = YES;
		
		NSRect defaultFrame, viewFrame;
		viewFrame = [self frame];
		
		defaultFrame.size.height = z_ButtonHeight;
		defaultFrame.size.width = z_ButtonWidth;
		defaultFrame.origin.y = floor((viewFrame.size.height - defaultFrame.size.height) / 2);
		defaultFrame.origin.x = floor((viewFrame.size.width - ([zTabsNames count]*(z_ButtonWidth - z_ButtonOverlap))) / 2);
		
		NSInteger state = NSOnState;
		NSInteger i = 0;
		for (ZTTabInfo *tabInfo in zTabsNames) {
			if (i == [zTabsNames count]-1) {
				defaultFrame.size.width -= z_ButtonOverlap;
			}
			
			tab = [[NSButton alloc] initWithFrame:defaultFrame];
			[tab setTitle:tabInfo.name];
			[tab setBezelStyle:NSTexturedSquareBezelStyle];
			[tab setButtonType:NSPushOnPushOffButton];
			[tab setState:state];
			[tab setTarget:self];
			[tab setAction:@selector(tabClicked:)];
			if (state == NSOnState) {
				zSelectedButton = tab;
				[iController setSelectionIndex:i];
				
				if (!iLoadedView) {
					ZTTabInfo *firstTab = [zTabsNames objectAtIndex:0];
					[NSBundle loadNibNamed:firstTab.nibName owner:self];
					[self changeView];
				}
			}
			
			[self addSubview:tab];
			
			[zTabs addObject:tab];
			[tab setNeedsDisplay: YES];
			
			defaultFrame.origin.x += (z_ButtonWidth - z_ButtonOverlap);
			state = NSOffState;
			
			++i;
		}
	}
}

- (void) shiftTabs: (NSRect) newRect {
	if ([zTabs count] > 0) {
		NSRect currentFrame = [[zTabs objectAtIndex:0] frame];
		NSInteger newX = floor((newRect.size.width - ([zTabsNames count]*(z_ButtonWidth - z_ButtonOverlap))) / 2);
		NSInteger shift = newX - currentFrame.origin.x;
		if (shift != 0) {
			for (NSButton *tab in zTabs)
			{
				NSRect f = [tab frame];
				f.origin.x += shift;
				[tab setFrame:f];
				[tab setNeedsDisplay: YES];
			}
		}
	}
}

- (void)drawRect:(NSRect)dirtyRect {
	if (dirtyRect.size.width == [self bounds].size.width) {
		[self shiftTabs: [self bounds]];
	
	}
	[[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.900 alpha:1.000] 
								  endingColor:[NSColor colorWithCalibratedWhite:0.750 alpha:1.000]]
	 drawInRect:dirtyRect angle: 270];
	[self setNeedsDisplay:YES];
}

- (void) tabClicked: (id) sender
{
	if (sender) {
		// First, deselect the current tab
		if (zSelectedButton != sender) {
			[zSelectedButton setState:NSOffState];
			zSelectedButton = sender;
			[self updateSelection: sender];
			// Change the view
			ZTTabInfo *tabInfo = [[iController selectedObjects] objectAtIndex:0];
			
			if ([NSBundle loadNibNamed:tabInfo.nibName owner:self]) {
				[self changeView];
			}
		}
		else {
			[zSelectedButton setState:NSOnState];
		}
	}
	
}

- (void)updateSelection: (NSButton *)newSelection
{
	NSString *title = [newSelection title];
	
	NSUInteger i=0;
	for (ZTTabInfo *tabInfo in [iController arrangedObjects])
	{
		if (tabInfo.name == title) {
			[iController setSelectionIndex:i];
			break;
		}
		i++;
	}
}

- (void)changeView
{
	if (iLoadedView && iLoadedView != zCurrentView) 
	{
		
		NSRect contentRect = [iTabContentView bounds];
		[iLoadedView setFrame:contentRect];
		
		[iTabContentView addSubview:iLoadedView positioned:NSWindowAbove relativeTo: nil];
		[iLoadedView display];
		[iLoadedView setNeedsDisplay:YES];
		[iTabContentView setNeedsDisplay: YES];
		if (zCurrentView && [zCurrentView superview]) {
			[zCurrentView removeFromSuperview];
		}
		
		zCurrentView = iLoadedView;
		
	}
}




@end
