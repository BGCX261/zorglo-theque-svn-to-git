//
//  ZTSourceNode.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 10/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTSourceNode.h"
#import "NSArray_Extensions.h"

@implementation ZTSourceNode

@synthesize zNibName;

- (id)init
{
	if (self = [super init])
	{
		[self setNodeTitle:@"SourceNode Untitled"];
		[self setChildren:[NSArray array]];
		[self setLeaf:NO];			// container by default
	}
	return self;
}


- (id)initLeaf
{
	if (self = [self init])
	{
		[self setLeaf:YES];
	}
	return self;
}

- (void)setNodeTitle:(NSString*)newNodeTitle
{
	nodeTitle = newNodeTitle;
}

- (NSString*)nodeTitle
{
	return nodeTitle;
}

- (void)setNodeIcon:(NSImage*)icon
{
    if (!zNodeIcon || ![zNodeIcon isEqual:icon])
	{
		zNodeIcon = icon;
    }
}

- (NSImage*)nodeIcon
{
    return zNodeIcon;
}

- (void)setChildren:(NSArray*)newChildren
{
	if (children != newChildren)
    {
        children = [[NSMutableArray alloc] initWithArray:newChildren];
    }
}

- (NSMutableArray*)children
{
	return children;
}

- (void)setLeaf:(BOOL)flag
{
	zIsLeaf = flag;
	if (zIsLeaf)
		[self setChildren:[NSArray arrayWithObject:self]];
	else
		[self setChildren:[NSArray array]];
}

- (BOOL)isLeaf
{
	return zIsLeaf;
}

- (BOOL) isGroup
{
	return (!(zIsLeaf) && zNodeIcon == nil);
}

- (NSComparisonResult)compare:(ZTSourceNode*)aNode
{
	return [[[self nodeTitle] lowercaseString] compare:[[aNode nodeTitle] lowercaseString]];
}


#pragma mark - Drag and Drop

- (BOOL)isDraggable
{
	BOOL result = YES;
	if ([self nodeIcon] == nil)
		result = NO;	// don't allow groups to be dragged
	return result;
}

- (id)parentFromArray:(NSArray*)array
{
	id result = nil;
	
	for (id node in array)
	{
		if (node == self)	// If we are in the root array, return nil
			break;
		
		if ([[node children] containsObjectIdenticalTo:self])
		{
			result = node;
			break;
		}
		
		if (![node isLeaf])
		{
			id innerNode = [self parentFromArray:[node children]];
			if (innerNode)
			{
				result = innerNode;
				break;
			}
		}
	}
	
	return result;
}

- (void)removeObjectFromChildren:(id)obj
{
	// Remove object from children or the children of any sub-nodes
	NSEnumerator *enumerator = [children objectEnumerator];
	id node = nil;
	
	while (node = [enumerator nextObject])
	{
		if (node == obj)
		{
			[children removeObjectIdenticalTo:obj];
			return;
		}
		
		if (![node isLeaf])
			[node removeObjectFromChildren:obj];
	}
}

- (NSArray*)descendants
{
	NSMutableArray	*descendants = [NSMutableArray array];
	NSEnumerator	*enumerator = [children objectEnumerator];
	id				node = nil;
	
	while (node = [enumerator nextObject])
	{
		[descendants addObject:node];
		
		if (![node isLeaf])
			[descendants addObjectsFromArray:[node descendants]];	// Recursive - will go down the chain to get all
	}
	return descendants;
}

- (NSArray*)allChildLeafs
{
	NSMutableArray	*childLeafs = [NSMutableArray array];
	NSEnumerator	*enumerator = [children objectEnumerator];
	id				node = nil;
	
	while (node = [enumerator nextObject])
	{
		if ([node isLeaf])
			[childLeafs addObject:node];
		else
			[childLeafs addObjectsFromArray:[node allChildLeafs]];	// Recursive - will go down the chain to get all
	}
	return childLeafs;
}

- (NSArray*)groupChildren
{
	NSMutableArray	*groupChildren = [NSMutableArray array];
	NSEnumerator	*childEnumerator = [children objectEnumerator];
	ZTSourceNode	*child;
	
	while (child = [childEnumerator nextObject])
	{
		if (![child isLeaf])
			[groupChildren addObject:child];
	}
	return groupChildren;
}

- (BOOL)isDescendantOfOrOneOfNodes:(NSArray*)nodes
{
    // returns YES if we are contained anywhere inside the array passed in, including inside sub-nodes
    NSEnumerator *enumerator = [nodes objectEnumerator];
	id node = nil;
	
    while (node = [enumerator nextObject])
	{
		if (node == self)
			return YES;		// we found ourselv
		
		// check all the sub-nodes
		if (![node isLeaf])
		{
			if ([self isDescendantOfOrOneOfNodes:[node children]])
				return YES;
		}
    }
	
    return NO;
}

- (BOOL)isDescendantOfNodes:(NSArray*)nodes
{
    NSEnumerator *enumerator = [nodes objectEnumerator];
	id node = nil;
	
    while (node = [enumerator nextObject])
	{
		// check all the sub-nodes
		if (![node isLeaf])
		{
			if ([self isDescendantOfOrOneOfNodes:[node children]])
				return YES;
		}
    }
	
	return NO;
}

// -------------------------------------------------------------------------------
//	indexPathInArray:array
//
//	Returns the index path of within the given array,
//	useful for drag and drop.
// -------------------------------------------------------------------------------
- (NSIndexPath*)indexPathInArray:(NSArray*)array
{
	NSIndexPath		*indexPath = nil;
	NSMutableArray	*reverseIndexes = [NSMutableArray array];
	id				parent, doc = self;
	NSInteger		index;
	
	while (parent = [doc parentFromArray:array])
	{
		index = [[parent children] indexOfObjectIdenticalTo:doc];
		if (index == NSNotFound)
			return nil;
		
		[reverseIndexes addObject:[NSNumber numberWithInt:index]];
		doc = parent;
	}
	
	// If parent is nil, we should just be in the parent array
	index = [array indexOfObjectIdenticalTo:doc];
	if (index == NSNotFound)
		return nil;
	[reverseIndexes addObject:[NSNumber numberWithInt:index]];
	
	// Now build the index path
	NSEnumerator *re = [reverseIndexes reverseObjectEnumerator];
	NSNumber *indexNumber;
	while (indexNumber = [re nextObject])
	{
		if (indexPath == nil)
			indexPath = [NSIndexPath indexPathWithIndex:[indexNumber intValue]];
		else
			indexPath = [indexPath indexPathByAddingIndex:[indexNumber intValue]];
	}
	
	return indexPath;
}


#pragma mark - Archiving And Copying Support

- (NSArray*)mutableKeys
{
	return [NSArray arrayWithObjects:
			@"nodeTitle",
			@"isLeaf",		// isLeaf MUST come before children for initWithDictionary: to work
			@"children", 
			@"nodeIcon",
			nil];
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
	self = [self init];
	NSEnumerator *keysToDecode = [[self mutableKeys] objectEnumerator];
	NSString *key;
	while (key = [keysToDecode nextObject])
	{
		if ([key isEqualToString:@"children"])
		{
			if ([[dictionary objectForKey:@"isLeaf"] boolValue])
				[self setChildren:[NSArray arrayWithObject:self]];
			else
			{
				NSArray *dictChildren = [dictionary objectForKey:key];
				NSMutableArray *newChildren = [NSMutableArray array];
				
				for (id node in dictChildren)
				{
					id newNode = [[[self class] alloc] initWithDictionary:node];
					[newChildren addObject:newNode];
				}
				[self setChildren:newChildren];
			}
		}
		else
			[self setValue:[dictionary objectForKey:key] forKey:key];
	}
	return self;
}

- (NSDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	NSEnumerator		*keysToCode = [[self mutableKeys] objectEnumerator];
	NSString			*key;
	
	while (key = [keysToCode nextObject])
	{
		// convert all children to dictionaries
		if ([key isEqualToString:@"children"])
		{
			if (!zIsLeaf)
			{
				NSMutableArray *dictChildren = [NSMutableArray array];
				for (id node in children)
				{
					[dictChildren addObject:[node dictionaryRepresentation]];
				}
				
				[dictionary setObject:dictChildren forKey:key];
			}
		}
		else if ([self valueForKey:key])
		{
			[dictionary setObject:[self valueForKey:key] forKey:key];
		}
	}
	return dictionary;
}

- (id)initWithCoder:(NSCoder*)coder
{		
	self = [self init];
	NSEnumerator *keysToDecode = [[self mutableKeys] objectEnumerator];
	NSString *key;
	while (key = [keysToDecode nextObject])
		[self setValue:[coder decodeObjectForKey:key] forKey:key];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{	
	NSEnumerator *keysToCode = [[self mutableKeys] objectEnumerator];
	NSString *key;
	while (key = [keysToCode nextObject])
		[coder encodeObject:[self valueForKey:key] forKey:key];
}

- (void)setNilValueForKey:(NSString*)key
{
	if ([key isEqualToString:@"isLeaf"])
		zIsLeaf = NO;
	else
		[super setNilValueForKey:key];
}

@end
