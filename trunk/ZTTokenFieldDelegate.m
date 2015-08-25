/*
 * ZTTokenFieldDelegate.m
 * ZorgloThèque
 * 
 * Created by Benjamin Dehalu on 22/03/10.
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

#import "ZTTokenFieldDelegate.h"
#import "ZTAuthorManagedObject.h"
#import "ZorgloThe_que_AppDelegate.h"
#import "ZTCreateHandler.h"
#import "ZTTokenField.h"

@interface ZTTokenFieldDelegate (Private)
- (BOOL) getManagedObjectContext;
- (ZTAuthorManagedObject *) createObjectFor: (NSString *) aFullName forEntity: (NSString *) entityName;
- (ZTAuthorManagedObject *) createObjectWithName: (NSString *) aName;
- (NSArray *) findCloseMatchesTo: (NSString *) aName;
- (void) displayNotificationForCreation: (ZTAuthorManagedObject *) author closeTo: (NSArray *) closeMatches forEntity: (NSString *) entityName;
@end

@implementation ZTTokenFieldDelegate

- (id) init
{
	if (self = [super init]) {
		zManagedObjectContext = [[NSApp delegate] managedObjectContext];
	}
	return self;
}

- (ZTAuthorManagedObject *) createObjectWithName: (NSString *) aName
{
	ZTAuthorManagedObject *newAuthor = [NSEntityDescription insertNewObjectForEntityForName:@"Author" 
																   inManagedObjectContext:zManagedObjectContext];
	NSArray *parts = [aName componentsSeparatedByString:@" "];
	if ([parts count] == 1) {
		newAuthor.nickName = [parts objectAtIndex:0];
	}
	else if ([parts count] == 2) {
		newAuthor.firstName = [parts objectAtIndex:0];
		newAuthor.lastName = [parts objectAtIndex:1];
	}
	else {
		NSUInteger particule = [parts indexOfObjectPassingTest:^ (id obj, NSUInteger idx, BOOL *stop) {
			if ([obj caseInsensitiveCompare:@"de"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"du"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"des"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"von"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"of"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"van"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"da"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"del"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"dal"] == NSOrderedSame ||
				[obj caseInsensitiveCompare:@"della"] == NSOrderedSame) {
				*stop = YES;
				return YES;
			}
			return NO;
			
		}];
		if (particule < [parts count] - 1) {
			NSRange firstRange, lastRange;
			firstRange.location = 0;
			firstRange.length = particule;
			lastRange.location = particule;
			lastRange.length = [parts count] - particule;
			newAuthor.firstName = [[parts subarrayWithRange:firstRange] 
								   componentsJoinedByString:@" "];
			newAuthor.lastName = [[parts subarrayWithRange:lastRange] 
								   componentsJoinedByString:@" "];
		}
		else {
			NSRange lastRange;
			newAuthor.firstName = [parts objectAtIndex: 0];
			lastRange.location = 1;
			lastRange.length = [parts count] - 1;
			newAuthor.lastName = [[parts subarrayWithRange:lastRange] 
								  componentsJoinedByString:@" "];
		}
	}
	
	return newAuthor;
}

- (NSArray *) findCloseMatchesTo: (NSString *) aName
{
	NSArray *results;
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Author" 
														 inManagedObjectContext:zManagedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	//Could be improved with blocks, but that would remove the possibility to use SQLite store
	//TODO: Add XML store option in preferences and use block in that case
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", aName];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES]; //TODO: Use sortName
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error;
	results = nil;
	results = [zManagedObjectContext executeFetchRequest:request error:&error];
	return results;
}

- (void) displayNotificationForCreation: (ZTAuthorManagedObject *) author closeTo: (NSArray *) closeMatches forEntity: (NSString *) entityName
{
	ZTCreateHandler * createHandler = [[ZTCreateHandler alloc] initForVolume:[iVolumesController selection]
																   andAuthor: author
																	  forKey: entityName
																   inContext: zManagedObjectContext];
	
	[((ZorgloThe_que_AppDelegate*) [NSApp delegate]).notificationArea showNotificationWithText:[NSString stringWithFormat:@"An author named %@ has been created", author.fullName]
																					cancelText:@"Change" 
																				   confirmText:@"Dismiss"
																				   withHandler: createHandler 
																				withDataSource: closeMatches];
}

- (ZTAuthorManagedObject *) createObjectFor: (NSString *) aFullName forEntity: (NSString *) entityName
{
	NSArray *closeMatches = [self findCloseMatchesTo: aFullName];
	ZTAuthorManagedObject *newAuthor = [self createObjectWithName:aFullName];
	[self displayNotificationForCreation: newAuthor closeTo: closeMatches forEntity: entityName];
	
	return newAuthor;
}

- (NSArray *)tokenField:(NSTokenField *)tokenFieldArg completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
{
	if (!zManagedObjectContext) return nil;
	
	NSArray *results;
	*selectedIndex = -1; // No default selection
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Author" 
														 inManagedObjectContext:zManagedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(displayName CONTAINS[cd] %@)", substring];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error;
	results = nil;
	results = [zManagedObjectContext executeFetchRequest:request error:&error];
	if (results == nil)
	{
		return results;
	}
	else {
		NSMutableArray *stringedResults = [[NSMutableArray alloc] initWithCapacity:[results count]];
		[results enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
			[stringedResults insertObject:((ZTAuthorManagedObject*) obj).displayName 
								  atIndex:idx];
		}];
		return stringedResults;
	}
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString: (NSString *)editingString 
{
	if (!zManagedObjectContext) return nil;
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Author" 
														 inManagedObjectContext:zManagedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *predForTypeOfInput = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", @".*\\(.*\\)$"];
	NSString *theFormat;
	if ([predForTypeOfInput evaluateWithObject:editingString])
		theFormat = @"displayName == %@";
	else 
		theFormat = @"fullName == %@";
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: theFormat, editingString];
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray* results = [zManagedObjectContext executeFetchRequest:request error:&error];
	if (results == nil || [results count] == 0)
	{
		// We did not find an exact match.
		// However, it is frequent to mistype names
		// So we need to provide a list of close matches
		return [self createObjectFor: editingString forEntity: ((ZTTokenField *)tokenField).rEntityName];
	}
	return [results objectAtIndex:0];
}

- (NSString *)tokenField:(NSTokenField *)tokenFieldArg displayStringForRepresentedObject:(id)representedObject
{
	return ((ZTAuthorManagedObject*) representedObject).fullName;
}

@end
