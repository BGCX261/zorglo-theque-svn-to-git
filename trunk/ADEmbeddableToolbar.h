/*
 Copyright (c) 2009, Aaron Dodson
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the Aaron Dodson or Stuffed Iggy Software nor the
 names of their contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY Aaron Dodson ``AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL Aaron Dodson BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <Cocoa/Cocoa.h>

@interface ADEmbeddableToolbar : NSView 
{	
	NSMutableArray *items;
	int xOffset;
	BOOL runnethOver, displayModeChanged;
	NSPopUpButton *overflow;
	NSToolbarDisplayMode displayMode;
	
	IBOutlet NSView *partnerView;
}

- (NSButton*)addItemWithIcon:(NSImage *)icon title:(NSString *)title tag:(int)tag keyEquivalent:(NSString *)equivalent target:(id)target selector:(SEL)selector tooltip:(NSString *)hint;
- (void)addItemWithView:(NSView *)view title:(NSString *)title;
- (void)setTitle:(NSString *)newTitle forItemAtIndex:(int)index;
- (void)updateOverflowMenu;
- (BOOL)removeItemAtIndex:(int)index;
- (void)setDisplayMode:(NSToolbarDisplayMode)newMode;

@end
