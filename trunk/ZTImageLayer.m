//
//  ZTImageLayer.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 19/04/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTImageLayer.h"

@interface ZTImageLayer (Private)

- (CGRect)fitImage: (CGImageRef) imgRef;

@end


@implementation ZTImageLayer

@synthesize zImageURL;
@synthesize zMaxFrame;
@synthesize zNbShadowedImages;

- (id) initWithLayer:(id)layer
{
	self = [super initWithLayer:layer];
	if (self) {
		zShadowed = NO;
	}
	return self;
}


- (CGRect)fitImage: (CGImageRef) imgRef
{
	CGRect fit = self.maxFrame;
	
	// Compute the size
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	if (height > fit.size.height) {
		width = ((width / height) * fit.size.height);
		height = fit.size.height;
	}
	if (width > fit.size.width) {
		height = ((height / width) * fit.size.width);
		width = fit.size.width;
	}
	
	// Compute the origin
	CGFloat x = (fit.size.width - width) / 2.0 + fit.origin.x;
	CGFloat y = (fit.size.height - height) / 2.0 + fit.origin.y;
	
	return CGRectMake(x + self.borderWidth, y + self.borderWidth, width - (2 * self.borderWidth), height - (2 * self.borderWidth));
}

- (void) createShadowedImages
{
	if (!zNbShadowedImages || zShadowed) return;
	zSahadowedImages = [[NSMutableArray	alloc] initWithCapacity:zNbShadowedImages];
	
	for (int i=0, p=1, n=0; n < zNbShadowedImages; i += (p > 0) ? 1 : 0, n++) {
		CALayer *layer1 = [CALayer layer];
		[[self superlayer] insertSublayer:layer1 below: self];
		layer1.frame = self.frame;
		layer1.backgroundColor = CGColorCreateGenericGray(1.000, 1.000);
		layer1.anchorPoint = CGPointMake(0.5, 0.5);
		layer1.transform = CATransform3DMakeRotation(((5 * (i+1) * p) / 57.2958), 0, 0, 1);
		[layer1 setNeedsDisplay];
		p *= -1;
		[zSahadowedImages addObject:layer1];
	}
	zShadowed = YES;
}

- (void) resizeShadowedImages
{
	if (!zNbShadowedImages || !zShadowed) return;
	CGRect targetFrame = self.frame;
	[zSahadowedImages enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
		((CALayer *)obj).frame = targetFrame; 
	}];
}

- (void)display
{
	[super display];
	if (self.imageURL) {
		CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef) self.imageURL, NULL);
		if(imageSource){
			CGImageRef imgRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
			
			if (imgRef) {
				self.contentsGravity = kCAGravityResizeAspect;
				CGImageRetain(imgRef);
				self.frame = [self fitImage:imgRef];
				self.contents = (id) imgRef;
				
				if (zNbShadowedImages > 0) {
					if (zShadowed) {
						[self resizeShadowedImages];
					}
					else {
						[self createShadowedImages];
					}

				}
			}
			CFRelease(imageSource);
		}
	}
}

@end
