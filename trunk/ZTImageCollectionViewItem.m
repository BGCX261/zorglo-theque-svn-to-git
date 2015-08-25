/*
 * ZTImageCollectionViewItem.m
 * ZorgloThèque
 * 
 * Created by Benjamin Dehalu on 1/05/10.
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

#import "ZTImageCollectionViewItem.h"
#import "ZTImageLayer.h"
#import "ZTVolumeManagedObject.h"

@interface ZTImageCollectionViewItem (Private)

- (NSUInteger) nbOfShadows;

@end



@implementation ZTImageCollectionViewItem

@synthesize bSerieTitle;
@synthesize bSerieCoverFile;
@synthesize bIsSelected;
@synthesize zShadowed;
@synthesize iCollectionViewItem;

- (void) awakeFromNib
{
	if (!zAwokeFromNib) {
		[self bind:@"bIsSelected" toObject: iCollectionViewItem withKeyPath:@"selected" options:nil];
		zAwokeFromNib = YES;
	}
	[super awakeFromNib];
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		zDrawn = NO;
		zAwokeFromNib = NO;
		zShadowed = NO;
    }
    return self;
}

- (void) setBIsSelected:(BOOL)selected
{
	if (zCoverLayer) {
		if (bIsSelected != selected) {
			if (selected) {
				zCoverLayer.borderColor = CGColorCreateGenericRGB(0.089, 0.385, 0.816, 1.000);
				zCoverLayer.borderWidth = 5.0;
				zCoverLayer.cornerRadius = 5.0;
			}
			else {
				zCoverLayer.borderColor = CGColorCreateGenericRGB(1.0,1.0,1.0,1.0);
				zCoverLayer.borderWidth = 5.0;
				zCoverLayer.cornerRadius = 0.0;
				
			}
		}
	}
	bIsSelected = selected;
}

- (void) setBSerieTitle:(NSString *)title {
	bSerieTitle = title;
	zSerieTitleLayer.string = bSerieTitle;
}

- (NSUInteger) nbOfShadows
{
	return 2;
}

- (void)drawRect:(NSRect)dirtyRect {
	CALayer *rootLayer = [self layer];
	if (!zDrawn) {	
		zSerieTitleLayer = [CATextLayer layer];
		zCoverLayer = [ZTImageLayer layer];
		zSerieTitleLayer.position = rootLayer.position;
		zSerieTitleLayer.frame = CGRectMake (5, 5, rootLayer.bounds.size.width-10, 30);
		zSerieTitleLayer.fontSize = 14;
		zSerieTitleLayer.wrapped = YES;
		zSerieTitleLayer.alignmentMode = kCAAlignmentCenter;
		zSerieTitleLayer.shadowOpacity = .8f;
		zSerieTitleLayer.shadowRadius = 2.0;
		zSerieTitleLayer.shadowOffset = CGSizeMake(0.0, 0.0);
		zSerieTitleLayer.cornerRadius = 3.0;
		zSerieTitleLayer.string = self.bSerieTitle;
		[rootLayer addSublayer:zSerieTitleLayer];
		
		
		zCoverLayer.frame = CGRectMake((rootLayer.bounds.size.width - 100) / 2, 40, 100, 133);
		zCoverLayer.maxFrame = zCoverLayer.frame;
		if (self.shadowed) {
			zCoverLayer.nbShadowedImages = [self nbOfShadows];
		}
		else {
			zCoverLayer.nbShadowedImages = 0;
		}
		zCoverLayer.bounds = CGRectMake(5, 5, 90, 123);
		zCoverLayer.borderColor = CGColorCreateGenericRGB(1.0,1.0,1.0,1.0);
		zCoverLayer.borderWidth = 5.0;
		zCoverLayer.imageURL = [[ZTVolumeManagedObject coverStorage] URLByAppendingPathComponent:self.bSerieCoverFile];
		zCoverLayer.shadowOffset = CGSizeMake(0.0, 0.0);
		zCoverLayer.shadowOpacity = 1.2f;
		zCoverLayer.shadowRadius = 5.0;
		zCoverLayer.shadowColor = CGColorCreateGenericGray(0.000, 1.000);
		
		[rootLayer addSublayer:zCoverLayer];
		[zCoverLayer setNeedsDisplay];
		zDrawn = YES;
		zSubLayers = rootLayer.sublayers;
	}
	else if (rootLayer.sublayers != zSubLayers) {
		rootLayer.sublayers = zSubLayers;
		zSubLayers = rootLayer.sublayers;
	}
}


@end
