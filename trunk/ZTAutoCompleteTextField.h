//
//  ZTAutoCompleteTextField.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 27/02/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZTAutoCompleteDataSource.h"


static const int z_MaxRows = 6;
static const int z_FrameMargin = 1;


@interface ZTAutoCompleteTextField : NSTextField {
	NSWindow*					zPopupWin;
	NSTableView*				zTableView;
	ZTAutoCompleteDataSource*	zDataSource;
	
	IBOutlet NSArrayController*	iVolumesController;
	
	NSString*					rEntityName;
	NSString*					rDeleteFormat;
	NSString*					rRenameFormat;
}

@property(readonly,getter=volumesController) NSArrayController *iVolumesController;
@property(readonly,getter=tableView) NSTableView *zTableView;
@property(setter=setDataSource,getter=dataSource) ZTAutoCompleteDataSource *zDataSource;


// Runtime attributes
@property(copy) NSString *rEntityName;
@property(copy) NSString *rDeleteFormat;
@property(copy) NSString *rRenameFormat;

- (id)fieldEditor;
- (void) closePopup;
- (BOOL) isOpen;
- (int) visibleRows;
- (void) openPopup;
- (void) enterResult:(int)aRow;
- (void) selectRowAt:(int)aRow;
- (void) selectRowBy:(int)aRows;

@end

@interface ZTAutoCompleteWindow : NSWindow
- (BOOL)isKeyWindow;
@end
