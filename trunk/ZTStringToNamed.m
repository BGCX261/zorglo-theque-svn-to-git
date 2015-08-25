/*
 * ZTStringToNamed.m
 * ZorgloThèque
 * 
 * Created by Benjamin Dehalu on 16/03/10.
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

#import "ZTStringToNamed.h"
#import "ZTNamedManagedObject.h"


@interface ZTStringToNamed(Private)

- (ZTNamedManagedObject *) findObjectWithName: (NSString *) aName;
- (ZTNamedManagedObject *) createObjectWithName: (NSString *) aName;
- (BOOL) getManagedObjectContext;

@end

@implementation ZTStringToNamed

- (id) initWithEntityName: (NSString *)entityName
{
	if (self = [super init]) {
		zEntityName = entityName;
	}
	return self;
}

- (ZTNamedManagedObject *) findObjectWithName: (NSString *) aName
{
	if (![self getManagedObjectContext]) return nil;
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:zEntityName 
														 inManagedObjectContext:zManagedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name == %@", aName];
	[request setPredicate:predicate];
	
	NSError *error;
	NSArray* results = [zManagedObjectContext executeFetchRequest:request error:&error];
	if (results == nil || [results count] == 0)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

- (ZTNamedManagedObject *) createObjectWithName: (NSString *) aName
{
	ZTNamedManagedObject *newSerie = [NSEntityDescription insertNewObjectForEntityForName:zEntityName 
																   inManagedObjectContext:zManagedObjectContext];
	newSerie.name = aName;
	return newSerie;
}

#pragma mark -

- (BOOL) getManagedObjectContext
{
	if (!zManagedObjectContext) 
		zManagedObjectContext = [[NSApp delegate] managedObjectContext];
	return (zManagedObjectContext != nil);
}

- (id) init
{
	if ((self = [super init])) {
		zManagedObjectContext = nil;
		zObject = nil;
	}
	
	return self;
}

#pragma mark -

+ (Class)transformedValueClass
{
	return [ZTNamedManagedObject class];
}

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

- (id)reverseTransformedValue:(id)value
{
	if (zObject.name == value) return zObject;
	
	// We get a NSString, we need to return the appropriate Serie
	ZTNamedManagedObject *result = [self findObjectWithName:value];
	if (result == nil) {
		result = [self createObjectWithName:value];
	}
	
	return result;
}

- (id)transformedValue:(id)value
{
	// We get a Serie, we need to return a string
	ZTNamedManagedObject *ret = value;
	return ret.name;
}

@end
