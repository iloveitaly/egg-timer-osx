//
//  TransparentWindow.m
//  RoundedFloatingPanel
//
//  Created by Matt Gemmell on Thu Jan 08 2004.
//  <http://iratescotsman.com/>
//
//  Customizations for Egg Timer by Michael Bianco
//  <http://developer.mabwebdesign.com>
//


#import "TransparentWindow.h"

// http://www.cocoadev.com/index.pl?PreventWindowOrdering

@implementation TransparentWindow

- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(unsigned int)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag { 
    if (self = [super initWithContentRect:contentRect styleMask:NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:NO]) {
        [self setLevel:NSStatusWindowLevel];
        [self setBackgroundColor: [NSColor clearColor]];
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        [self setHasShadow:NO];
		[self setMovableByWindowBackground:NO];
		[self setHidesOnDeactivate:NO];
        
        return self;
    }
    
    return nil;
}

- (void)mouseDragged:(NSEvent *)theEvent {
#ifdef WIN_DRAG
    NSPoint currentLocation;
    NSPoint newOrigin;
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [self frame];
    
    currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    if( (newOrigin.y + windowFrame.size.height) > (NSMaxY(screenFrame) - [NSMenuView menuBarHeight]) ){
        // Prevent dragging into the menu bar area
	newOrigin.y = NSMaxY(screenFrame) - windowFrame.size.height - [NSMenuView menuBarHeight];
    }
    /*
    if (newOrigin.y < NSMinY(screenFrame)) {
        // Prevent dragging off bottom of screen
        newOrigin.y = NSMinY(screenFrame);
    }
    if (newOrigin.x < NSMinX(screenFrame)) {
        // Prevent dragging off left of screen
        newOrigin.x = NSMinX(screenFrame);
    }
    if (newOrigin.x > NSMaxX(screenFrame) - windowFrame.size.width) {
        // Prevent dragging off right of screen
        newOrigin.x = NSMaxX(screenFrame) - windowFrame.size.width;
    }
    */
    
    [self setFrameOrigin:newOrigin];
#endif
}

- (void) mouseDown:(NSEvent *)theEvent {	
#ifdef WIN_DRAG
    NSRect windowFrame = [self frame];
    
    // Get mouse location in global coordinates
    initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
    initialLocation.x -= windowFrame.origin.x;
    initialLocation.y -= windowFrame.origin.y;
#endif
	[[self delegate] endAlertPanel:self];	
}

- (BOOL) canBecomeKeyWindow {
    return NO;
}

- (BOOL) canBecomeMainWindow {
	return NO;	
}


- (IBAction) fadeAndClose:(id)sender {
	[[NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(fadeOut:) userInfo:nil repeats:YES] retain];
}

- (void) fadeOut:(NSTimer *) theTimer {
	if ([self alphaValue] > 0.0) {
        // If window is still partially opaque, reduce its opacity.
        [self setAlphaValue:[self alphaValue] - 0.06];
    } else {
        // Otherwise, if window is completely transparent, destroy the timer and close the window.
        [theTimer invalidate];
        [theTimer release];
        theTimer = nil;
        
        [self close];
    }	
}
@end
