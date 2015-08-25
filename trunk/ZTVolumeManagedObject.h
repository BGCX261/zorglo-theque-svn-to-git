//
//  ZTVolumeManagedObject.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 1/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZTSerieManagedObject;
@class ZTAuthorManagedObject;

@interface ZTVolumeManagedObject : NSManagedObject {
	NSImage	*cover;
}

@property (nonatomic, copy) NSNumber * number;
@property (nonatomic, copy) NSString * title;
@property (nonatomic) ZTSerieManagedObject * serie;
@property (nonatomic, readonly) NSString* displayTitle;
@property (nonatomic, copy) NSSet* drawing;
@property (nonatomic, copy) NSString * coverFileName;
@property (nonatomic, readonly) NSImage* cover;
@property (nonatomic, copy) NSNumber * love;
@property (nonatomic, copy) NSNumber * hate;
@property (nonatomic, copy) NSNumber * dedicaced;
@property (nonatomic, copy) NSNumber * eo;
@property (nonatomic, copy) NSNumber * signature;



- (NSString*) displayTitle;
+ (NSURL*) coverStorage;

+ (NSURL*) copyFileAsCover: (NSString *) fileURL;

@end

// coalesce these into one @interface ZTVolumeManagedObject (CoreDataGeneratedAccessors) section
@interface ZTVolumeManagedObject (CoreDataGeneratedAccessors)
- (void)addDrawingObject:(ZTAuthorManagedObject *)value;
- (void)removeDrawingObject:(ZTAuthorManagedObject *)value;
- (void)addDrawing:(NSSet *)value;
- (void)removeDrawing:(NSSet *)value;

@end
