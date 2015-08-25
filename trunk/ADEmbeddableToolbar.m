/*
 Copyright (c) 2009, Aaron Dodson
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the Aaron Dodson or Stuffed Iggy Software nor the
 names of their contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY Aaron Dodson ``AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL Aaron Dodson BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "ADEmbeddableToolbar.h"

@implementation ADEmbeddableToolbar

#pragma mark -
#pragma mark Setup

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
	{
        items = [[NSMutableArray alloc] init];
		
		//Give ourselves some spacing at the beginning of the items
		xOffset = 5;
		
		//Create our overflow menu
		overflow = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(frame.size.width - 30, 11, 30, 26)];
		[[overflow cell] setArrowPosition:NSPopUpNoArrow];
		[overflow setBordered:NO];
		NSMenu *overflowMenu = [[NSMenu alloc] init];
		NSMenuItem *overflowArrow = [[NSMenuItem alloc] init];
		[overflowArrow setImage:[NSImage imageNamed:@"more"]];
		[overflowArrow setHidden:YES];
		[overflowMenu addItem:overflowArrow];
		[overflowMenu release];
		[overflowArrow release];
		
		[self addSubview:overflow];
		
		displayMode = NSToolbarDisplayModeIconAndLabel;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect 
{
	//Establish the width we may need on the end for the disclosure button
	int width = [self frame].size.width - 40;
	
	//Assume every item fits
	runnethOver = NO;
	
	//Go through our items; if any of them are not fully displayed, remove them from view
	//If an item can be displayed, add it back to the view
	for (int i = 0; i < [items count]; i++)
	{
		if ([[items objectAtIndex:i] frame].origin.x + [[items objectAtIndex:i] frame].size.width > width)
		{
			[[items objectAtIndex:i] removeFromSuperview];
			runnethOver = YES;
		}
		else
		{
			if (displayModeChanged)
				[[items objectAtIndex:i] removeFromSuperview];
			
			if (![[self subviews] containsObject:[items objectAtIndex:i]])
			{
				if (displayMode == NSToolbarDisplayModeLabelOnly && ![[[items objectAtIndex:i] className] isEqualToString:@"NSView"])
					[[items objectAtIndex:i] setImagePosition:NSNoImage];
				else if (displayMode == NSToolbarDisplayModeIconOnly && ![[[items objectAtIndex:i] className] isEqualToString:@"NSView"])
					[[items objectAtIndex:i] setImagePosition:NSImageOnly];
				else if (![[[items objectAtIndex:i] className] isEqualToString:@"NSView"])
					[[items objectAtIndex:i] setImagePosition:NSImageAbove];
				
				if (!(displayMode == NSToolbarDisplayModeLabelOnly && [[[items objectAtIndex:i] className] isEqualToString:@"NSView"]))
					[self addSubview:[items objectAtIndex:i]];
			}
		}
	}
	
	displayModeChanged = NO;
	
	//Hide or update the overflow menu as necessary
	if (runnethOver)
		[self updateOverflowMenu];
	else
		[overflow setHidden:YES];
	
	//Move the overflow menu to the current end of the view
	[overflow setFrame:NSMakeRect([self frame].size.width - 30, 11, 30, 26)];
}

- (void)updateOverflowMenu
{
	//Create the menu item with the arrows
	NSMenu *overflowMenu = [[NSMenu alloc] init];
	NSMenuItem *overflowArrow = [[NSMenuItem alloc] init];
	[overflowArrow setImage:[NSImage imageNamed:@"more"]];
	[overflowArrow setHidden:YES];
	[overflowMenu addItem:overflowArrow];
	[overflowArrow release];
	
	//Add menu items for any hidden buttons
	//We ignore views here, because they generally can't be interacted with in menu form
	for (int i = 0; i < [items count]; i++)
	{
		if (![[self subviews] containsObject:[items objectAtIndex:i]])
		{
			if (![[[items objectAtIndex:i] className] isEqualToString:@"NSView"])
			{
				[overflowMenu addItemWithTitle:[[items objectAtIndex:i] title] action:[[items objectAtIndex:i] action] keyEquivalent:@""];
				[[overflowMenu itemAtIndex:([[overflowMenu itemArray] count] -1)] setTarget:[[items objectAtIndex:i] target]];
				[[overflowMenu itemAtIndex:([[overflowMenu itemArray] count] -1)] setTag:[[items objectAtIndex:i] tag]];
				[[overflowMenu itemAtIndex:([[overflowMenu itemArray] count] -1)] setKeyEquivalent:[[items objectAtIndex:i] keyEquivalent]];
			}
		}
	}
	
	//Add the new menu to the overflow button
	[overflow setMenu:overflowMenu];
	[overflowMenu release];
	[overflow setHidden:NO];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

#pragma mark -
#pragma mark Adding Items

- (NSButton*)addItemWithIcon:(NSImage *)icon title:(NSString *)title tag:(int)tag keyEquivalent:(NSString *)equivalent target:(id)target selector:(SEL)selector tooltip:(NSString *)hint
{
	//Determine the size of the item based on the width of its title
	int width;
	if ([title sizeWithAttributes:nil].width <= 48)
		width = 48;
	else
		width = [title sizeWithAttributes:nil].width + 5;
	
	//Create an NSButton and configure it
	NSButton *toolbarItem = [[NSButton alloc] initWithFrame:NSMakeRect(xOffset, 0, width, 48)];
	[toolbarItem setImage:icon];
	[toolbarItem setTitle:title];
	[toolbarItem setTarget:target];
	[toolbarItem setAction:selector];
	[toolbarItem setBordered:NO];
	[toolbarItem setImagePosition:NSImageAbove];
	[toolbarItem setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
	[toolbarItem setButtonType:NSMomentaryChangeButton];
	[toolbarItem setTag:tag];
	[toolbarItem setToolTip:hint];
	[toolbarItem setKeyEquivalent:equivalent];
	
	if (tag != 10)
		[toolbarItem setKeyEquivalentModifierMask:NSCommandKeyMask];
	else
		[toolbarItem setKeyEquivalentModifierMask:(NSCommandKeyMask|NSAlternateKeyMask)];
	
	//Add the button as a subview
	[self addSubview:toolbarItem];
	
	//Increase the x offset for the next item by this item's width and some extra space
	xOffset+= (width + 5);
	
	//Add the button to the array of items
	[items addObject:toolbarItem];
	
	return toolbarItem;
}

- (void)addItemWithView:(NSView *)view title:(NSString *)title
{
	//Determine the item's width based on the view or the title's width (whichever is greater)
	int width;
	if ([title sizeWithAttributes:nil].width > [view frame].size.width)
		width = [title sizeWithAttributes:nil].width + 5;
	else
		width = [view frame].size.width + 5;
	
	//Create a view to act as a container for the view and its title					  
	NSView *masterView = [[NSView alloc] initWithFrame:NSMakeRect(xOffset, 0, width, 48)];
	[view setFrame:NSMakeRect(([masterView frame].size.width - [view frame].size.width) / 2, ([self frame].size.height - [view frame].size.height) / 2, [view frame].size.width, [view frame].size.height)];
	[masterView addSubview:view];
	NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, [masterView frame].size.width, 14)];
	[label setStringValue:title];
	[label setEditable:NO];
	[label setSelectable:NO];
	[label setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
	[label setBordered:NO];
	[label setDrawsBackground:NO];
	[label setAlignment:NSCenterTextAlignment];
	[masterView addSubview:label];
	[label release];
	
	//Add the container view to ourself
	[self addSubview:masterView];
	
	//Update our x offset and add the container view to the list of items
	xOffset+= (width + 5);
	[items addObject:masterView];
	[masterView release];
}

#pragma mark -
#pragma mark Modifying Items

- (void)setTitle:(NSString *)newTitle forItemAtIndex:(int)index
{
	[[items objectAtIndex:index] setTitle:newTitle];
}

#pragma mark -
#pragma mark Appearance

- (void)changeDisplayMode:(id)sender
{
	displayModeChanged = YES;
	if ([[sender title] isEqualToString:@"Icon & Text"] && displayMode != NSToolbarDisplayModeIconAndLabel)
	{
		[self setDisplayMode:NSToolbarDisplayModeIconAndLabel];
		[self setFrame:NSMakeRect([self frame].origin.x, [self frame].origin.y + 16, [self frame].size.width, [self frame].size.height)];
		[partnerView setFrame:NSMakeRect([partnerView frame].origin.x, [partnerView frame].origin.y + 32, [partnerView frame].size.width, [partnerView frame].size.height - 32)];
	}
	else if ([[sender title] isEqualToString:@"Text Only"] && displayMode != NSToolbarDisplayModeLabelOnly)
	{
		[self setDisplayMode:NSToolbarDisplayModeLabelOnly];
		[self setFrame:NSMakeRect([self frame].origin.x, [self frame].origin.y - 16, [self frame].size.width, [self frame].size.height)];
		[partnerView setFrame:NSMakeRect([partnerView frame].origin.x, [partnerView frame].origin.y - 32, [partnerView frame].size.width, [partnerView frame].size.height + 32)];
	}
}

- (void)setDisplayMode:(NSToolbarDisplayMode)newMode
{
	displayMode = newMode;
	
	for (int i = 0; i < [[self subviews] count]; i++)
	{
		if ([[[[self subviews] objectAtIndex:i] className] isEqualToString:@"NSButton"])
		{
			if (displayMode == NSToolbarDisplayModeLabelOnly)
				[[[self subviews] objectAtIndex:i] setImagePosition:NSNoImage];
			else if (displayMode == NSToolbarDisplayModeIconOnly)
				[[[self subviews] objectAtIndex:i] setImagePosition:NSImageOnly];
			else
				[[[self subviews] objectAtIndex:i] setImagePosition:NSImageAbove];
		}
	}
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenu *defaultMenu = [[[NSMenu alloc] init] autorelease];
	
	[defaultMenu addItemWithTitle:@"Icon & Text" action:@selector(changeDisplayMode:) keyEquivalent:@""];
	[defaultMenu addItemWithTitle:@"Text Only" action:@selector(changeDisplayMode:) keyEquivalent:@""];
	
	if (displayMode == NSToolbarDisplayModeLabelOnly)
		[[defaultMenu itemAtIndex:1] setState:NSOnState];
	else
		[[defaultMenu itemAtIndex:0] setState:NSOnState];
	
	return defaultMenu;
}

#pragma mark -
#pragma mark Removing Items

- (BOOL)removeItemAtIndex:(int)index
{
	//Get the width of the item to remove
	int width = [[items objectAtIndex:index] frame].size.width + 5;
	
	//Nuke the item to be removed from ourself and the array of items
	[[items objectAtIndex:index] removeFromSuperview];
	[items removeObjectAtIndex:index];
	
	//Update the location of all the items after the removed item
	for (int i = index; i < [items count]; i++)
	{
		[[items objectAtIndex:i] setFrame:NSMakeRect([[items objectAtIndex:i] frame].origin.x - width, [[items objectAtIndex:i] frame].origin.y, [[items objectAtIndex:i] frame].size.width, [[items objectAtIndex:i] frame].size.height)];
	}
	
	//Remove every item from ourself
	for (int i = 0; i < [items count]; i++)
		[[items objectAtIndex:i] removeFromSuperviewWithoutNeedingDisplay];
	
	//Add back all the remaining items
	for (int i = 0; i < [items count]; i++)
		[self addSubview:[items objectAtIndex:i]];
	
	//Prepare our x offset for adding additional items
	xOffset = ([[items objectAtIndex:[items count] - 1] frame].origin.x + [[items objectAtIndex:[items count] - 1] frame].size.width + 5);
	
	return TRUE;
}

#pragma mark -
#pragma mark Cleaning Up

- (void)dealloc
{
	[items release];
	[overflow release];
	[super dealloc];
}

@end