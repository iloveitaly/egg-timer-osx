/*
"The software binary and source code are provided as is without any
warranty. Use at your own risk. You may freely copy and adapt the software
on the condition that you do not in any way gain financially from doing so."
*/

#import "ReminderController.h"
#import "Reminder.h"
#import "AlertPanelController.h"
#import "ConfigurationSheetController.h"
#import "MessageTextView.h"
#import "ETPreferenceController.h"
#import "ETPreferences.h"
#import "NSSound+SoundList.h"

#define kEditReminderSelector @selector(editReminder:)
#define kDeleteReminderSelector @selector(deleteSelectedReminder:)
#define kStopReminderSelector @selector(cancelSelectedReminder:)
#define kResetReminderSelector @selector(resetSelectedReminder:)
/*
EGSingleHourString = "hour"
EGMultipleHoursString = "hours"
EGSingleMinuteString = "minute"
EGMultipleMinutesString = "minutes"
EGSingleSecondString = "second"
EGMultipleSecondsString = "seconds"
*/
#define kEGRemindMeAtString @"EGRemindMeAtString"
#define kEGRemindMeInString @"EGRemindMeInString"

#define TIME_TO_SECONDS(h,m,s) ((h*3600) + (m*60) + s)

@implementation ReminderController

- (id) init {
	if ((self = [super init]) != nil) {
		reminderArray = [[NSMutableArray alloc] init];   
		toolbaritems = [[NSMutableDictionary alloc] init];
		defaultitems = [[NSMutableArray alloc] init];
		
		// Load saved reminders
		NSArray *loadedReminders = PREF_KEY_VALUE(ETSavedReminders);
		if(!isEmpty(loadedReminders)) {
			NSEnumerator *enumerator = [loadedReminders objectEnumerator];
			Reminder *loadedReminder;
			id object;
			
			while(object = [enumerator nextObject]) {
				loadedReminder = [NSKeyedUnarchiver unarchiveObjectWithData:object];
				
				if([loadedReminder active] && [loadedReminder alerted]) {
					if([loadedReminder repeats])
						[loadedReminder reset];
					else
						[loadedReminder cancel];
				}
				
				[reminderArray addObject:loadedReminder];
			}
		}
			
		if([reminderArray count]) {
			savedReminders = [[NSMutableArray alloc] initWithArray:reminderArray];
		} else {
			savedReminders = [[NSMutableArray alloc] init];
		}
	}
	
	return self;
}

- (void) awakeFromNib {
    [self setupSoundList];
	
	//Who wants the egg as the mini-window?
	//NSImage *miniwindowImage;
	//miniwindowImage = [[NSImage alloc] initWithContentsOfFile:@"eggtimer.icns"];
	//[oMainWindow setMiniwindowImage:miniwindowImage];
	
	// Table setup
    [remindersTable setAction:@selector(updateControls)];
	[remindersTable setDoubleAction:@selector(editReminderFromTable)];
	
	// Misc. Control setup
    [remindMeRadioMatrix setRefusesFirstResponder:YES];
    [repeatCheckbox setRefusesFirstResponder:YES];
    [playSoundCheckbox setRefusesFirstResponder:YES];
    [remindMeRadioMatrix selectCell:[remindMeRadioMatrix cellWithTag:0]];
	
	[repeatCheckbox setState:NSOffState];
	[playSoundCheckbox setState:NSOnState];
	[soundChoicePopup setEnabled:YES];
	[repeatSoundPopup setEnabled:YES];
	
    [hourTextField setDelegate:self];
	[minuteTextField setDelegate:self];
	[secondTextField setDelegate:self];
	
	// Setup toolbar items
    [self toolbarAddItemWithLabel:@"Add Reminder" toolTip:@"Add Reminder" image:[NSImage imageNamed:@"add"] enable:YES target:self action:@selector(addReminder:)];
    [defaultitems addObject:@"Add Reminder"];
	[addMenu setAction:@selector(configureReminder:)];
	[addMenu setTarget:configurationController];
	
    [self toolbarAddItemWithLabel:@"Edit Reminder" toolTip:@"Edit/Replace Reminder" image:[NSImage imageNamed:@"edit"] enable:YES target:self action:nil];
    [defaultitems addObject:@"Edit Reminder"];
	[editMenu setAction:nil];
	[editMenu setTarget:self];

    [self toolbarAddItemWithLabel:@"Delete Reminder" toolTip:@"Delete Reminder" image:[NSImage imageNamed:@"remove"] enable:YES target:self action:nil];
    [defaultitems addObject:@"Delete Reminder"];
   	[deleteMenu setAction:nil];
	[deleteMenu setTarget:self];

    [self toolbarAddItemWithLabel:NSToolbarFlexibleSpaceItemIdentifier toolTip:NSToolbarFlexibleSpaceItemIdentifier image:nil enable:YES target:self action:nil];
    [defaultitems addObject:NSToolbarFlexibleSpaceItemIdentifier];
    
    [self toolbarAddItemWithLabel:@"Stop" toolTip:@"Stop" image:[NSImage imageNamed:@"suspend"] enable:YES target:self action:nil];
    [defaultitems addObject:@"Stop"];
	[stopMenu setAction:nil];
	[stopMenu setTarget:self];
	
	// Create & Setup the toolbar
    toolbar = [[NSToolbar alloc] initWithIdentifier:@"eggtimer"];
    [toolbar setDelegate:self];
	[oMainWindow setToolbar:toolbar];
	
	//[toolbar setAllowsUserCustomization:NO];
	//[toolbar setAutosavesConfiguration:NO];

    [secondStepper setEnabled:NO];
    [secondTextField setEnabled:NO];
    
	[oMainWindow setExcludedFromWindowsMenu:YES];
    [oMainWindow makeKeyAndOrderFront:nil];

	[self reloadData];
}

- (void) setupSoundList {
	[soundChoicePopup removeAllItems];
	[soundChoicePopup addItemsWithTitles:[NSSound availableSounds]];
}

- (void) reloadData {
	NSDate *date = [NSDate date];
	NSEnumerator *enumerator;
	id			  reminder;
	NSTimeInterval timeInterval = 0;
	
	//only update the visual stuff if the window is visible\
	//increases performance when window is closed
	if([oMainWindow isVisible]) {
		[todayTextField setStringValue:[date description]];
		[remindersTable reloadData];
	}

	enumerator = [reminderArray objectEnumerator];
	while ((reminder = [enumerator nextObject])) {
		if([reminder active] && ![reminder alerted]) {
			timeInterval = [[reminder dueDate] timeIntervalSinceNow];
			if(timeInterval <= 0) {
				[self reminderDue:reminder];
			}			
		}
	}
	
}

- (void) updateControls {
    Reminder *selectedReminder = [self selectedObject];
	if(!isEmpty(selectedReminder)) {
        [reminderSubjectText setStringValue:[selectedReminder subject]];
        [messageTextView setString:[selectedReminder message]];
		
        if([selectedReminder repeats]) {
            [repeatCheckbox setIntValue:YES];
        } else {
            [repeatCheckbox setIntValue:NO];
        }
    
        if([selectedReminder countdown]) {
            [remindMeRadioMatrix selectCell:[remindMeRadioMatrix cellWithTag:1]];
        } else {
            [remindMeRadioMatrix selectCell:[remindMeRadioMatrix cellWithTag:0]];
        }
    
		BOOL value = [selectedReminder playSound];
		[playSoundCheckbox setIntValue:value];
		[soundChoicePopup setEnabled:value];
		[repeatSoundPopup setEnabled:value];
		[repeatSoundTextField setEnabled:value];
        
        if([selectedReminder save])
			[saveReminderCheckbox setIntValue:YES];
        else
			[saveReminderCheckbox setIntValue:NO]; 
    }
}

- (void) updateToolbarItems {
	NSToolbarItem *editItem = [toolbaritems objectForKey:@"Edit Reminder"];
	NSToolbarItem *deleteItem = [toolbaritems objectForKey:@"Delete Reminder"];
	NSToolbarItem *stopItem = [toolbaritems objectForKey:@"Stop"];
	
	if(!isEmpty([self selectedObject])) {// we have a row selected
		Reminder *remind;
		[editItem setEnabled:YES];
		[editItem setAction:kEditReminderSelector];
		
		[deleteItem setEnabled:YES];
		[deleteItem setAction:kDeleteReminderSelector];
		
		remind = [self selectedObject];
		[stopItem setEnabled:YES];
		[stopItem setAction:([remind active]?kStopReminderSelector:kResetReminderSelector)];
		[stopItem setImage:[NSImage imageNamed:([remind active]?@"suspend":@"arrows")]];
		[stopItem setLabel:[remind active] ? @"Stop" : @"Reset"];
		
		[editMenu setAction:kEditReminderSelector];
		[deleteMenu setAction:kDeleteReminderSelector];
		[stopMenu setAction: ([remind active]?kStopReminderSelector:kResetReminderSelector)];
		[stopMenu setTitle: ([remind active]?@"Stop":@"Reset")];
	} else {//nothing selected
		[editItem setEnabled:NO];
		[editItem setAction:nil];
		
		[deleteItem setEnabled:NO];
		[deleteItem setAction:nil];
		
		[stopItem setEnabled:NO];
		[stopItem setAction:nil];
		[stopItem setImage:[NSImage imageNamed:@"suspend"]];
		[stopItem setLabel:@"Stop"];
		
		[editMenu setAction:nil];
		[deleteMenu setAction:nil];
		[stopMenu setAction:nil];
	}	
}

- (void) saveReminders {
    NSMutableArray *save = [NSMutableArray array];
    NSEnumerator *enumerator = [savedReminders objectEnumerator];
    id object;

    while(object = [enumerator nextObject]) {
        [save addObject:[NSKeyedArchiver archivedDataWithRootObject:object]];
    }

	PREF_SET_KEY_VALUE(ETSavedReminders, save);
	[(NSUserDefaultsController*)[NSUserDefaultsController sharedUserDefaultsController] save:self];
}

// NSApp Delegate Methods
#pragma mark NSApp Delegate Methods
- (void) applicationDidFinishLaunching:(NSNotification *)notification {   	    
    [oMainWindow makeKeyAndOrderFront:self];

	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reloadData) userInfo:nil repeats:YES];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return NO;
}

- (BOOL) applicationShouldTerminate:(NSApplication *)sender {
    if([reminderArray count]) {
        [self saveReminders];
        NSBeep();
		
		// Check to see if there is any active reminders left
		BOOL activeReminders = NO;
		int l = [reminderArray count];
		while(l--) {
			if([[reminderArray objectAtIndex:l] active]) {
				activeReminders = YES;
			}
		}
		
        if(!activeReminders || NSRunAlertPanel(@"EggTimer Warning", @"There are still reminders in the list.\nAre you sure you want to quit?", @"Quit", @"No", nil) == NSAlertDefaultReturn) {
			return YES;
		} else {
			return NO;	
		}

	}
	
    return YES;
}

// Action methods
#pragma mark Action Methods
- (BOOL) addReminder:(id)sender atIndex:(int)rowIndex {
    NSString *partOfDayString = nil, *soundName = nil;
    NSCalendarDate *calendarDate = nil;
    NSCalendarDate *today = nil;
    NSString 	   *todayString = nil;
    Reminder *aReminder;
    SEL aSelector;
    int hr, min, sec;
	long interval = 0L;
    BOOL repeats, playSound, countdown, shouldSave;
	unsigned char repeatSound;
		
    aSelector  = @selector(reminderDue:);
    repeats = (BOOL) [repeatCheckbox state];
	countdown = (BOOL) [[remindMeRadioMatrix selectedCell] tag];
    playSound = (BOOL) [playSoundCheckbox state];

    shouldSave = (BOOL) [saveReminderCheckbox state];
    soundName = playSound ? [soundChoicePopup titleOfSelectedItem] : @"";
	partOfDayString = [partOfDay titleOfSelectedItem];
	hr  = [hourStepper intValue];
    min = [minuteStepper intValue];
    sec = [secondStepper intValue];
	

	repeatSound = [[repeatSoundPopup titleOfSelectedItem] intValue];
	today = [NSCalendarDate calendarDate];

	if(hr != 0 || min != 0 || sec != 0) {
		unsigned hourOfDay = [today hourOfDay];
		unsigned time;
		
		// If we have a relative time timer
		if(countdown) {
			NSLog(@"today time: %@", [today description]);
			calendarDate = [today dateByAddingYears:0 months:0 days:0 hours:hr minutes:min seconds:sec];
			NSLog(@"countdown time: %@", [calendarDate description]);
			interval = TIME_TO_SECONDS(hr, min, sec);
		} else {
            //if hour is between 1 AM and 12PM then, time should be 1 - 12
            //if hour is between 1 PM and 12AM then, time should be 13 - 24
            //NSLog(@"hr: %d; day time: %@", hr, partOfDayString);
            if(([partOfDayString isEqualToString: @"PM"] && (hr >= 1 && hr < 12)) || ([partOfDayString isEqualToString: @"AM"] && hr == 12)) {
                time = hr + 12;
				
                if(time == 24)
					time = 0;
            } else {
                time = hr;
			}

            //NSLog(@"time: %d; hourOfday: %d", time, hourOfDay);

            NSAssert((time >= 0 && time <= 23), @"time is not between 1 and 24");

            if(hourOfDay<12 && time>=12) {
				todayString = [NSString stringWithFormat:@"%d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d %@", [today yearOfCommonEra], [today dayOfMonth], [today monthOfYear], hr,min,sec, partOfDayString];
                NSAssert(todayString != nil, @"hourOfDay<12 && time>12");
				//reminder time is due today.
			} else if(hourOfDay>12 && time<12) {
				todayString = [NSString stringWithFormat:@"%d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d %@", [today yearOfCommonEra], [today dayOfMonth]+1, [today monthOfYear], hr,min,sec, partOfDayString];
                NSAssert(todayString != nil, @"hourOfDay>12 && time<12");
				//reminder time is due tomorrow.
			}
            else if(hourOfDay == time) {
                unsigned minute= [today minuteOfHour];//, second = [today secondOfMinute];
                if(minute < min) {
                    todayString = [NSString stringWithFormat:@"%d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d %@", [today yearOfCommonEra], [today dayOfMonth], [today monthOfYear], hr,min,sec, partOfDayString];
                } else {
                    if(minute == min) {
                        int result;
                        NSBeep();
                        result = NSRunAlertPanel(@"EggTimer Warning",@"Can't set timer to go off right now!\nIf you set the current time as a reminder, the Reminder will be set for the next day.", @"Set", @"Cancel", nil);
                        if(result != NSOKButton) 
                            return NO;
                    }
					
                    todayString = [NSString stringWithFormat:@"%d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d %@", [today yearOfCommonEra], [today dayOfMonth]+1, [today monthOfYear], hr,min,sec, partOfDayString];
                    NSAssert(todayString != nil, @"todayString = [NSString stringWithFormat:@\"%d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d %@\", [today yearOfCommonEra], [today dayOfMonth]+1, [today monthOfYear], hr,min,sec, partOfDayString]; is nil");

                }
            }
			
			//current time is AM and reminder time is AM,
			//or current time is PM and reminder time is PM
			else if((hourOfDay<12 && time<12) || (hourOfDay>12 && time>12)) {
				if(hourOfDay < time) {
					todayString = [NSString stringWithFormat:@"%d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d %@", [today yearOfCommonEra], [today dayOfMonth], [today monthOfYear], hr,min,sec, partOfDayString];
                    NSAssert(todayString != nil, @"hourOfDay < time");
					//reminder due today
				} else if(hourOfDay > time) {
					todayString = [NSString stringWithFormat:@"%d-%0.2d-%0.2d %0.2d:%0.2d:%0.2d %@", [today yearOfCommonEra], [today dayOfMonth]+1, [today monthOfYear], hr,min,sec, partOfDayString];
                    NSAssert(todayString != nil, @"hourOfDay > time");
					//reminder due tomorrow
				}
            }
//            else NSLog(@"time: %d; hourOfday: %d", time, hourOfDay);

			calendarDate = [NSCalendarDate dateWithString:todayString calendarFormat:@"%Y-%d-%m %I:%M:%S %p"];
		}
		
		if(calendarDate) {
            aReminder = [[Reminder alloc] initWithCalendarDate:calendarDate repeats:repeats countdown:interval sound:soundName repeatSound:repeatSound save:shouldSave subject:[reminderSubjectText stringValue] message:[[messageTextView string] copy] active:YES alerted:NO];
			[aReminder setPlaySound:playSound];
			[aReminder setActive:YES];
			
			if(rowIndex > -1) {
				//we want to keep the index because we dont want things jumping around when we are editing them
				[oController insertObject:aReminder atArrangedObjectIndex:rowIndex];
				[oController setSelectedObjects:[NSArray arrayWithObject:aReminder]];
			} else {
				[oController addObject:aReminder];
				[oController setSelectedObjects:[NSArray arrayWithObject:aReminder]];
			}
	
			[aReminder release];
			return YES;
		} else {
            NSBeep();
            NSRunAlertPanel(@"EggTimer Error", @"Calendar date for Reminder is nil.  Unable to add Reminder.", @"OK", nil, nil);
        }
	} else {
		NSBeep();
		NSRunAlertPanel(@"EggTimer Warning",@"Countdown time must be greater than zero!", @"OK", nil, nil);
        return NO;
	}
	
	return YES;
}

- (void) editReminderFromTable {
	if(isEmpty([self selectedObject])) {
		NSBeep();
		return;
	}
	
	[self editReminder:nil];
}

- (void) addReminder:(NSToolbarItem*)item {
	edit = NO;

	[remindMeRadioMatrix setSelectionFrom:0 to:0 anchor:0 highlight:YES];
	[self changeReminderKind:remindMeRadioMatrix];
	
	// clear the message fields for a new object
	[reminderSubjectText setStringValue:@""];
	[messageTextView setString:@""];
	
	[configurationController setEdit:edit];
	[configurationController configureReminder:self];
}

- (void) editReminder:(NSToolbarItem*)item {
	edit = YES;
	Reminder *reminder = [self selectedObject];
	int value = [reminder countdown] ? 1 :  0;
	[remindMeRadioMatrix setSelectionFrom:value to:value anchor:0 highlight:YES];
	
	//add current time to the reminder.
    [configurationController setEdit:edit];
    [configurationController configureReminder:self];
}

- (void) cancelReminder:(Reminder *)aReminder {
    [aReminder cancel];
    [self updateControls];
	[self updateToolbarItems];
}

- (void) cancelSelectedReminder:(id)sender {
	NSArray *selection = [oController selectedObjects];
	
	if(isEmpty(selection)) {
		NSBeep();
		return;
	}
	
    NSEnumerator *enumerator = [selection objectEnumerator];
    Reminder *reminder;

    NSBeep();
    int result = NSRunAlertPanel(@"Stop Reminders", @"Are you sure you want to stop the selected items?", @"Stop", @"Cancel", nil);
    if(result == NSOKButton) {
		while(reminder = [enumerator nextObject]) {
			[self cancelReminder:reminder];
		}
    }
}

- (void) resetSelectedReminder:(id)sender {
	NSArray *selection = [oController selectedObjects];
	
	if(isEmpty(selection)) {
		NSBeep();
		return;
	}
	
    NSEnumerator *enumerator = [selection objectEnumerator];
    Reminder *reminder;

	//NSBeep();
    int result = NSRunAlertPanel(@"Reset Reminders", @"Are you sure you want to reset the selected items?", @"Reset", @"Cancel", nil);
    if(result == NSOKButton) {
		while(reminder = [enumerator nextObject]) {
			[self resetReminder:reminder];
		}
    }
}

- (void) resetReminder:(Reminder *)aReminder {
    [aReminder reset];
	
	// Update the toolbar items if there was a selection
	if(!isEmpty([self selectedObject])) {	
		[self updateToolbarItems];
	}
}

- (void) deleteReminder:(Reminder *)aReminder {
	[oController removeObject:aReminder];
}

- (void) deleteSelectedReminder:(id)sender {
	if(NSRunAlertPanel(@"EggTimer Warning", @"Are you sure you want to delete the selected items?", @"Delete", @"Cancel", nil) == NSOKButton) {
		[oController remove:self];
	}	
}

- (IBAction) reminderDue:(id)reminder {
	[reminder setAlerted:YES];
	[NSApp requestUserAttention:NSInformationalRequest];
	[AlertPanelController alertPanelWithReminder:reminder panelToFront:YES];
}

- (BOOL) replaceReminder:(id)sender {
    Reminder *aReminder = [self selectedObject];
	int selectedRow = [remindersTable selectedRow];
	
	if(!isEmpty(aReminder)) {
		[self addReminder:self atIndex:selectedRow];
		[self deleteReminder:aReminder];
		[oController setSelectionIndex:selectedRow];
		[self updateControls];
		
		return YES;
	} else {
		NSBeep();
		NSRunAlertPanel(@"EggTimer Warning",@"Nothing to replace!", @"OK", nil, nil);
		return NO;
	}
}

- (void) showWindow:(id)sender {
    [oMainWindow makeKeyAndOrderFront:self];
}

- (IBAction) openPreferences:(id)sender {
	if(!_preferenceController) {
		_preferenceController = [ETPreferenceController new];
	}
	
	[_preferenceController showWindow:self];
}

// NSToolbar Delegate Methods
#pragma mark NSToolBar Delegates
- (void) toolbarAddItemWithLabel:(NSString *)label toolTip:(NSString *)tip image:(NSImage*)img enable:(BOOL)enable target:(id)target action:(SEL)select {
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:label];
    
    [item setPaletteLabel:label];
    [item setLabel:label];
    [item setToolTip:tip];
    [item setImage:img];
    [item setEnabled:enable];
    [item setTarget:target];
    [item setAction:select];
    
    [toolbaritems setObject:item forKey:label];
    
    [item release];
}

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [toolbaritems objectForKey:itemIdentifier];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    return defaultitems;
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return defaultitems;
}

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification {
	if([aNotification object] == remindersTable) {
		[self updateToolbarItems];
	}
}

- (void) takeIntValueFrom:(id)sender {
	//NSLog(@"Take int! %@", sender);
    int hr, min, sec;
	unsigned int _hval = 12, _mval = 59, _sval = 59;

    if([sender isEqual:hourStepper]) {
		[hourTextField setIntValue:[hourStepper intValue]];
		[[configurationController window] endEditingFor:hourTextField];
    } else if([sender isEqual:minuteStepper]) {
		[minuteTextField setIntValue:[minuteStepper intValue]];
		[[configurationController window] endEditingFor:minuteTextField];

    } else if([sender isEqual: secondStepper]) {
        [secondTextField setIntValue:[secondStepper intValue]];
		[[configurationController window] endEditingFor:secondTextField];

	} else if([sender isEqual: hourTextField]) {
        hr = [hourTextField intValue];
        if(hr < _hval && hr > -1) {
			[hourTextField setIntValue:hr];
			[hourStepper setIntValue:hr];
		}
        if([[remindMeRadioMatrix selectedCell] tag] == 0) {
            if(hr < 1) hr = 1;
            if(hr > 12) hr = 12;

            [hourTextField setIntValue:hr];
            [hourStepper setIntValue:hr];
        }
        [hourTextField selectText:self];
	} else if([sender isEqual:minuteTextField]) {
        min = [minuteTextField intValue];
        if(min < _mval && min >-1) {
            [minuteTextField setIntValue:min];
			[minuteStepper setIntValue:min];
		}
        [minuteTextField selectText:self];
	} else if([sender isEqual:secondTextField]) {
        sec = [secondTextField intValue];

		if(sec < _sval && sec >-1) {
            [secondTextField setIntValue:sec];
        	[secondStepper setIntValue:sec];
 		}
        [secondTextField selectText:self];
	} else if([sender isEqual:playSoundCheckbox]) {
        BOOL value = [playSoundCheckbox intValue];
        [soundChoicePopup setEnabled:value];
        [repeatSoundPopup setEnabled:value];
        [repeatSoundTextField setEnabled:value];        
    }
}

- (IBAction) changeReminderKind:(id)sender {
    NSCalendarDate *theDate;
    unsigned char thour = 0, hour = 1, minute = 0, second = 0;

    if(sender == remindMeRadioMatrix) {
		if([[remindMeRadioMatrix selectedCell] tag] == 0) {// At a specified time
			NSNumberFormatter *formatter = [hourStepper formatter];
			
			[formatter setMaximum:[NSDecimalNumber decimalNumberWithString:@"12"]];
			[formatter setMinimum:[NSDecimalNumber decimalNumberWithString:@"01"]];

			[hourStepper setMaxValue:12];
			[hourStepper setMinValue:1];
			
			if(![hourTextField intValue])
				[hourTextField setIntValue:1];
			if([hourTextField intValue] > 12)
				[hourTextField  setIntValue:12];

			[partOfDay setEnabled:YES];
            [secondStepper setEnabled:NO];
            [secondTextField setEnabled:NO];

            if(edit == NO) {
                theDate = [NSCalendarDate calendarDate];
                thour = [theDate hourOfDay];
                minute = [theDate minuteOfHour];
            } else {
                theDate = [[self selectedObject] dueDate];
                thour = [theDate hourOfDay];
                minute = [theDate minuteOfHour];
            }

            [partOfDay setTitle:(thour <= 11)?@"AM":@"PM"];

            if(thour > 12) {
				hour = thour-12;
			} else if(thour <= 12 && thour != 0){
				hour = thour;
            } else if(thour == 0) {
				hour = 12;
			}

            [hourStepper setIntValue:hour];
            [hourTextField setIntValue:hour];
            [minuteStepper setIntValue:minute];
            [minuteTextField setIntValue:minute];
            [secondStepper setIntValue:0];
            [secondTextField setIntValue:0];
        } else {// Remind me in was selected
            NSNumberFormatter *formatter = [hourTextField formatter];
            Reminder *reminder = [self selectedObject];

            //NSLog(@"remind me in");
            if (!isEmpty(reminder)) {
                if([reminder countdown] == 0)
					edit = NO;
            }

            [partOfDay setEnabled:NO];
            [formatter setMaximum:[NSDecimalNumber decimalNumberWithString:@"23"]];
            [formatter setMinimum:[NSDecimalNumber decimalNumberWithString:@"0"]];
			
            if(edit == NO) {
                hour = 0;
                minute = 0;
                second = 0;
            } else {
                [Reminder convertSecondsToTime:[reminder countdown] :&hour :&minute :&second];
            }

            [hourStepper setMaxValue:23];
            [hourStepper setMinValue:0];
			
            [hourStepper setIntValue:hour];
            [hourTextField setIntValue:hour];
            [minuteStepper setIntValue:minute];
            [minuteTextField setIntValue:minute];
            [secondStepper setIntValue:second];
            [secondTextField setIntValue:second];

            [secondStepper setEnabled:YES];
            [secondTextField setEnabled:YES];
        }
    }
}

- (void) insertObject:(Reminder *)ref inReminderArrayAtIndex:(unsigned int)index {
	if([ref save]) {
		[savedReminders addObject:ref];
	}
	
	[reminderArray insertObject:ref atIndex:index];
	[self saveReminders];
}

- (void)removeObjectFromReminderArrayAtIndex:(unsigned int)index {	
	Reminder *target = [reminderArray objectAtIndex:index];
	if([target save]) {
		[savedReminders removeObject:target];
	}
	
	[reminderArray removeObjectAtIndex:index];
	[self saveReminders];
}

- (NSMutableArray *) reminderArray {
	return reminderArray;
}

- (Reminder *) selectedObject {
	NSArray *sel = [oController selectedObjects];
	
	if(isEmpty(sel) || [sel count] < 1)
		return nil;
	
	return [sel objectAtIndex:0];
}
@end
