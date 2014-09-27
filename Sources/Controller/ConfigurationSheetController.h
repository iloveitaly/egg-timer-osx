/*
"The software binary and source code are provided as is without any
warranty. Use at your own risk. You may freely copy and adapt the software
on the condition that you do not in any way gain financially from doing so."
*/

#import <Cocoa/Cocoa.h>

@class Reminder;

@interface ConfigurationSheetController : NSWindowController {
    IBOutlet id doneButton; //"OK" button
    IBOutlet id mainWindow;
    IBOutlet id reminderController;
    IBOutlet id addMenu;
    IBOutlet id editMenu;
    
    BOOL	edit;
	Reminder *_targetObject;
}

- (IBAction) configureReminder:(id)sender;
- (IBAction) doneConfiguring:(id)sender;

- (Reminder *) targetObject;
- (void) setTargetObject:(Reminder *)object;
- (void) setEdit:(BOOL)e;
- (BOOL) edit;

@end
