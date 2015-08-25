//
//  ZTSeriesCollectionItemView.h
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 14/04/10.
//  Copyright 2010 Zorglo Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZTImageCollectionViewItem.h"


@class ZTSerieVolumesDelegate;
@class ZTEditSerieDelegate;

@interface ZTSeriesCollectionItemView : ZTImageCollectionViewItem {
	IBOutlet NSButton * iInfoButton;
	NSButton *zInfoButton;
	
	
	ZTSerieVolumesDelegate * zVolumeViewDel;
	ZTEditSerieDelegate * zEditViewDel;
	id bSerie;
	
	BOOL zEditingTitle;
	NSTextField *zEditTitle;
}

@property (getter=volumeViewDel, setter=setVolumeViewDel) ZTSerieVolumesDelegate * zVolumeViewDel;
@property (getter=editViewDel, setter=setEditViewDel) ZTEditSerieDelegate * zEditViewDel;
@property (getter=serie, setter=setSerie) id bSerie;

- (IBAction) getInfo: (id) sender;

- (void)textDidEndEditing:(NSNotification *)aNotification;

@end