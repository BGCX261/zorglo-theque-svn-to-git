//
//  ZTSourcesDataSource.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 9/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTSourcesDataSource.h"
#import "ZTSourceItemView.h"

#define COLUMNID_NAME			@"__col1"


@interface ZTSourcesDataSource (Private)
- (void)removeContentView;
- (void)changeContentView: (ZTSourceNode *)selectedNode withView:(NSView *)myView;
- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
@end

@implementation ZTSourcesDataSource



- (id) init
{
	if (self = [super init])
	{
		contents = [[NSMutableArray alloc] init];
		
		zBuildingOutlineView = NO;
		zBuilt = NO;
		
	}
	return self;
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    return [[NSApp delegate] managedObjectContext];
}


- (void) addSourceNamed: (NSString*) name linkedTo: (NSString*) nibName atIndex: (NSIndexPath*) indexPath withLogo: (NSString*) logoFileName
{
	if (!indexPath) {
		indexPath = [zListsIndexPath indexPathByAddingIndex: 0];
	}
	ZTSourceNode *node = [[ZTSourceNode alloc] init];
	[node setNodeTitle:name];
	if (logoFileName) {
		NSString *path = [[NSBundle mainBundle] pathForResource:logoFileName ofType:@"png"];
		NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
		[node setNodeIcon:img];
		[node setLeaf:YES];
		node.nibName = nibName;
	}
	else {
		[node setLeaf:NO];
	}
	[zTreeController insertObject:node atArrangedObjectIndexPath:indexPath];

}

- (void)awakeFromNib
{
	if (!zBuilt) {
		zBuildingOutlineView = YES;
		NSTableColumn *tableColumn = [zOutlineView tableColumnWithIdentifier:COLUMNID_NAME];
		ZTSourceItemView *imageAndTextCell = [[ZTSourceItemView alloc] init];
		[imageAndTextCell setEditable:YES];
		[tableColumn setDataCell:imageAndTextCell];
		
		NSIndexPath* indexPath = nil;
		indexPath = [NSIndexPath indexPathWithIndex:0];
		
		[self addSourceNamed:@"BOOKS" linkedTo:nil atIndex:indexPath withLogo:nil];
		
		
		indexPath = [zTreeController selectionIndexPath];
		
		[self addSourceNamed:@"Volumes" linkedTo:@"Volumes" atIndex:[indexPath indexPathByAddingIndex:0] withLogo:@"volumes"];
		[self addSourceNamed:@"Series" linkedTo:@"Series" atIndex:[indexPath indexPathByAddingIndex:1] withLogo:@"series"];
		[self addSourceNamed:@"Editors" linkedTo:@"Editors" atIndex:[indexPath indexPathByAddingIndex:2] withLogo:@"editors"];
		[self addSourceNamed:@"Authors" linkedTo:@"Authors" atIndex:[indexPath indexPathByAddingIndex:3] withLogo:@"authors"];
		
		NSIndexPath* indexPath2 = nil;
		indexPath2 = [NSIndexPath indexPathWithIndex:1];
		zListsIndexPath = indexPath2;
		
		[self addSourceNamed:@"LISTS" linkedTo:nil atIndex:indexPath2 withLogo:nil];
		
		zBuildingOutlineView = NO;
		zBuilt = YES;
		[zTreeController setSelectionIndexPath:[indexPath indexPathByAddingIndex:0]];
	}
}

- (void)setContents:(NSArray*)newContents
{
	if (contents != newContents)
	{
		contents = [[NSMutableArray alloc] initWithArray:newContents];
	}
}

- (NSMutableArray *)contents
{
	return contents;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
	return (![[item representedObject] isGroup]);
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{	
	if ([[tableColumn identifier] isEqualToString:COLUMNID_NAME])
	{
		// we are displaying the single and only column
		if ([cell isKindOfClass:[ZTSourceItemView class]])
		{
			// set the cell's image
			[(ZTSourceItemView*)cell setImage:[[item representedObject] nodeIcon]];
		}
	}
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	NSCell* returnCell = [tableColumn dataCell];
	if ([[tableColumn identifier] isEqualToString:COLUMNID_NAME])
	{
		returnCell = [tableColumn dataCell];
		/*ZTSourceItemView* node = item;
		 if ([node nodeIcon] == nil && [[node nodeTitle] length] == 0)
		 returnCell = separatorCell;*/
	}
	return returnCell;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return NO;
}

-(BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
	ZTSourceNode* node = [item representedObject];
	return ([node nodeIcon] == nil);
}

#pragma mark -


- (void)removeContentView
{
	NSArray *subViews = [zContentView subviews];
	if ([subViews count] > 0)
	{
		[[subViews objectAtIndex:0] removeFromSuperview];
	}
	[zContentView displayIfNeeded];
}

- (void)changeContentView: (ZTSourceNode *)selectedNode withView:(NSView *)myView
{
	if (selectedNode) 
	{
		
		NSRect contentRect = [zContentView bounds];
		[myView setFrame:contentRect];
			
		[zContentView addSubview:myView positioned:NSWindowAbove relativeTo: nil];
		[myView setNeedsDisplay:YES];
		[zContentView setNeedsDisplay: YES];
		
	}
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	if (zBuildingOutlineView) return;
	
	NSArray *selection = [zTreeController selectedObjects];
	if ([selection count] == 1)
	{
		//TODO: Not clean
		ZTSourceNode *node = [selection objectAtIndex:0];
		if ([node nodeTitle] == @"Volumes") {
			if (!zVolumesView) {
				[NSBundle loadNibNamed:node.nibName owner:self];
			}
			[self changeContentView:node withView:zVolumesView];
			if (zSeriesView && [zSeriesView superview]) [zSeriesView removeFromSuperview];
			if (zEditorsView && [zEditorsView superview]) [zEditorsView removeFromSuperview];
			if (zAuthorsView && [zAuthorsView superview]) [zAuthorsView removeFromSuperview];
		}
		else if ([node nodeTitle] == @"Series") {
			if (!zSeriesView) {
				[NSBundle loadNibNamed:node.nibName owner:self];
			}
			[self changeContentView:node withView:zSeriesView];
			if (zVolumesView && [zVolumesView superview]) [zVolumesView removeFromSuperview];
			if (zEditorsView && [zEditorsView superview]) [zEditorsView removeFromSuperview];
			if (zAuthorsView && [zAuthorsView superview]) [zAuthorsView removeFromSuperview];
		}
		else if ([node nodeTitle] == @"Editors") {
			if (!zEditorsView) {
				[NSBundle loadNibNamed:node.nibName owner:self];
			}
			[self changeContentView:node withView:zEditorsView];
			if (zVolumesView && [zVolumesView superview]) [zVolumesView removeFromSuperview];
			if (zSeriesView && [zSeriesView superview]) [zSeriesView removeFromSuperview];
			if (zAuthorsView && [zAuthorsView superview]) [zAuthorsView removeFromSuperview];
		}
		else if ([node nodeTitle] == @"Authors") {
			if (!zAuthorsView) {
				[NSBundle loadNibNamed:node.nibName owner:self];
			}
			[self changeContentView:node withView:zAuthorsView];
			if (zVolumesView && [zVolumesView superview]) [zVolumesView removeFromSuperview];
			if (zSeriesView && [zSeriesView superview]) [zSeriesView removeFromSuperview];
			if (zEditorsView && [zEditorsView superview]) [zEditorsView removeFromSuperview];
		}
	}
	else {
		[self removeContentView];
	}
	
}

@end