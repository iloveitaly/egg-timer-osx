#import "messageTextView.h"
#import "ReminderController.h"

@implementation MessageTextView

- (void) doCommandBySelector:(SEL)aSelector {
	NSEvent *theEvent = [NSApp currentEvent];
	unichar keyDownCharacter = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	
	if(keyDownCharacter == NSTabCharacter) {
		[[self window] selectKeyViewFollowingView:self];
    } else if(keyDownCharacter == NSBackTabCharacter) {
		[[self window] selectPreviousKeyView:self];
	} else if (keyDownCharacter == NSEnterCharacter) {
		[button performKeyEquivalent:[NSEvent keyEventWithType:NSKeyDown location:NSMakePoint(0,0) modifierFlags:[button keyEquivalentModifierMask] timestamp:0 windowNumber:0 context:nil characters:[button keyEquivalent] charactersIgnoringModifiers:[button keyEquivalent] isARepeat:NO keyCode:0]];
	} else {
		//NSLog(@"selector name: %@", NSStringFromSelector(aSelector));
		[super doCommandBySelector:aSelector];	
	} 
}

- (BOOL) endEditing:(NSDictionary *)textObjectDict {
	return NO;
}

- (BOOL) acceptFirstResponder {
	return YES;
}
@end
