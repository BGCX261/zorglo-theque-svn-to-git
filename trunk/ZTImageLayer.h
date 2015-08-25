//
//  ZTImageLayer.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 19/04/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ZTImageLayer : CALayer {
	NSURL *zImageURL;
	CGRect zMaxFrame;
	
	NSUInteger zNbShadowedImages;
	BOOL zShadowed;
	NSMutableArray *zSahadowedImages;
}

@property (getter=imageURL, setter=setImageURL, copy) NSURL * zImageURL;
@property (getter=maxFrame, setter=setMaxFrame) CGRect zMaxFrame;
@property (getter=nbShadowedImages, setter=setNbShadowedImages) NSUInteger zNbShadowedImages;

@end
