/*
 * ZTNamedManagedObject.m
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

#import "ZTNamedManagedObject.h"
#import "ZTVolumeManagedObject.h"

// coalesce these into one @interface ZTSerieManagedObject (CoreDataGeneratedPrimitiveAccessors) section
@interface ZTNamedManagedObject (CoreDataGeneratedPrimitiveAccessors)

- (NSString *)primitiveName;
- (void)setPrimitiveName:(NSString *)value;
- (void)notifyVolumesThatWeWillChange;
- (void)notifyVolumesThatWeDidChange;

@end


@implementation ZTNamedManagedObject

@dynamic volumes;
@dynamic name;

- (id) initWithObject:(ZTNamedManagedObject *)serie insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
	if ((self = [super initWithEntity:[serie entity] insertIntoManagedObjectContext:context])) {
		self.name = serie.name;
	}
	
	return self;
	
}

- (BOOL) isVirgin
{
	// Will be needed when series have more information than just a name
	return YES;
}

- (NSUInteger) nbAlbums {
	if (self.volumes) {
		return [self.volumes count];
	}
	return 0;
}

- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey:@"name"];
	[self notifyVolumesThatWeWillChange];
    [self setPrimitiveName:value];
	[self notifyVolumesThatWeDidChange];
    [self didChangeValueForKey:@"name"];
}

- (void)notifyVolumesThatWeWillChange
{
	ZTVolumeManagedObject *aVolume;
	NSSet *allVolumes = self.volumes;
	for (aVolume in allVolumes) {
		[aVolume willChangeValueForKey:[self myKey]];
	}
}


- (void)notifyVolumesThatWeDidChange
{
	ZTVolumeManagedObject *aVolume;
	NSSet *allVolumes = self.volumes;
	for (aVolume in allVolumes) {
		[aVolume didChangeValueForKey:[self myKey]];
	}
	
}

- (NSString *) myKey
{
	return @"Unknown";
}

@end
