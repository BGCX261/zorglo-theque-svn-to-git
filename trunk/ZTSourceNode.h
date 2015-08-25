//
//  ZTSourceNode.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 10/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZTSourceNode : NSObject {
	NSString		*nodeTitle;
	NSMutableArray	*children;
	BOOL			zIsLeaf;
	NSImage			*zNodeIcon;
	NSString		*zNibName;
}

@property (readwrite, getter=nibName, setter=setNibName, copy) NSString * zNibName;


- (id)initLeaf;

- (void)setNodeTitle:(NSString*)newNodeTitle;
- (NSString*)nodeTitle;

- (void)setChildren:(NSArray*)newChildren;
- (NSMutableArray*)children;

- (void)setLeaf:(BOOL)flag;
- (BOOL)isLeaf;
- (BOOL) isGroup;

- (void)setNodeIcon:(NSImage*)icon;
- (NSImage*)nodeIcon;

- (BOOL)isDraggable;

- (NSComparisonResult)compare:(ZTSourceNode*)aNode;

- (NSArray*)mutableKeys;

- (NSDictionary*)dictionaryRepresentation;
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (id)parentFromArray:(NSArray*)array;
- (void)removeObjectFromChildren:(id)obj;
- (NSArray*)descendants;
- (NSArray*)allChildLeafs;
- (NSArray*)groupChildren;
- (BOOL)isDescendantOfOrOneOfNodes:(NSArray*)nodes;
- (BOOL)isDescendantOfNodes:(NSArray*)nodes;
- (NSIndexPath*)indexPathInArray:(NSArray*)array;

@end
