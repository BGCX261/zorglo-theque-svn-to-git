//
//  ZTSerieManagedObject.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 1/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZTNamedManagedObject.h"

@class ZTNamedManagedObject;

@interface ZTSerieManagedObject : ZTNamedManagedObject {

}

- (NSString*) firstDefinedCover;

@end


