/*
 * ZTSeriesToolbarController.m
 * ZorgloThèque
 * 
 * Created by Benjamin Dehalu on 2/05/10.
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

#import "ZTSeriesToolbarController.h"
#import "ADEmbeddableToolbar.h"
#import "ZTSeriesCollectionItemView.h"
#import "ZTSerieManagedObject.h"


@implementation ZTSeriesToolbarController

@synthesize bHasSelection;
@synthesize bHasURL;
@synthesize bWebsite;

- (void)awakeFromNib
{
	[iSeriesController addObserver:self forKeyPath:@"selectionIndexes" options:NSKeyValueObservingOptionOld context:nil];
	[self bind:@"website" toObject:iSeriesController withKeyPath:@"selection.website" options:nil];
	[iToolBar addItemWithIcon:[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"add" withExtension:@"png"]] 
						title:@"Add" 
						  tag:0 
				keyEquivalent:@"" 
					   target:self 
					 selector:@selector(addNewSerie:) 
					  tooltip:@"Create New Serie"];
	
	NSButton *b = [iToolBar addItemWithIcon:[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"edit" withExtension:@"png"]] 
						title:@"Edit" 
						  tag:0 
				keyEquivalent:@"" 
					   target:self 
					 selector:@selector(showEditWindow:) 
					  tooltip:@"Change Serie Details"];
	[b bind:@"enabled" toObject:self withKeyPath:@"hasSelection" options:nil];
	
	b = [iToolBar addItemWithIcon:[[NSImage alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"url" withExtension:@"png"]] 
						title:@"Website" 
						  tag:0 
				keyEquivalent:@"" 
					   target:self 
					 selector:@selector(goToURL:) 
						  tooltip:@"Access Serie's Website"];
	[b bind:@"enabled" toObject:self withKeyPath:@"hasURL" options:nil];
}
	 

#pragma mark Bindings

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath compare:@"selectionIndexes"] == NSOrderedSame) {
		BOOL newValue = ([[object selectionIndexes] count] > 0);
		if (newValue != self.hasSelection) {
			self.hasSelection = newValue;
		}
	}
}

- (void) setWebsite:(NSString *)t
{
	if (t) {
		self.hasURL = YES;
	}
	else {
		self.hasURL = NO;
	}
	[self willChangeValueForKey:@"test"];
	bWebsite = t;
	[self didChangeValueForKey:@"test"];

}

#pragma mark Actions

- (void) showEditWindow: (id) sender
{
	NSIndexSet * idxs = [iCollectionView selectionIndexes];
	if ([idxs count] > 0) {
		NSUInteger i = [idxs firstIndex];
		NSCollectionViewItem * colItem = [iCollectionView itemAtIndex:i];
		if (colItem) {
			ZTSeriesCollectionItemView *z = (ZTSeriesCollectionItemView*)[colItem view];
			if (z) {
				[z getInfo:self];
			}
		}
	}
}

- (void) addNewSerie: (id) sender
{
	// Add the Serie
	[iSeriesController add:sender];
}

- (void) goToURL: (id) sender
{
	ZTSerieManagedObject * serie = (ZTSerieManagedObject*)[[iSeriesController selectedObjects] objectAtIndex: 0];
	NSString *urlStr = [serie valueForKey:@"website"];
	if (urlStr) {
		NSURL *url = [NSURL URLWithString:urlStr];
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
}

@end
