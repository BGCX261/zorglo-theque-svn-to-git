//
//  ZTNotificationOwner.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 7/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTNotificationOwner.h"

@interface ZTNotificationOwner (Private)

- (BOOL) loadNotificationNibFile;
- (void) displayBar;
- (void) resizeMainView;
- (void) drawBar;
- (void) setChoicesDataSource: (NSArray *) content;

@end


@implementation ZTNotificationOwner

@synthesize zNotificationView;


- (IBAction) cancelAction: (id) anObject
{
	if ([zAdditionalChoices isHidden]) {
		[zHandler cancelAction:anObject owner:self forSelection:nil];
	}
	else {
		[zHandler cancelAction:anObject owner:self forSelection:[[zAdditionalChoices selectedItem] representedObject]];
	}

}

- (IBAction) confirmAction: (id) anObject
{
	[zHandler confirmAction:anObject owner:self forSelection:nil];
}

- (void) showNotificationWithText: (NSString *) title 
					   cancelText: (NSString *) cancel 
					  confirmText: (NSString *) confirm
					  withHandler: (ZTAbstractNotificationHandler *) handler 
				   withDataSource: (id) dataSource
{
	if ([self loadNotificationNibFile]) {
		[zNotificationText setStringValue:title];
		[zCancelAction setTitle:cancel];
		[zConfirmAction setTitle:confirm];
		zHandler = handler;
		
		if (dataSource == nil) {
			[zAdditionalChoices setHidden:YES];
		}
		else {
			[self setChoicesDataSource:dataSource];
		}

		
		[self displayBar];
	}
	
}

- (void) setChoicesDataSource: (NSArray *) content
{
	NSArrayController *controller = [[NSArrayController alloc] initWithContent:content];
	NSMutableDictionary *bindingOptions = [NSMutableDictionary dictionary];
	[bindingOptions setObject:[NSNumber numberWithInt:1]
					   forKey:@"NSContinuouslyUpdatesValueBindingOption"];
	[zAdditionalChoices bind:@"content" toObject:controller withKeyPath:@"arrangedObjects" options:bindingOptions];
	[zAdditionalChoices bind:@"contentValues" toObject:controller withKeyPath:@"arrangedObjects.fullName" options:bindingOptions];
}

- (BOOL) loadNotificationNibFile
{
	if (![NSBundle loadNibNamed:@"NotificationArea" owner:self])
	{
		NSLog(@"Warning! Could not load NotificationArea file.\n");
		return NO;
	}
	return YES;
}

- (void) displayBar
{
	[self drawBar];
	[self resizeMainView];
}

- (void) restoreMainView
{
	NSRect mainFrame = [zMainView frame];
	NSRect actualTopBarFrame = [zNotificationView frame];
	mainFrame.size.height += actualTopBarFrame.size.height;
	//[zNotificationView removeFromSuperview];
	[zNotificationView performSelector:@selector(removeFromSuperview) withObject: nil afterDelay:2.0];
	[[zMainView animator] setFrame: mainFrame];
	[zMainView setNeedsDisplay:YES];
}

- (void) resizeMainView
{
	NSRect mainFrame = [zMainView frame];
	
	NSRect actualTopBarFrame = [zNotificationView frame];
	//mainFrame.origin.y = actualTopBarFrame.size.height;
	mainFrame.size.height -= actualTopBarFrame.size.height;
	[[zMainView animator] setFrame: mainFrame];
	[zMainView setNeedsDisplay:YES];
}

- (void) drawBar
{
	NSRect currentFrame = [zNotificationView frame];
	currentFrame.origin.y = [zMainView frame].size.height - currentFrame.size.height;
	currentFrame.origin.x = 0.0;
	currentFrame.size.width = [zMainView frame].size.width;
	[zNotificationView setFrame: currentFrame];
	
	[[zMainView superview] addSubview:zNotificationView positioned:NSWindowBelow relativeTo: zMainView];
	[zMainView display];
	[zNotificationView setNeedsDisplay:YES];
}

@end
