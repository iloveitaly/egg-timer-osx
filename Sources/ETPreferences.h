/*
 *  Preferences.h
 *  EggTimer
 *
 *  Created by Michael Bianco on 10/3/06.
 *  Copyright 2006 Prosit Software. All rights reserved.
 *
 */

//macros for getting pref values
#define PREF_KEY_VALUE(x) [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:(x)]
#define PREF_KEY_BOOL(x) [(PREF_KEY_VALUE(x)) boolValue]
#define PREF_SET_KEY_VALUE(x, y) [[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:(y) forKey:(x)]
#define PREF_OBSERVE_VALUE(x, y) [[NSUserDefaultsController sharedUserDefaultsController] addObserver:y forKeyPath:x options:NSKeyValueObservingOptionOld context:nil];

#define ETSavedReminders @"SavedReminders"
#define ETOldNotificationStyle @"OldNotificationStyle"
