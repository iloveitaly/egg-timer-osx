/* AlertPanelController.m created by Esteban Uribe on Sun 18-Aug-2002 */
#import "AlertPanelController.h"
#import "ReminderController.h"
#import "TransparentWindow.h"
#import "ETPreferences.h"

@implementation AlertPanelController

+ (id) alertPanelWithReminder:(Reminder *)r panelToFront:(BOOL)panelToFront {
	return [[AlertPanelController alloc] initWithReminder:r panelToFront:panelToFront];
}

- (id) initWithReminder:(Reminder *)r panelToFront:(BOOL)panelToFront {
	if(self = [self init]) {
		_reminder = [r retain];
		_message = [[_reminder message] retain];
		
		_repeat = [_reminder repeatSound];
		_panelToFront = panelToFront;
		
		if(![NSBundle loadNibNamed:@"AlertPanel" owner:self]) {
			[self autorelease];
			self = nil;
		}		
	}
	
	return self;
}

- (void) awakeFromNib {
	[oFloatingAlert center];
	[oFloatingAlert makeKeyAndOrderFront:self];
	
	[self playSound];
}

- (void) dealloc {
	[_message retain];
	[_reminder release];
	[super dealloc];
}

- (IBAction) endAlertPanel:(id)sender {
	if(sender == oFloatingAlert) {
        if([_reminder repeats]) {
            [(ReminderController *)[NSApp delegate] resetReminder:[self reminderObject]];
        } else {
            [(ReminderController *)[NSApp delegate] cancelReminder:[self reminderObject]];
		}
	}
	
	[(TransparentWindow*)oFloatingAlert fadeAndClose:self];
	
	[self stopSound];
	
	//not good form... but this is the last we get to reference self
	[self autorelease];
}

- (Reminder *) reminderObject {
	return _reminder;
}

- (NSString *) title {
	return isEmpty([_reminder subject]) ? @"Notification" : [_reminder subject];
}

- (NSString *) message {
	return [[[NSAttributedString alloc] initWithString:isEmpty([_reminder message]) ? @"" : [_reminder message]] autorelease];
}

- (NSString *) dateString {
	NSMutableString *dateString = [NSMutableString stringWithFormat:@"Due Time: %@", [_reminder description]];
    [dateString replaceOccurrencesOfString:@"\n" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [dateString length])];
	return dateString;
}

// Sound playing functionality
- (void) playSound {
	if(!isEmpty([_reminder sound])) {
		_soundPlayer = [NSSound soundNamed:[_reminder sound]];
		[_soundPlayer play];
		
		_soundRepeatTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateSoundStatus) userInfo:nil repeats:YES] retain];
	}
}

- (void) updateSoundStatus {
	if(![_soundPlayer isPlaying]) {
		if(_repeat > 1) {
			_repeat--;
			[_soundPlayer play];
		} else {
			[self stopSound];
		}
	}
}

- (void) stopSound {
	if(_soundRepeatTimer) {
		[_soundRepeatTimer invalidate];
		[_soundRepeatTimer release];
		_soundRepeatTimer = nil;
	}
}
@end
