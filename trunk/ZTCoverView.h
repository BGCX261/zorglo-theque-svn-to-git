//
//  ZTCoverView.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 27/03/10.
//  Copyright 2010 Zorglo Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZTCoverAttribute;
@class ZTCover;

@interface ZTCoverView : NSView {

	NSTrackingArea *zTrackingArea;
	CALayer	*zZoomedLayer;
	
	// The cover
	NSString *bCoverFileName;
	IBOutlet NSArrayController *iController;
	
	NSMutableArray *zVertDelegates;
	NSMutableArray *zHoriDelegates;
	ZTCoverAttribute *delegate1;
	ZTCoverAttribute *delegate2;
	ZTCoverAttribute *delegate3;
	ZTCoverAttribute *delegate4;
	ZTCoverAttribute *delegate5;
	
	NSUInteger zVertShifted;
	NSUInteger zHoriShifted;
	// Value in binary form should be: 
	// 1 -> not present. 
	// 0 -> present. 
	// Plus left 1 bit as guard
	NSMutableArray * zVertFreeSpots;
	NSMutableArray * zHoriFreeSpots;
	
	
	ZTCover *coverDelegate;
	
	BOOL bEO;
	BOOL bSigned;
	BOOL bDedicaced;
	BOOL bLove;
	BOOL bHate;
}

@property (setter=seyCoverFileName, getter=coverFileName, copy) NSString * bCoverFileName;
@property (setter=setEO, getter=EO) BOOL bEO;
@property (setter=setSignature, getter=signature) BOOL bSigned;
@property (setter=setDedicaced, getter=dedicaced) BOOL bDedicaced;
@property (setter=setHate, getter=hate) BOOL bHate;
@property (setter=setLove, getter=love) BOOL bLove;

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
