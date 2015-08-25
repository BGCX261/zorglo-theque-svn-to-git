/*
 * ZTEditorManagedObject.m
 * ZorgloThèque
 * 
 * Created by Benjamin Dehalu on 20/03/10.
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

#import "ZTEditorManagedObject.h"

#define k_EditorsImgDir "EditorsLogos"

@interface ZTEditorManagedObject (Private)

- (NSImage*) formatLogo: (NSImage *) sourceImage;

@end

@implementation ZTEditorManagedObject

@dynamic logoFileName;

- (NSString *) myKey
{
	return @"editor";
}

- (NSString *) logoPath
{
	// Filename
	NSString *logoFN = [self valueForKey:@"logoFileName"];
	
	// Path
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		BOOL isDir;
		
		NSString *storeLogoPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"EditorsLogos"];
		NSString *returnPath = [storeLogoPath stringByAppendingPathComponent: logoFN];
		
		if (![fileManager fileExistsAtPath:storeLogoPath])
		{
			NSError *error;
			if ([fileManager createDirectoryAtPath:storeLogoPath withIntermediateDirectories: YES attributes:nil error: &error]) {
				return returnPath;
			}
			return nil;
		}
		else if ([fileManager fileExistsAtPath:storeLogoPath isDirectory: &isDir] && !isDir) {
			//TODO: Handle this error properly
			return nil;
		}
		else {
			return returnPath;
		}
	}
	return nil;
}

- (NSImage *) logo
{
	if (!zLogo)
	{
		NSString *myLogoPath = [self logoPath];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (myLogoPath && [fileManager fileExistsAtPath:myLogoPath])
			zLogo = [[NSImage alloc] initWithContentsOfFile:myLogoPath];
	}
	return zLogo;
}

- (void) setLogo: (NSImage *) data
{
	if (data) {
		NSImage *img = [self formatLogo: data];
		
		NSBitmapImageRep *bits = [[img representations] objectAtIndex:0];
		NSData *data;
		data = [bits representationUsingType:NSPNGFileType properties:nil];
		self.logoFileName = [NSString stringWithFormat:@"%@.png", self.name];
		NSLog(@"%@", self.logoPath);
		[data writeToFile:self.logoPath atomically:NO];
	}
}

- (NSImage*) formatLogo: (NSImage *) sourceImage
{
	return sourceImage;
}

@end
