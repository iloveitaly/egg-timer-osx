/* AlertPanelController.h created by Esteban Uribe on Sun 18-Aug-2002 */

#import <Cocoa/Cocoa.h>
#import "Reminder.h"

@interface AlertPanelController : NSObject {
	IBOutlet NSWindow *oFloatingAlert;

	NSTimer *_soundRepeatTimer;
	unsigned char _repeat;
	NSSound *_soundPlayer;
	Reminder *_reminder;
	NSString *_message;
	BOOL _panelToFront;
}

+ (id) alertPanelWithReminder:(Reminder *)r panelToFront:(BOOL)panelToFront;

- (id) initWithReminder:(Reminder *)r panelToFront:(BOOL)panelToFront;

- (IBAction) endAlertPanel:(id)sender;

- (Reminder *) reminderObject;
- (NSString *) title;
- (NSString *) message;
- (NSString *) dateString;

// Sound playing functionality
- (void) playSound;
- (void) updateSoundStatus;
- (void) stopSound;
@end
