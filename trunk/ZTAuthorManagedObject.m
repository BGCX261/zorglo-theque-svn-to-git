/*
 * ZTAuthorManagedObject.m
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

#import "ZTAuthorManagedObject.h"

@interface ZTAuthorManagedObject (Private)
	- (NSString *) generateDisplayName;
	- (NSString *) generateFullName;
@end

@implementation ZTAuthorManagedObject

@dynamic firstName;
@dynamic lastName;
@dynamic nickName;
@dynamic displayName;
@dynamic fullName;


- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
	if (self = [super initWithEntity:entity insertIntoManagedObjectContext:context]) {
		[self addObserver:self forKeyPath:@"firstName" options:0 context:nil];
		[self addObserver:self forKeyPath:@"lastName" options:0 context:nil];
		[self addObserver:self forKeyPath:@"nickName" options:0 context:nil];
	}
	return self;
}

#pragma mark KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (keyPath == @"firstName" || keyPath == @"lastName" || keyPath == @"nickName") {
		((ZTAuthorManagedObject *)object).displayName = [self generateDisplayName];
		((ZTAuthorManagedObject *)object).fullName = [self generateFullName];
	}
}

- (NSString *) generateDisplayName
{
	NSString *fullName = @"";
	
	if (self.nickName) {
		fullName = self.nickName;
		if (self.firstName || self.lastName) {
			NSString *tempName = @"";
			if (self.firstName) {
				tempName = self.firstName;
			}
			if (self.lastName) {
				if (self.firstName) {
					tempName = [tempName stringByAppendingString:@" "];
				}
				tempName = [tempName stringByAppendingString:self.lastName];
			}
			fullName = [fullName stringByAppendingFormat:@" (%@)", tempName];
		}
	}
	else {
		//TODO: Refactor this
		fullName = @"";
		if (self.firstName) {
			fullName = self.firstName;
		}
		if (self.lastName) {
			if (self.firstName) {
				fullName = [fullName stringByAppendingString:@" "];
			}
			fullName = [fullName stringByAppendingString:self.lastName];
		}
	}
	return fullName;
}

#pragma mark Accessors

- (NSString *) generateFullName
{
	NSString *fullName = @"<unknown>";
	
	if (self.nickName) {
		fullName = self.nickName;
	}
	else {
		fullName = @"";
		NSString *separator = @"";
		if (self.firstName) {
			fullName = [fullName stringByAppendingString:self.firstName];
			separator = @" ";
		}
		if (self.lastName) {
			fullName = [fullName stringByAppendingFormat:@"%@%@", separator, self.lastName];
		}
	}
	return fullName;
}



@end
