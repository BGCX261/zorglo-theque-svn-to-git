//
//  NSArray_Extensions.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 10/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSArray (MyArrayExtensions)
- (BOOL)containsObjectIdenticalTo:(id)object;
- (BOOL)containsAnyObjectsIdenticalTo:(NSArray*)objects;
- (NSIndexSet*)indexesOfObjects:(NSArray*)objects;
@end

