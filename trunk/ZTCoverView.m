//
//  ZTCoverView.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 27/03/10.
//  Copyright 2010 Zorglo Software. All rights reserved.
//

#import "ZTCoverView.h"
#import "ZTCoverAttribute.h"
#import "ZTCover.h"
#import "ZTVolumeManagedObject.h"

#define ZTDontForce 0
#define ZTForceOn 1
#define ZTForceOff 2

@interface ZTCoverView(Private)

- (void) buildLayersTree;
- (void) restoreInitialPositionForLayer: (CALayer *) layer withDelegate: (ZTCoverAttribute *) del vertically: (BOOL) vert shifted: (NSUInteger *) shifted;
- (NSUInteger) actionForMask: (NSUInteger) mask withPosition: (NSUInteger*) pos andShifted: (NSUInteger *) shifted;
- (NSUInteger) positionForShiftedIcon: (BOOL) vert shifted: (NSUInteger) shifted;
- (void) shiftLayerVertically: (CGPoint *) currentPosition forDelegate: (ZTCoverAttribute *)del atPosition: (NSUInteger) cnt;
- (void) shiftLayerHorizontally: (CGPoint *) currentPosition forDelegate: (ZTCoverAttribute *)del atPosition: (NSUInteger) cnt;
- (void) restoreInitialPositionForLayer: (CALayer *) layer withDelegate: (ZTCoverAttribute *) del vertically: (BOOL) vert shifted: (NSUInteger *) shifted;
- (void) replaceLayerAtPosition: (NSUInteger) pos fromPosition: (CGPoint *) currentPosition forDelegate: (ZTCoverAttribute *) del shifted: (NSUInteger *) shifted vertically: (BOOL) vert;

@end

@implementation ZTCoverView

@synthesize bCoverFileName;
@synthesize bEO;
@synthesize bSigned;
@synthesize bDedicaced;
@synthesize bHate;
@synthesize bLove;

- (void) setCoverFileName: (NSString *) name
{
	bCoverFileName = name;
	NSArray *subLayers = [self layer].sublayers;
	if ([subLayers count] > 0) { 
		CALayer *theLayer = [subLayers objectAtIndex:0];
		if (theLayer) {
			((ZTCover *)theLayer.delegate).coverFileName = name;
			[theLayer setNeedsDisplay];
		}
	}
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		zTrackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] 
													 options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow) 
													   owner:self 
													userInfo:nil];
		[self addTrackingArea:zTrackingArea];
		zZoomedLayer = nil;
		zVertShifted = 15;
		zHoriShifted = 7;
		
		zVertDelegates = [[NSMutableArray alloc] initWithCapacity:3];
		zHoriDelegates = [[NSMutableArray alloc] initWithCapacity:2];
		
		zVertFreeSpots = [[NSMutableArray alloc] init];
		zHoriFreeSpots = [[NSMutableArray alloc] init];
		
		[self registerForDraggedTypes: [NSArray arrayWithObjects: NSFilesPromisePboardType, NSFilenamesPboardType, nil]];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (keyPath == @"selectedObjects") {
		NSArray *subLayers = [self layer].sublayers;
		if ([subLayers count] > 0) { 
			CALayer *theLayer = [subLayers objectAtIndex:0];
			if (theLayer) {
				[theLayer setNeedsDisplay];
			}
		}
	}
}

- (CALayer *) coverAtttributeLayer: (NSString *) name inRect: (NSRect) coverRect atIndex: (NSUInteger) idx vertically: (BOOL) vert assignTo: (ZTCoverAttribute **) delegateI
{	
	CALayer *myLayer = [CALayer layer];
	if (vert) {
		myLayer.position = CGPointMake(0.0+12, coverRect.size.height - (idx * 25)+18);
	}
	else {
		myLayer.position = CGPointMake(coverRect.size.width - (idx * 25)+9, 0.0+9);
	}

	myLayer.anchorPoint = CGPointMake(0.5, 0.5);
	myLayer.bounds = CGRectMake(0.0, 0.0, 18, 18);
	
	ZTCoverAttribute *myDelegate = [[ZTCoverAttribute alloc] init];
	myDelegate.imageName = name;
	myDelegate.vert = vert;
	
	[myLayer setDelegate:myDelegate];
	if (vert) {
		if ([zVertDelegates count] >= idx-1)
			[zVertDelegates insertObject:myDelegate atIndex:idx-1];
	}
	else {
		if ([zHoriDelegates count] >= idx-1)
			[zHoriDelegates insertObject:myDelegate atIndex:idx-1];
	}

	*delegateI = myDelegate; //FIXME: Somehow, the delegate gets released even with GC when not keeping a reference in the view
	myDelegate.layer = myLayer;
	myDelegate.initialPosition = myLayer.position;
	return myLayer;
}

- (CALayer *) coverLayerInRect: (NSRect) fullRect
{
	CALayer *coverLayer = [CALayer layer];
	CGFloat height =  fullRect.size.height;
	CGFloat width = 400.0 / 533.0 * height;
	if (width > fullRect.size.width - 30) {
		width = fullRect.size.width - 30;
		height = 533.0 / 400.0 * width;
	}
	coverLayer.position = CGPointMake((fullRect.size.width - width), fullRect.size.height - height - 10);
	coverLayer.anchorPoint = CGPointMake(0, 0);
	coverLayer.bounds = CGRectMake(0, 0, width, height);
	coverLayer.contentsGravity = kCAGravityResizeAspect;
	
	coverDelegate = [[ZTCover alloc] init];
	[coverDelegate setController: &iController];
	
	[self bind:@"coverFileName" toObject:iController withKeyPath:@"selection.coverFileName" options:nil];
	coverLayer.delegate = coverDelegate;
	
	
	return coverLayer;
}

- (BOOL) isEnabled
{
	return ([[iController selectedObjects] count] > 0);
}

- (void) awakeFromNib
{
	[self buildLayersTree];
	
	[iController addObserver:self forKeyPath:@"selectedObjects" options:NSKeyValueObservingOptionOld context:nil];
}

- (void) buildLayersTree
{
	CALayer *rootLayer = [CALayer layer];
	NSRect coverRect = self.frame;	
	[rootLayer setFrame: CGRectMake(coverRect.origin.x, coverRect.origin.y, coverRect.size.width, coverRect.size.height)];
	
	
	[self setLayer:rootLayer];
	[self setWantsLayer:YES];
	[rootLayer setNeedsDisplay];
	
	CALayer *coverLayer = [self coverLayerInRect: coverRect];
	[rootLayer addSublayer:coverLayer];
	[coverLayer setNeedsDisplay];
	
	
	CALayer *signedLayer = [self coverAtttributeLayer:@"signed" inRect:coverRect atIndex:1 vertically: YES assignTo: &delegate1];
	((ZTCoverAttribute *)signedLayer.delegate).position = 14;
	((ZTCoverAttribute *)signedLayer.delegate).complPosition = 1;
	((ZTCoverAttribute *)signedLayer.delegate).mask = 15;
	((ZTCoverAttribute *)signedLayer.delegate).volumeKey = @"signature";
	CALayer *eoLayer = [self coverAtttributeLayer:@"eo" inRect:coverRect atIndex:2 vertically: YES assignTo: &delegate2];
	((ZTCoverAttribute *)eoLayer.delegate).position = 13;
	((ZTCoverAttribute *)eoLayer.delegate).complPosition = 2;
	((ZTCoverAttribute *)eoLayer.delegate).mask = 15;
	((ZTCoverAttribute *)eoLayer.delegate).volumeKey = @"eo";
	CALayer *dedicaceLayer = [self coverAtttributeLayer:@"dedicace" inRect:coverRect atIndex:3 vertically: YES assignTo: &delegate3];
	((ZTCoverAttribute *)dedicaceLayer.delegate).position = 11;
	((ZTCoverAttribute *)dedicaceLayer.delegate).complPosition = 4;
	((ZTCoverAttribute *)dedicaceLayer.delegate).mask = 15;
	((ZTCoverAttribute *)dedicaceLayer.delegate).volumeKey = @"dedicaced";
	CALayer *loveLayer = [self coverAtttributeLayer:@"love" inRect:coverRect atIndex:1 vertically: NO assignTo: &delegate4];
	((ZTCoverAttribute *)loveLayer.delegate).position = 6;
	((ZTCoverAttribute *)loveLayer.delegate).complPosition = 1;
	((ZTCoverAttribute *)loveLayer.delegate).mask = 5;
	((ZTCoverAttribute *)loveLayer.delegate).volumeKey = @"love";
	CALayer *hateLayer = [self coverAtttributeLayer:@"hate" inRect:coverRect atIndex:2 vertically: NO assignTo: &delegate5];
	((ZTCoverAttribute *)hateLayer.delegate).position = 5;
	((ZTCoverAttribute *)hateLayer.delegate).complPosition = 2;
	((ZTCoverAttribute *)hateLayer.delegate).mask = 6;
	((ZTCoverAttribute *)hateLayer.delegate).volumeKey = @"hate";
	
	
	[rootLayer addSublayer:signedLayer];
	[signedLayer setNeedsDisplay];
	[rootLayer addSublayer:eoLayer];
	[eoLayer setNeedsDisplay];
	[rootLayer addSublayer:dedicaceLayer];
	[dedicaceLayer setNeedsDisplay];
	[rootLayer addSublayer:loveLayer];
	[loveLayer setNeedsDisplay];
	[rootLayer addSublayer:hateLayer];
	[hateLayer setNeedsDisplay];
	
	[self bind:@"signature" toObject:iController withKeyPath:@"selection.signature" options:nil];
	[self bind:@"EO" toObject:iController withKeyPath:@"selection.eo" options:nil];
	[self bind:@"dedicaced" toObject:iController withKeyPath:@"selection.dedicaced" options:nil];
	[self bind:@"love" toObject:iController withKeyPath:@"selection.love" options:nil];
	[self bind:@"hate" toObject:iController withKeyPath:@"selection.hate" options:nil];
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect: dirtyRect];
}

#pragma mark Binded values

- (void)shift: (NSUInteger *)shifted layer: (CALayer *)layer newValue: (BOOL)place
{
	ZTCoverAttribute *del = layer.delegate;
	CGPoint currentPosition = layer.position;
	if ((*shifted & del.complPosition) == 0 && !place) {
		// The layer is already assigned and we need to move it back
		[self restoreInitialPositionForLayer:layer withDelegate:del vertically: del.vert shifted: shifted];
	}
	else if (place) {
		// the layer is not yet assigned and we need to assign it
		NSUInteger pos, c = [self actionForMask:del.mask withPosition: &pos andShifted: shifted];
		
		if (c != 3) {
			
			if (c == 1) {
				NSUInteger cnt = 0;
				cnt = [self positionForShiftedIcon: del.vert shifted: *shifted];
				
				if (del.vert) {
					[self shiftLayerVertically:&currentPosition forDelegate: del atPosition: cnt];
				}
				else {
					[self shiftLayerHorizontally:&currentPosition forDelegate: del atPosition: cnt];
				}
				
			}
			else {
				[self replaceLayerAtPosition:pos fromPosition:&currentPosition forDelegate:del shifted: shifted vertically: del.vert];
			}
			del.selected = YES;
			
			
			layer.position = currentPosition;
			
			// Record that we added a new attribute
			*shifted = *shifted & del.position;
		}
	}
}

- (void)setSignature:(BOOL)sign
{
	CALayer *layer = [[self layer].sublayers objectAtIndex: 1];
	[self shift: &zVertShifted layer:layer newValue:sign];
	bSigned = sign;
}

- (void)setEO:(BOOL)eo
{
	CALayer *layer = [[self layer].sublayers objectAtIndex: 2];
	[self shift: &zVertShifted layer:layer newValue:eo];
	bEO = eo;
}

- (void)setDedicaced:(BOOL)dedicaced
{
	CALayer *layer = [[self layer].sublayers objectAtIndex: 3];
	[self shift: &zVertShifted layer:layer newValue:dedicaced];
	bDedicaced = dedicaced;
}

- (void)setLove:(BOOL)love
{
	CALayer *layer = [[self layer].sublayers objectAtIndex: 4];
	[self shift: &zHoriShifted layer:layer newValue:love];
	bLove = love;
}

- (void)setHate:(BOOL)hate
{
	CALayer *layer = [[self layer].sublayers objectAtIndex: 5];
	[self shift: &zHoriShifted layer:layer newValue:hate];
	bHate = hate;
}

#pragma mark Events

- (void) restoreSizeOfLayer
{
	CGRect currentRect = zZoomedLayer.bounds;
	currentRect.size.height /= 2;
	currentRect.size.width /= 2;
	zZoomedLayer.bounds = currentRect;
	zZoomedLayer = nil;
}

- (void) zoomOnLayer: (CALayer *) theLayer
{
	CGRect currentRect = theLayer.bounds;
	currentRect.size.height *= 2;
	currentRect.size.width *= 2;
	theLayer.bounds = currentRect;
	[theLayer setNeedsDisplay];
	zZoomedLayer = theLayer;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	// Which layer are we in ?
	NSPoint location = [[self superview] convertPoint:[theEvent locationInWindow] fromView: nil];
	CALayer *currentLayer = [self.layer hitTest:CGPointMake(location.x, location.y)];
	if (zZoomedLayer != nil && zZoomedLayer != currentLayer) {
		[self restoreSizeOfLayer];
	}
	else if (currentLayer != nil && [currentLayer.delegate isKindOfClass:[ZTCoverAttribute class]] && zZoomedLayer == nil) {
		[self zoomOnLayer:currentLayer];
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	if (zZoomedLayer != nil) {
		[self restoreSizeOfLayer];
	}
}

- (NSUInteger) actionForMask: (NSUInteger) mask withPosition: (NSUInteger*) pos andShifted: (NSUInteger *) shifted
{
	// 0 -> error; 1 -> append; 2 -> replace; 3 -> nothing
	NSUInteger c = 0;
	NSUInteger t = (*shifted | mask);
	NSUInteger t1 = t, t2 = 1, cnt1 = 0, cnt0 = 0;
	NSUInteger posT = 0;
	while (t1 != 0) {
		t2 = t1;
		t1 >>= 1;
		if ((t1*2) != t2) cnt1++;
		else cnt0++;
		if (cnt0 < 1) posT++;
	}
	
	if (cnt0 == 0) {
		// Append
		c = 1;
	}
	else if (cnt0 == 1) {
		// Replace
		c = 2;
	}
	else {
		c = 3;
	}
	*pos = posT;
	return c;
}

- (NSUInteger) positionForShiftedIcon: (BOOL) vert shifted: (NSUInteger) shifted
{
	// Check the place to put the icon
	NSUInteger cnt = 0;
	NSUInteger test = (vert) ? [zVertFreeSpots count] : [zHoriFreeSpots count];
	if (test != 0) {
		cnt = (vert) ? [[zVertFreeSpots objectAtIndex:0] intValue] : [[zHoriFreeSpots objectAtIndex:0] intValue];
		if (vert) [zVertFreeSpots removeObjectAtIndex:0];
		else [zHoriFreeSpots removeObjectAtIndex:0];
	}
	else {
		NSUInteger t=shifted, t1=1; 
		while (t1 != 0) {
			if ((t * 2) == t1) cnt++;
			t1 = t;
			t >>= 1;
		}
	}
	return cnt;
}

- (void) restoreInitialPositionForLayer: (CALayer *) layer withDelegate: (ZTCoverAttribute *) del vertically: (BOOL) vert shifted: (NSUInteger *) shifted
{
	layer.position = del.initialPosition;
	*shifted = *shifted | del.complPosition;
	if (vert) {
		[zVertFreeSpots addObject:[NSNumber numberWithInt: del.insertedAtPosition]];
		[zVertFreeSpots sortUsingSelector:@selector(compare:)];
	}
	else {
		[zHoriFreeSpots addObject:[NSNumber numberWithInt: del.insertedAtPosition]];
		[zHoriFreeSpots sortUsingSelector:@selector(compare:)];
	}

}

- (void) replaceLayerAtPosition: (NSUInteger) pos fromPosition: (CGPoint *) currentPosition forDelegate: (ZTCoverAttribute *) del shifted: (NSUInteger *) shifted vertically: (BOOL) vert
{
	ZTCoverAttribute *replaceDelegate = (vert) ? [zVertDelegates objectAtIndex:pos] : [zHoriDelegates objectAtIndex:pos];
	if (replaceDelegate) {
		CALayer *replaceLayer = replaceDelegate.layer;
		*currentPosition = replaceLayer.position;
		replaceLayer.position = replaceDelegate.initialPosition;
		*shifted = *shifted | replaceDelegate.complPosition;
		del.insertedAtPosition = replaceDelegate.insertedAtPosition;
		NSArray *selectedVolumes = [iController selectedObjects];
		[selectedVolumes enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
			[obj setValue: [NSNumber numberWithInt:0] forKey: replaceDelegate.volumeKey];
		}];
	}
}

- (CALayer *) getCoverLayer
{
	CALayer *coverLayer = ((ZTCover*)((CALayer*)[self.layer.sublayers objectAtIndex:0]).delegate).coverLayer;
	return coverLayer;
}

- (void) shiftLayerVertically: (CGPoint *) currentPosition forDelegate: (ZTCoverAttribute *)del atPosition: (NSUInteger) cnt
{
	CALayer *coverLayer = [self getCoverLayer];
	(*currentPosition).y = coverLayer.superlayer.frame.origin.y + coverLayer.frame.origin.y + coverLayer.frame.size.height + 5;
	(*currentPosition).x = coverLayer.superlayer.frame.origin.x + coverLayer.frame.origin.x + coverLayer.frame.size.width - 9 - (cnt*25);
	del.insertedAtPosition = cnt;
}

- (void) shiftLayerHorizontally: (CGPoint *) currentPosition forDelegate: (ZTCoverAttribute *)del atPosition: (NSUInteger) cnt
{
	CALayer *coverLayer = [self getCoverLayer];
	(*currentPosition).y = coverLayer.superlayer.frame.origin.y + coverLayer.frame.origin.y + 5;
	(*currentPosition).x = coverLayer.superlayer.frame.origin.x + coverLayer.frame.origin.x + 5 + (cnt*25);
	del.insertedAtPosition = cnt;
}

- (void)mouseDownWithShifted: (NSUInteger *) shifted withDelegate: (ZTCoverAttribute *) del andLayer: (CALayer *) currentLayer
{
	CGPoint currentPosition = currentLayer.position;
	// Is the attribute already assigned?
	if ((*shifted & del.complPosition) == 0) {
		[self restoreInitialPositionForLayer:currentLayer withDelegate:del vertically: del.vert shifted: shifted];
	}
	else {
		
		NSUInteger pos, c = [self actionForMask:del.mask withPosition: &pos andShifted: shifted];
		
		if (c != 3) {
			
			if (c == 1) {
				NSUInteger cnt = 0;
				cnt = [self positionForShiftedIcon: del.vert shifted: *shifted];
				
				if (del.vert) {
					[self shiftLayerVertically:&currentPosition forDelegate: del atPosition: cnt];
				}
				else {
					[self shiftLayerHorizontally:&currentPosition forDelegate: del atPosition: cnt];
				}
				
			}
			else {
				[self replaceLayerAtPosition:pos fromPosition:&currentPosition forDelegate:del shifted: shifted vertically: del.vert];
			}
			del.selected = YES;
			
			
			currentLayer.position = currentPosition;
			
			// Record that we added a new attribute
			*shifted = *shifted & del.position;
		}
	}
}

- (void)mouseDownForVerticalAttributeWithDelegate: (ZTCoverAttribute *) del andLayer: (CALayer *) currentLayer
{
	[self mouseDownWithShifted: &zVertShifted withDelegate: del andLayer: currentLayer];
}

- (void)mouseDownForHorizontalAttributeWithDelegate: (ZTCoverAttribute *) del andLayer: (CALayer *) currentLayer
{
	[self mouseDownWithShifted: &zHoriShifted withDelegate: del andLayer: currentLayer];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint location = [[self superview] convertPoint:[theEvent locationInWindow] fromView: nil];
	CALayer *currentLayer = [self.layer hitTest:CGPointMake(location.x, location.y)];
	if ([currentLayer.delegate isKindOfClass:[ZTCoverAttribute class]]) {
		ZTCoverAttribute * del = currentLayer.delegate;
		if (del.vert) {
			if ((zVertShifted & del.complPosition) == 0) {
				NSArray *selectedVolumes = [iController selectedObjects];
				[selectedVolumes enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
					[obj setValue: [NSNumber numberWithInt:0] forKey: del.volumeKey];
				}];
			}
			else {
				NSArray *selectedVolumes = [iController selectedObjects];
				[selectedVolumes enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
					[obj setValue: [NSNumber numberWithInt:1] forKey: del.volumeKey];
				}];
				//[self mouseDownForVerticalAttributeWithDelegate: del andLayer: currentLayer];
			}
		}
		else {
			if ((zHoriShifted & del.complPosition) == 0) {
				NSArray *selectedVolumes = [iController selectedObjects];
				[selectedVolumes enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
					[obj setValue: [NSNumber numberWithInt:0] forKey: del.volumeKey];
				}];
			}
			else {
				NSArray *selectedVolumes = [iController selectedObjects];
				[selectedVolumes enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
					[obj setValue: [NSNumber numberWithInt:1] forKey: del.volumeKey];
				}];
			}
			
			//[self mouseDownForHorizontalAttributeWithDelegate: del andLayer: currentLayer];
		}
	}
}

#pragma mark Drag&Drop

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	if ([self isEnabled]) {
		CALayer *theLayer = [[self layer].sublayers objectAtIndex:0];
		((ZTCover*)theLayer.delegate).highlighted = YES;
		[theLayer.delegate drawHighlighting: theLayer];
		return NSDragOperationCopy;
	}
	return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	CALayer *theLayer = [[self layer].sublayers objectAtIndex:0];
	((ZTCover*)theLayer.delegate).highlighted = NO;
	[theLayer.delegate drawHighlighting: theLayer];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	return [self isEnabled];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pb = [sender draggingPasteboard];
	NSArray *types = [pb types];
	if ([types containsObject:NSFilesPromisePboardType]) {
		NSArray *test = [pb propertyListForType:NSFilesPromisePboardType];
		if ([test firstObjectCommonWithArray:[NSArray arrayWithObjects:@"jpeg", @"png", @"tiff", nil]] != nil) {
			// Where to store the covers
			NSURL *dropLocation = [ZTVolumeManagedObject coverStorage];
			
			NSArray *fileNames = [sender namesOfPromisedFilesDroppedAtDestination:dropLocation];
			if (fileNames && [fileNames count] > 0) {
				NSString *coverFileName = [fileNames objectAtIndex: 0];
				
				// Get the current volumes
				NSArray *selectedVolumes = [iController selectedObjects];
				[selectedVolumes enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
					((ZTVolumeManagedObject *)obj).coverFileName = coverFileName;
				}];
				
				return YES;
			}
		}
	}
	else if ([types containsObject:NSFilenamesPboardType]) {
		NSString *filePath = [[pb propertyListForType:NSFilenamesPboardType] lastObject];
		if ([[filePath pathExtension] caseInsensitiveCompare:@"png"] == NSOrderedSame || 
			[[filePath pathExtension] caseInsensitiveCompare:@"tiff"] == NSOrderedSame ||
			[[filePath pathExtension] caseInsensitiveCompare:@"jpeg"] == NSOrderedSame ||
			[[filePath pathExtension] caseInsensitiveCompare:@"tif"] == NSOrderedSame ||
			[[filePath pathExtension] caseInsensitiveCompare:@"jpg"] == NSOrderedSame) {
			NSURL *fileURL = [ZTVolumeManagedObject copyFileAsCover:filePath];
			if (fileURL) {
				NSArray *selectedVolumes = [iController selectedObjects];
				[selectedVolumes enumerateObjectsUsingBlock:^ (id obj, NSUInteger idx, BOOL *stop) {
					((ZTVolumeManagedObject *)obj).coverFileName = [fileURL lastPathComponent];
				}];
				return YES;
			}
		}
	}
	return NO;
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender
{
	CALayer *theLayer = [[self layer].sublayers objectAtIndex:0];
	((ZTCover*)theLayer.delegate).highlighted = NO;
	[theLayer.delegate drawHighlighting: theLayer];
}

@end
