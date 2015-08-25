/*
 * ZTAutoCompleteWatcher.m
 * ZorgloThèque
 * 
 * Created by Benjamin Dehalu on 15/03/10.
 * 
 * Copyright (c) 2010 Zorglo Software
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "ZTAutoCompleteDelegate.h"
#import "ZTVolumeManagedObject.h"
#import "ZorgloThe_que_AppDelegate.h"
#import "ZTDeleteHandler.h"
#import "ZTRenameHandler.h"
#import "ZTNamedManagedObject.h"
#import "ZTAutoCompleteTextField.h"

@interface ZTAutoCompleteDelegate (Private)

- (NSManagedObjectContext *) getTempContextFrom:(NSManagedObjectContext *) moc;
- (void) shouldDelete: (ZTNamedManagedObject *)oldValue inFavourOf: (ZTNamedManagedObject *)matchValue;
- (void) shouldRename: (ZTNamedManagedObject *)oldValue into: (NSString *) newValue;

@end


@implementation ZTAutoCompleteDelegate

@synthesize zTextField;
@synthesize zFormatStringForDelete;
@synthesize zFormatStringForRename;

- (id) initForEntityName: (NSString *) entityName options: (ZTAutoNotificationOptions)options
{
	self = [super init];
	if (self) {
		zOptions = options;
		zEntityName = entityName;
	}
	return self;
}


#pragma mark Delegates

- (void) startSearch:(NSString *)aString 
{
	if ([aString length]) {
		[zTextField.dataSource doSearch: aString];
		[zTextField.tableView noteNumberOfRowsChanged];
		if ([zTextField visibleRows] > 0) {
			[zTextField openPopup];
		}
		else {
			[zTextField closePopup];
		}
	}
	else {
		[zTextField closePopup];
	}
}

- (void)controlTextDidChange:(NSNotification *)aNote
{
	NSTextView *fieldEditor = [[aNote userInfo] objectForKey:@"NSFieldEditor"];
	NSString* currentText = [fieldEditor string];
	[self startSearch: currentText];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNote
{
	[zTextField closePopup];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{	
	if (command == @selector(insertNewline:)) {
		[zTextField enterResult:[zTextField.tableView selectedRow]];
		[zTextField.tableView deselectAll:self];
	}
	else if (command == @selector(moveUp:)) {
		if ([zTextField isOpen]) {
			[zTextField selectRowBy:-1];
			return YES;
		}
	}
	else if (command == @selector(moveDown:)) {
		if ([zTextField isOpen]) {
			[zTextField selectRowBy:1];
			return YES;
		}
		else if ([[[textView selectedRanges] objectAtIndex:0] rangeValue].location == [[[zTextField fieldEditor] string] length]) {
			[self startSearch:[[zTextField fieldEditor] string]];
			return YES;
		}
	}
	else if (command == @selector(scrollPageUp:)) {
		[zTextField selectRowBy:-z_MaxRows];
	}
	else if (command == @selector(scrollPageDown:)) {
		[zTextField selectRowBy:z_MaxRows];
	}
	else if (command == @selector(moveToBeginningOfDocument:)) {
		[zTextField selectRowAt:0];
	}
	else if (command == @selector(moveToEndOfDocument:)) {
		[zTextField selectRowAt:[zTextField.tableView numberOfRows]-1];
	}
	else if (command == @selector(complete:)) {
		[zTextField selectRowBy:1];
		[zTextField enterResult:[zTextField.tableView selectedRow]];
		[[zTextField tableView] deselectAll:self];
		return YES;
	}
	else if (command == @selector(insertTab:)) {
		
		if ([zTextField nextKeyView])
			[[zTextField window] selectKeyViewFollowingView:zTextField];
		else {
			NSWindow* wind = [zTextField window];
			[wind makeFirstResponder:wind];
		}
	}
	
	return NO;
}

#pragma mark Notifications


- (ZTNamedManagedObject *) findInStore: (NSString *) aName 
						 forEntityName: (NSString *) entity 
						 withPredicate: (NSPredicate *)predicate
{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	if (!moc) return nil;
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity
														 inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray* results = [moc executeFetchRequest:request error:&error];
	if (results == nil || [results count] == 0)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

- (ZTNamedManagedObject *) findInStore: (NSString *) aName
{
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
	
	if (!moc) return nil;
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:zEntityName 
														 inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@", aName];
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray* results = [moc executeFetchRequest:request error:&error];
	if (results == nil || [results count] == 0)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

- (ZTNamedManagedObject *) namedObjectLinkedTo: (ZTVolumeManagedObject *)volume
{
	return [volume valueForKey:zEntityName];
}

- (NSString *) textForDeletionOf: (NSString *) name {
	return @"";
}

- (NSString *) textForRenameOf: (NSString *) oldName into: (NSString *) newName {
	return @"";
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSArray *selection = [[(ZTAutoCompleteTextField *) control volumesController] selectedObjects];
	
	if ([selection count] == 0) {
		return YES;
	}
	else if ([selection count] > 1) {
		//TODO: Multiple selection
		return YES;
	}
	else {
		ZTVolumeManagedObject *oldValueVolume = [selection objectAtIndex:0];
		ZTNamedManagedObject *oldValue = [self namedObjectLinkedTo:oldValueVolume];
		NSString *newValue = [fieldEditor string];
		
		if (oldValue == nil) {
			// The transformer will either select the serie with name newValue
			// or create a new serie with name newValue
			return YES;
		}
		
		
		// Does newValue exist?
		ZTNamedManagedObject *matchValue = [self findInStore:newValue];
		
		if (matchValue) {
			NSInteger numberOfAlbums = [oldValue.volumes count];
			if (numberOfAlbums > 1) { // The volume has not been removed yet
				return YES;
			}
			
			if ([oldValue isVirgin]) {
				// Delete
				[self shouldDelete:oldValue inFavourOf:matchValue];
			}
		}
		else {
			// Rename
			[self shouldRename:oldValue into:newValue];
		}
	}
	return YES;
}

- (void) shouldRename: (ZTNamedManagedObject *) oldValue into: (NSString *) newValue
{
	if (zOptions & ZTAllowUndoOnRename) {
		NSString *notificationText = [[NSString alloc] initWithFormat:self.renameFormat, oldValue.name, newValue];
		NSString *oldName = oldValue.name;
		
		oldValue.name = [[NSString alloc] initWithString: newValue];
		[[oldValue managedObjectContext] refreshObject:oldValue mergeChanges:YES];
		[((ZorgloThe_que_AppDelegate*) [NSApp delegate]).notificationArea showNotificationWithText:notificationText 
																						cancelText:@"Undo" 
																					   confirmText:@"Dismiss"
																					   withHandler:[[ZTRenameHandler alloc] initWithSerie:oldValue 
																															   andOldName:oldName] 
																					withDataSource: nil];
	}
}

- (NSManagedObjectContext *) getTempContextFrom:(NSManagedObjectContext *) moc
{
	
	
	NSManagedObjectContext *tempMoc = [[NSManagedObjectContext alloc] init];
	NSPersistentStoreCoordinator *myCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[moc persistentStoreCoordinator] managedObjectModel]];
	
	NSError *error = [[NSError alloc] init];
	if ([myCoordinator addPersistentStoreWithType:NSInMemoryStoreType 
									configuration:nil 
											  URL:nil 
										  options:nil 
											error:&error]){
		[tempMoc setPersistentStoreCoordinator:myCoordinator];
		return tempMoc;
	}
	return nil;
}

- (void) shouldDelete: (ZTNamedManagedObject *)oldValue inFavourOf: (ZTNamedManagedObject *)matchValue
{
	ZTNamedManagedObject *keepValue;
	
	
	if (zOptions & ZTAllowDelete) {
		NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
		NSManagedObjectContext *tempMoc = nil;
		if (zOptions & ZTAllowUndoOnDelete) {
			// If we do not change manually the relationship,
			// the textField will not be updated, though the relationship itself would have been
			NSSet *currentVolumes = matchValue.volumes;
			matchValue.volumes = [currentVolumes setByAddingObjectsFromSet:oldValue.volumes];
			oldValue.volumes = [[NSSet alloc] init];
			
			tempMoc = [self getTempContextFrom: moc];
			if (tempMoc) {
				keepValue = [[ZTNamedManagedObject alloc] initWithObject:oldValue 
										  insertIntoManagedObjectContext:tempMoc];
			}
		}
		NSString *oldName = oldValue.name; NSString *newName = matchValue.name;
		[moc deleteObject:oldValue];
		
		if (zOptions & ZTDisplayNotificationOnDelete) {
			NSString *notificationText = [[NSString alloc] initWithFormat:self.deleteFormat, oldName, newName];
			[((ZorgloThe_que_AppDelegate*) [NSApp delegate]).notificationArea showNotificationWithText:notificationText 
																							cancelText:@"Undo" 
																						   confirmText:@"Dismiss" 
																						   withHandler:[[ZTDeleteHandler alloc] initWithSerie: keepValue 
																																	inContext: tempMoc] 
																						withDataSource: nil];
		}
	}
}

@end
