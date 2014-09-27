//
//  TransparentWindow.h
//  RoundedFloatingPanel
//
//  Created by Matt Gemmell on Thu Jan 08 2004.
//  <http://iratescotsman.com/>
//


#import <Cocoa/Cocoa.h>

@interface TransparentWindow : NSPanel { /* It is defined as a NSWindow in IB... I should fix that */
    NSPoint initialLocation;
}

- (IBAction) fadeAndClose:(id)sender;
- (void) fadeOut:(NSTimer *) theTimer;

@end
