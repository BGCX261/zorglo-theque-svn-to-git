//
//  ZTAutoCompleteTextField.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 27/02/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTAutoCompleteTextField.h"
#import "ZTSerieManagedObject.h"
#import "ZorgloThe_que_AppDelegate.h"
#import "ZTDeleteHandler.h"
#import "ZTRenameHandler.h"
#import "ZTVolumeManagedObject.h"
#import "ZTAutoCompleteDelegate.h"


@interface ZTAutoCompleteTextField(Private)

- (void) createPopupWindow;
- (void) createTableView;
- (void) setTableViewColumns;
- (NSScrollView *) createScrollView;
- (void) resizePopup:(BOOL)forceResize;
- (void) setNewValue:(NSString *)aString fromLocation:(unsigned int)aLocation;
- (void) startSearch:(NSString *)aString;

- (void) onRowClicked:(NSNotification *)aNote;
- (void) clearSelection;

- (ZTSerieManagedObject *) findInStore: (NSString *) aString;

@end

#pragma mark -

@implementation ZTAutoCompleteWindow

- (BOOL)isKeyWindow
{
	return YES;
}

@end

#pragma mark -

@implementation ZTAutoCompleteTextField

@synthesize iVolumesController;
@synthesize zTableView;
@synthesize zDataSource;
@synthesize rEntityName;
@synthesize rDeleteFormat;
@synthesize rRenameFormat;

- (void) createPopupWindow {
	zPopupWin = [[ZTAutoCompleteWindow alloc] initWithContentRect:NSMakeRect(0,0,0,0)
													  styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[zPopupWin setReleasedWhenClosed:NO];
	[zPopupWin setHasShadow:YES];
	[zPopupWin setAlphaValue:0.9];
}

- (void) createTableView {
	zTableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0,0,0,0)];
	[zTableView setIntercellSpacing:NSMakeSize(1, 2)];
	[zTableView setTarget:self];
	[zTableView setAction:@selector(onRowClicked:)];
}

- (void) setTableViewColumns {
	// Add the column that will display the auto-complete text
	NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"serieName"];
	[column setEditable: NO];
	[zTableView addTableColumn: column];
	
	// Hide the table header
	[zTableView setHeaderView: nil];
}

- (NSScrollView *) createScrollView {
	NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0,0,0,0)];
	[scrollView setHasVerticalScroller: YES];
	[[scrollView verticalScroller] setControlSize:NSSmallControlSize];
	[scrollView setDocumentView: zTableView];
	return scrollView;
}

#pragma mark -

- (int) visibleRows 
{
	NSInteger numberOfResults = [zDataSource rowCount];
	return (numberOfResults < z_MaxRows) ? numberOfResults : z_MaxRows;
}

- (void) selectRowAt:(int)aRow
{
	if (aRow >= -1 && [zDataSource rowCount] > 0) {
		// show the popup
		[self openPopup];
		
		if ( aRow == -1 )
			[zTableView deselectAll:self];
		else {
			[zTableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:aRow] byExtendingSelection:NO];
			[zTableView scrollRowToVisible: aRow];
		}
	}
}

- (void) selectRowBy:(int)aRows
{
	int row = [zTableView selectedRow];
	
	if (row == -1 && aRows < 0) {
		// if nothing is selected and you scroll up, go to last row
		row = [zTableView numberOfRows]-1;
	}
	else if (row == [zTableView numberOfRows]-1 && aRows == 1) {
		// if the last row is selected and you scroll down, do nothing. pins
		// the selection at the bottom.
	}
	else if (aRows+row < 0) {
		// if you scroll up beyond first row...
		if (row == 0)
			row = -1; // ...and first row is selected, select nothing
		else
			row = 0; // ...else, go to first row
	}
	else if (aRows+row >= [zTableView numberOfRows]) {
		// if you scroll down beyond the last row...
		if (row == [zTableView numberOfRows]-1)
			row = 0; // and last row is selected, select first row
		else
			row = [zTableView numberOfRows]-1; // else, go to last row
	}
	else {
		// no special case, just increment current row
		row += aRows;
	}
    
	[self selectRowAt:row];
}



#pragma mark -

- (void) awakeFromNib
{	
	NSScrollView *scrollView;
	
	ZTAutoCompleteDelegate *myDelegate = [[ZTAutoCompleteDelegate alloc] initForEntityName: self.rEntityName
														  options: ZTAllowUndoOnDelete | ZTAllowUndoOnRename | ZTDisplayNotificationOnDelete | ZTDisplayNotificationOnRename | ZTAllowDelete];
	myDelegate.deleteFormat = self.rDeleteFormat;
	myDelegate.renameFormat = self.rRenameFormat;
	myDelegate.textField = self;
	zDataSource = [[ZTAutoCompleteDataSource alloc] initForEntityName:self.rEntityName];
	
	[self setDelegate: myDelegate];
	
	[self createPopupWindow];
	[self createTableView];
	
	[self setAutoresizesSubviews:YES];
	
	[self setTableViewColumns];
	scrollView = [self createScrollView];
	
	[zTableView setDataSource: zDataSource];
	
	[zPopupWin setContentView:scrollView];
}

-(id) fieldEditor
{
	return [[self window] fieldEditor:NO forObject:self];
}



#pragma mark -

- (void) openPopup
{
	[self resizePopup:YES];
	
	// show the popup
	if ([zPopupWin isVisible] == NO)
	{
		[[self window] addChildWindow:zPopupWin ordered:NSWindowAbove];
		[zPopupWin orderFront:nil];
	}
}

- (void) resizePopup:(BOOL)forceResize
{
	if ([self visibleRows] == 0) {
		[self closePopup];
		return;
	}
	
	// don't waste time resizing stuff that is not visible (unless we're about
	// to show the popup)
	if (![self isOpen] && !forceResize)
		return;
	
	// get the origin of the text field in coordinates of the root view
	NSRect locationFrame = [self bounds];
	NSPoint locationOrigin = locationFrame.origin;
	locationOrigin.y += NSHeight(locationFrame);    // we want bottom left
	locationOrigin = [self convertPoint:locationOrigin toView:nil];
	
	// get the height of the table view
	NSRect winFrame = [[self window] frame];
	int tableHeight = (int)([zTableView rowHeight] + [zTableView intercellSpacing].height) * [self visibleRows];
	
	// make the columns split the width of the popup
	[[zTableView tableColumnWithIdentifier:@"serieName"] setWidth:(locationFrame.size.width)]; //TODO: Make this less specific
	
	// position the popup anchored to bottom/left of text field
	NSRect popupFrame = NSMakeRect(winFrame.origin.x + locationOrigin.x + z_FrameMargin,
								   ((winFrame.origin.y + locationOrigin.y) - tableHeight) - z_FrameMargin,
								   locationFrame.size.width - (2 * z_FrameMargin),
								   tableHeight);
	[zPopupWin setFrame:popupFrame display:NO];
}

- (void) closePopup
{
	[[zPopupWin parentWindow] removeChildWindow:zPopupWin];
	[zPopupWin orderOut:nil];
	[self clearSelection];
}

- (BOOL) isOpen
{
	return [zPopupWin isVisible];
}

#pragma mark Events

- (void) enterResult:(int)aRow
{
	if ([zDataSource rowCount] > aRow) {
		[self setNewValue:[zDataSource resultForRow:[zTableView selectedRow] columnIdentifier:@"serieName"] fromLocation:0];
		[self closePopup];
	}
}

- (void) setNewValue:(NSString *)aString fromLocation:(unsigned int)aLocation
{
	NSTextView* fieldEditor = [self fieldEditor];
	NSString* curValue = [fieldEditor string];
	
	unsigned curLength = [curValue length];
	if (aLocation > curLength)    // sanity check or AppKit crashes
		return;
	
	if ((aLocation + [aString length] == curLength) && [curValue compare:aString options:0 range:NSMakeRange(aLocation, [aString length])] == NSOrderedSame)
		return;  // nothing to do
	
	NSRange range = NSMakeRange(aLocation, [curValue length] - aLocation);
	if ([fieldEditor shouldChangeTextInRange:range replacementString:aString])
	{
		[[fieldEditor textStorage] replaceCharactersInRange:range withString:aString];
		if (NSMaxRange(range) == 0) // will only be true if the field is empty
			[fieldEditor setFont:[self font]]; // wrong font will be used otherwise
		
		// Whenever we send [self didChangeText], we trigger the
		// textDidChange method, which will begin a new search with
		// a new search string (which we just inserted) if the selection
		// is at the end of the string.  So, we "select" the first character
		// to prevent that badness from happening.
		[fieldEditor setSelectedRange:NSMakeRange(0,0)];    
		[fieldEditor didChangeText];
	}
	
	// sanity check and don't update the highlight if we're starting from the
	// beginning of the string. There's no need for that since no autocomplete
	// result would ever replace the string from location 0.
	if (aLocation > [[fieldEditor string] length] || !aLocation)
		return;
	range = NSMakeRange(aLocation, [[fieldEditor string] length] - aLocation);
	[fieldEditor setSelectedRange:range];
	
}


- (void) onRowClicked:(NSNotification *)aNote
{
	[self enterResult:[zTableView clickedRow]];
	[[self window] endEditingFor:self];
}

- (void) clearSelection
{
	// close up the popup and make sure we clear any past selection. We cannot
	// use |selectAt:-1| because that would show the popup, even for a brief instant
	// and cause flashing.
	[zTableView deselectAll:self];
}

@end
