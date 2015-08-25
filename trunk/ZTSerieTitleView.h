//
//  ZTSerieTitleView.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 1/05/10.
//  Copyright 2010 Zorglo Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZTSerieTitleView : NSView {
	NSUInteger zType;
	NSUInteger zAlpha;
}

@property (getter=type, setter=setType) NSUInteger zType;
@property (getter=alpha, setter=setAlpha) NSUInteger zAlpha;

@end
