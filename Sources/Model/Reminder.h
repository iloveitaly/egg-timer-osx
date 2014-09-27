/* Reminder.h created by wjabi on Sat 17-Jan-1998 */
/* Reminder.h extensively modified by Esteban Uribe on Sun 18-Aug-2002 */
/*
"The software binary and source code are provided as is without any
warranty. Use at your own risk. You may freely copy and adapt the software
on the condition that you do not in any way gain financially from doing so."
*/

#import <AppKit/AppKit.h>

@interface Reminder : NSObject <NSCoding> {
	NSString       *_soundName;
	NSString       *_message;
	NSString       *_subject;
	NSCalendarDate *_dueDate;
	
	unsigned char  _repeatSound;
	unsigned long   _countdown;
	BOOL           _repeat;
	BOOL           _playSound;
	BOOL			_active;
	BOOL			_alerted;
	BOOL			_save;
	BOOL			_shouldSave;
}

+ (void) convertSecondsToTime:(unsigned long)totalSeconds :(unsigned char *)hrs :(unsigned char *)mins :(unsigned char *)secs;
+ (long) convertTimeToSeconds:(int) hr :(int)min :(int)sec;

- (id) initWithCalendarDate:(NSCalendarDate *)calendarDate repeats:(BOOL)repeats countdown:(long)interval sound:(NSString*)soundName repeatSound:(unsigned char)rSound save:(BOOL)save subject:(NSString *)subject message:(NSString *)message active:(BOOL)active alerted:(BOOL)alerted;
- (id) initWithCoder:(NSCoder *)coder;
- (void) encodeWithCoder:(NSCoder *)encoder;

- (void) setReminderWithCalendarDate:(NSCalendarDate *)calendarDate repeats:(BOOL)repeats countdown:(long)interval sound:(NSString*)soundName repeatSound:(unsigned char)rSound save:(BOOL)save subject:(NSString *)subject message:(NSString *)message;
- (void) remainingTime:(unsigned char *)hours minutes:(unsigned char *)minutes seconds:(unsigned char *)seconds timeOfDay:(NSString **)timeOfDay;

- (void) cancel;
- (void) reset;

// Getter & Setters

- (void)setSave:(BOOL)save;
- (BOOL)save;

- (void)setSound:(NSString*)Name;
- (NSString *)sound;

- (void) setRepeatSound:(unsigned char)r;
- (unsigned char) repeatSound;

- (void) setRepeats:(BOOL)r;
- (BOOL) repeats;

- (void) setPlaySound:(BOOL)p;
- (BOOL) playSound;

- (void) setActive:(BOOL)a;
- (BOOL) active;

- (void) setAlerted:(BOOL)a;
- (BOOL) alerted;

- (void) setMessage:(NSString *)m;
- (NSString *) message;

- (void) setSubject:(NSString *)s;
- (NSString *) subject;

- (void)setCountdown:(unsigned long)c;
- (unsigned long)countdown;

- (void) setDueDate:(NSCalendarDate *)d;
- (NSCalendarDate *) dueDate;

- (NSImage *) repeatsImage;
- (NSAttributedString *) when;
- (NSString *) reminder;
- (NSAttributedString *) formattedReminder;
@end
