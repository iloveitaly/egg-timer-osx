/* ReminderController */
/*
"The software binary and source code are provided as is without any
warranty. Use at your own risk. You may freely copy and adapt the software
on the condition that you do not in any way gain financially from doing so."
*/

#import <Cocoa/Cocoa.h>

@class Reminder, MessageTextView, ETPreferenceController;

@interface ReminderController : NSObject {
    IBOutlet id configurationController;
    IBOutlet id hourTextField;
	IBOutlet id	hourStepper;
    IBOutlet NSWindow *oMainWindow;
    IBOutlet id minuteTextField;
	IBOutlet id minuteStepper;
	IBOutlet id partOfDay;

    IBOutlet id playSoundCheckbox;
    IBOutlet NSTextView *messageTextView;
	IBOutlet NSTextField *reminderSubjectText;
    IBOutlet id remindMeRadioMatrix;
    IBOutlet NSTableView *remindersTable;
	IBOutlet id repeatCheckbox;
    IBOutlet id saveReminderCheckbox;
    IBOutlet id secondTextField;
    IBOutlet id secondStepper;
    IBOutlet id repeatSoundPopup;
    IBOutlet id repeatSoundTextField;
	IBOutlet NSMenuItem *addMenu;
	IBOutlet NSMenuItem *editMenu;
	IBOutlet NSMenuItem *deleteMenu;
	IBOutlet NSMenuItem *stopMenu;
	IBOutlet NSPopUpButton *soundChoicePopup;

	IBOutlet id todayTextField;
	IBOutlet NSArrayController *oController;
	
	ETPreferenceController *_preferenceController;
	
	// Toolbar variables
	NSToolbar	   	*toolbar;
    NSMutableDictionary *toolbaritems;
	NSMutableArray	*defaultitems;
	
    NSMutableArray 	*reminderArray;
    NSMutableArray	*savedReminders;
    
    BOOL			edit;
}

// NSApp Delegate Methods
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (BOOL)applicationShouldTerminate:(NSApplication *)sender;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication;

- (void) setupSoundList;

// NSToolbar Delegate Methods
- (void) toolbarAddItemWithLabel:(NSString *)label toolTip:(NSString *)tip image:(NSImage*)img enable:(BOOL)enable target:(id)target action:(SEL)select;
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;

// Action Methods
- (void) addReminder:(NSToolbarItem*)item;
- (void) editReminder:(NSToolbarItem*)item;

- (BOOL) addReminder:(id)sender atIndex:(int)rowIndex;

- (void) cancelReminder:(Reminder *)aReminder;
- (IBAction) cancelSelectedReminder:(id)sender;

- (void) deleteReminder:(Reminder *)aReminder;
- (IBAction)deleteSelectedReminder:(id)sender;

- (void)resetReminder:(Reminder *)aReminder;
- (IBAction)resetSelectedReminder:(id)sender;

- (IBAction) reminderDue:(id)sender;
- (BOOL) replaceReminder:(id)sender;
- (IBAction) changeReminderKind:(id)sender;

- (void) reloadData;

- (IBAction) showWindow:(id)sender;
- (IBAction) openPreferences:(id)sender;
- (IBAction) takeIntValueFrom:(id)sender;

- (void) takeIntValueFrom:(id)sender;
- (void) updateControls;
- (void) updateToolbarItems;
- (void) saveReminders;

- (NSMutableArray *) reminderArray;
- (Reminder *) selectedObject;
@end

