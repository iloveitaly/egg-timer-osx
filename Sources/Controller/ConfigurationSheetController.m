/*
"The software binary and source code are provided as is without any
warranty. Use at your own risk. You may freely copy and adapt the software
on the condition that you do not in any way gain financially from doing so."
*/

#import "ConfigurationSheetController.h"
#import "ReminderController.h"

@implementation ConfigurationSheetController

- (IBAction) configureReminder:(id)sender {
    [NSApp beginSheet:[self window] modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];

    if([sender isEqual:addMenu]) {
		edit = NO;
    } else if ([sender isEqual:editMenu]) {
		edit = YES;
    }
}

- (IBAction) doneConfiguring:(id)sender {
    BOOL stop = YES;
	
    if([sender isEqual:doneButton]) {
        [[self window] makeFirstResponder:sender];
		
		if([self edit] == NO) {
			stop = [reminderController addReminder:sender atIndex:-1];
		} else {
			stop = [reminderController replaceReminder:sender];
		}
    }
    
    if(stop == YES) {
		[[self window] orderOut:nil];
		[NSApp endSheet:[self window]];
    }
}

- (Reminder *) targetObject {
	return _targetObject;
}

- (void) setTargetObject:(Reminder *)object {
	[object retain];
	[_targetObject release];
	_targetObject = object;
}

// Whether or not the panel is editing a reminder
// if false then we are adding a new one
- (void) setEdit:(BOOL)e {
    edit = e;
}

- (BOOL)edit {
	return edit;
}

@end
