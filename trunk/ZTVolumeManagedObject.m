//
//  ZTVolumeManagedObject.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 1/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZorgloThe_que_AppDelegate.h"
#import "ZTVolumeManagedObject.h"
#import "ZTSerieManagedObject.h"

#define k_DefaultCover "no_cover.png"

@interface ZTVolumeManagedObject (Private)

- (NSImage*) getImageFromURL: (NSURL *) url;
- (NSURL*) defaultCoverPath;
- (NSImage*) getDefaultCover;
- (NSImage*) getAssignedCover;
- (BOOL)validateConsistency:(NSError **)error;
- (NSError *)errorFromOriginalError:(NSError *)originalError error:(NSError *)secondError;

@end

@implementation ZTVolumeManagedObject

@dynamic number;
@dynamic title;
@dynamic serie;
@dynamic drawing;
@dynamic coverFileName;
@dynamic love;
@dynamic hate;
@dynamic dedicaced;
@dynamic eo;
@dynamic signature;

+ (NSSet*) keyPathsForValuesAffectingDisplayTitle {
	return [NSSet setWithObjects:@"number", @"title", @"serie.name", nil];
}

- (NSString*) displayTitle
{
	NSString *ret;
	ret = [[NSString alloc] initWithFormat:@"%@ #%@ - %@", self.serie.name, self.number, self.title];
	
	return ret;
}

- (NSImage*) cover
{
	if (cover != nil) return cover;
	if (self.coverFileName) return [self getAssignedCover];
	else return [self getDefaultCover];
}

- (NSImage*) getImageFromURL: (NSURL *) url
{
	if (url) {
		return [[NSImage alloc] initWithContentsOfURL:url];
	}
	return nil;
}

+ (NSURL *) coverStorage
{
	NSURL *coverURL = [((ZorgloThe_que_AppDelegate *)[NSApp delegate]).storageURL URLByAppendingPathComponent:@"covers"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	if ( ![fileManager fileExistsAtPath:[coverURL path] isDirectory:&isDirectory] ) {		
		NSError *error;
		if (![fileManager createDirectoryAtPath:[coverURL path]
					withIntermediateDirectories:NO 
									 attributes:nil
										  error:&error]) {
			NSAssert(NO, ([NSString stringWithFormat:@"Failed to create Cover directory %@ : %@", coverURL,error]));
			NSLog(@"Error creating cover directory at %@ : %@",coverURL,error);
			return nil;
		}
	}
	return coverURL;
}

- (NSURL*) defaultCoverURL
{
	return [[NSBundle mainBundle] URLForResource:@"no-cover.png" withExtension:@"png"];
}

- (NSURL *) fullCoverURL
{
	if (self.coverFileName) {
		NSURL *coverURL = [ZTVolumeManagedObject	coverStorage];
		if (!coverURL) return nil;
		
		return [coverURL URLByAppendingPathComponent:self.coverFileName];
	}
	else {
		return nil;
	}

}

- (NSImage*) getDefaultCover
{
	return [self getImageFromURL: [self defaultCoverURL]];
}

- (NSImage*) getAssignedCover
{
	return [self getImageFromURL: [self fullCoverURL]];
}

+ (NSURL*) copyFileAsCover: (NSString *) filePath
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSURL *src = [NSURL fileURLWithPath:filePath];
	NSURL *dst = [ZTVolumeManagedObject coverStorage];
	NSString *fileName = [filePath lastPathComponent];
	
	BOOL cont = YES;
	NSUInteger n=0;
	while (cont && n < 50) {
		NSError *error = nil;
		NSString *fileName2 = [NSString stringWithFormat:@"%i-%@", n, fileName];
		NSURL *dst2 = [dst URLByAppendingPathComponent:fileName2];
		if ([fileManager copyItemAtURL:src toURL:dst2 error:&error]) {
			return dst2;
		}
		else {
			if ( [[error domain] isEqualToString:NSPOSIXErrorDomain] ) {
				switch ([error code]) {
					case 17:
						cont=YES;
						break;
					default:
						cont=NO;
						break;
				}
			}
		}
		n++;
	}
	return nil;
}

#pragma mark Validation

- (BOOL)validateForInsert:(NSError **)error
{
	if ([super validateForInsert:error]) {
		return [self validateConsistency:error];
	}
    return NO;
}

- (BOOL)validateForUpdate:(NSError **)error
{
    if ([super validateForUpdate:error]) {
		return [self validateConsistency:error];
	}
    return NO;
}

- (NSError *)errorFromOriginalError:(NSError *)originalError error:(NSError *)secondError
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSMutableArray *errors = [NSMutableArray arrayWithObject:secondError];
	
    if ([originalError code] == NSValidationMultipleErrorsError) {
		
        [userInfo addEntriesFromDictionary:[originalError userInfo]];
        [errors addObjectsFromArray:[userInfo objectForKey:NSDetailedErrorsKey]];
    }
    else {
        [errors addObject:originalError];
    }
	
    [userInfo setObject:errors forKey:NSDetailedErrorsKey];
	
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:NSValidationMultipleErrorsError
                           userInfo:userInfo];
}

- (BOOL)validateConsistency:(NSError **)error
{
	NSLog(@"%@", self.love);
	if ([self.love boolValue] && [self.hate boolValue]) {
		if (error != NULL) {
			NSString *appreciationErrorString = @"Appreciation is either love or hate, not both";
			
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
			[userInfo setObject:appreciationErrorString forKey:NSLocalizedFailureReasonErrorKey];
			[userInfo setObject:self forKey:NSValidationObjectErrorKey];
			
			NSError *appreciationError = [NSError errorWithDomain:@"ZTVolumeErrorDomain"
														   code:NSManagedObjectValidationError
													   userInfo:userInfo];
			
			// if there was no previous error, return the new error
			if (*error == nil) {
				*error = appreciationError;
			}
			// if there was a previous error, combine it with the existing one
			else {
				*error = [self errorFromOriginalError:*error error:appreciationError];
			}
		}
		return NO;
	}
	return YES;
}

@end
