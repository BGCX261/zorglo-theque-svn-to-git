/*
 * ZTCover.m
 * ZorgloThèque
 * 
 * Created by Benjamin Dehalu on 10/04/10.
 * 
 * Copyright (c) 2010 Zorglo Software
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "ZTCover.h"
#import "ZTVolumeManagedObject.h"

@implementation ZTCover

@synthesize zHighlighted;
@synthesize zCoverFileName;
@synthesize zImageLayer;

- (void) setController: (NSArrayController **) controller
{
	zController = controller;
}

- (void) setCoverFileName:(NSString *)name
{
	zCoverFileName = name;
}

- (id) init
{
	if (self = [super init]) {
		zHighlighted = NO;
	}
	return self;
}

- (BOOL) isEnabled
{
	return (zController && *zController && [[*zController selectedObjects] count] > 0); 
}

- (NSURL*) url
{
	if (self.coverFileName) {
		NSURL *coverURL = [ZTVolumeManagedObject coverStorage];
		return [coverURL URLByAppendingPathComponent:self.coverFileName]; 
	}
	else {
		if ([self isEnabled]) {
			return [[NSBundle mainBundle] URLForResource:@"drop-cover" withExtension:@"png"];
		}
		else {
			return [[NSBundle mainBundle] URLForResource:@"unknown-cover" withExtension:@"png"];
		}
	}
}

- (void) drawHighlighting: (CALayer *) theLayer
{
	theLayer.shadowOpacity = .8f;
	if (self.highlighted) {
		theLayer.shadowOffset = CGSizeMake(0.0, 0);
		theLayer.shadowRadius = 10.0;
		zTextLayer.string = @"Assign image as cover...";
		zTextLayer.backgroundColor = CGColorCreateGenericRGB(1.0f,1.0f,1.0f,.5f);		
	}
	else {
		theLayer.shadowOffset = CGSizeMake(0.0, -3.0);
		theLayer.shadowRadius = 3.0;
		if (!self.coverFileName) {
			if ([self isEnabled])
				zTextLayer.string = @"Drop an image to assign the cover...";
			else
				zTextLayer.string = @"No Selection";
		}
		else {
			zTextLayer.string = @"";
		}
		zTextLayer.backgroundColor = nil;
	}
}

- (CGRect)fitImage: (CGImageRef) imgRef toLayer: (CALayer *)theLayer
{
	CGRect fit = theLayer.bounds;
	
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
	CGFloat x = (fit.size.width - width) / 2.0;
	CGFloat y = (fit.size.height - height) / 2.0;
	
	return CGRectMake(x, y, width, height);
}

- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{
	if (!zTextLayer) 
		zTextLayer = [CATextLayer layer];
	[self drawHighlighting: theLayer];
	
	NSURL* url = [self url];
	
	CGImageRef imgRef = NULL;
	
	if (url) {
		CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef) url, NULL);
		if(imageSource){
			imgRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
			if (imgRef) {
				if (zImageLayer) {
					[zImageLayer removeFromSuperlayer];
				}
				zImageLayer = [CALayer layer];
				zImageLayer.frame = [self fitImage:imgRef toLayer:theLayer];
				
				[theLayer addSublayer:zImageLayer];
				CGContextDrawImage(theContext, zImageLayer.frame, imgRef);
				CGImageRelease(imgRef);
			}
			CFRelease(imageSource);
		}
	}
	
	zTextLayer.position = theLayer.position;
	zTextLayer.frame = CGRectMake(5, theLayer.bounds.size.height-32, theLayer.bounds.size.width-10, 30);
	zTextLayer.fontSize = 14;
	zTextLayer.wrapped = YES;
	zTextLayer.alignmentMode = kCAAlignmentCenter;
	zTextLayer.shadowOpacity = .8f;
	zTextLayer.shadowRadius = 2.0;
	zTextLayer.shadowOffset = CGSizeMake(0.0, 0.0);
	zTextLayer.cornerRadius = 3.0;
	[theLayer addSublayer:zTextLayer];
	
}

@end
