/* Reminder.m created by wjabi on Sat 17-Jan-1998 */
/*            modified by euribe on Sun 9-Sept-2001*/
/*            extensively modified by Esteban Uribe on Sun 18-Aug-2002 */
/*			  major modifications by Michael Bianco (svn.mabwebdesign.com) on 10/03/06 */
/*
"The software binary and source code are provided as is without any
warranty. Use at your own risk. You may freely copy and adapt the software
on the condition that you do not in any way gain financially from doing so."
*/

#import "Reminder.h"

@implementation Reminder
+ (void) convertSecondsToTime:(unsigned long)totalSeconds :(unsigned char *)hrs :(unsigned char *)mins :(unsigned char *)secs {
    *hrs = totalSeconds/3600;
    *mins = ((totalSeconds%3600)/60);
    *secs = ((totalSeconds%60));
}

+ (long) convertTimeToSeconds:(int) hr :(int)min :(int)sec {
	return (long) ((hr *3600) + (min * 60) + sec);
}

- (id) initWithCalendarDate:(NSCalendarDate *)calendarDate repeats:(BOOL)repeats countdown:(long)interval sound:(NSString*)soundName repeatSound:(unsigned char)rSound save:(BOOL)save subject:(NSString *)subject message:(NSString *)message active:(BOOL)active alerted:(BOOL)alerted {
	if(self = [self init]) {
		[self setReminderWithCalendarDate:calendarDate repeats:repeats countdown:interval sound:soundName repeatSound:rSound save:save subject:subject message:message];
        [self setPlaySound:!isEmpty(soundName)];
        [self setActive:active];
		[self setAlerted:alerted];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)coder {
	[self setSound:[coder decodeObject]];
	[self setMessage:[coder decodeObject]];
	[self setSubject:[coder decodeObject]];
	[self setDueDate:[[coder decodeObject] dateWithCalendarFormat:@"%Y-%m-%d %H:%M:%S %z" timeZone:nil]];
	
	//the bools
	[coder decodeValueOfObjCType:@encode(unsigned char) at:&_repeatSound];
	[coder decodeValueOfObjCType:@encode(unsigned long) at:&_countdown];
	[coder decodeValueOfObjCType:@encode(BOOL) at:&_repeat];
	[coder decodeValueOfObjCType:@encode(BOOL) at:&_playSound];
	[coder decodeValueOfObjCType:@encode(BOOL) at:&_active];
	[coder decodeValueOfObjCType:@encode(BOOL) at:&_alerted];
	[coder decodeValueOfObjCType:@encode(BOOL) at:&_save];
	[coder decodeValueOfObjCType:@encode(BOOL) at:&_shouldSave];
	
	return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_soundName];
	[encoder encodeObject:_message];
	[encoder encodeObject:_subject];
	[encoder encodeObject:_dueDate];
	
	//the bools
	[encoder encodeValueOfObjCType:@encode(unsigned char) at:&_repeatSound];
	[encoder encodeValueOfObjCType:@encode(unsigned long) at:&_countdown];
	[encoder encodeValueOfObjCType:@encode(BOOL) at:&_repeat];
	[encoder encodeValueOfObjCType:@encode(BOOL) at:&_playSound];
	[encoder encodeValueOfObjCType:@encode(BOOL) at:&_active];
	[encoder encodeValueOfObjCType:@encode(BOOL) at:&_alerted];
	[encoder encodeValueOfObjCType:@encode(BOOL) at:&_save];
	[encoder encodeValueOfObjCType:@encode(BOOL) at:&_shouldSave];
}

- (void) setReminderWithCalendarDate:(NSCalendarDate *)calendarDate repeats:(BOOL)repeats countdown:(long)interval sound:(NSString *)soundName repeatSound:(unsigned char)rSound save:(BOOL)save subject:(NSString *)subject message:(NSString *)message {
	[self setRepeats:repeats];
	[self setCountdown:interval];

	[self setRepeatSound:rSound];

	[self setSubject:subject];
	[self setMessage:message];

	[self setSave:save];

	[self setSound:soundName];
	[self setDueDate:calendarDate];
}

- (void) remainingTime:(unsigned char *)hours minutes:(unsigned char *)minutes seconds:(unsigned char *)seconds timeOfDay:(NSString **)timeOfDay {
	NSTimeInterval timeInterval = 0;
	NSCalendarDate *due = [self dueDate];

    if([self countdown] == 0) {
		*hours = [due hourOfDay];
		*minutes = [due minuteOfHour];
		*seconds = [due secondOfMinute];
		*timeOfDay = (*hours >= 12) ? @"PM" : @"AM";
		*hours = (*hours == 0)? 12: ((*hours > 13) ? (*hours - 12) : *hours);
    } else {
		timeInterval = [[self dueDate] timeIntervalSinceNow];
		
        if(timeInterval > 0) {
            [Reminder convertSecondsToTime:timeInterval :hours :minutes :seconds];
			*timeOfDay = nil;
            return;
		} else {
            *hours  = 0;
            *minutes = 0;
            *seconds = 0;
			*timeOfDay = @"AM";
		}
	}
}

- (void) dealloc {
	[_message release];
	[_subject release];
	[_soundName release];
	[_dueDate release];
	[super dealloc];
}

// Action Methods
#pragma mark Action Methods

- (void) cancel {
	[self setAlerted:YES];
	[self setActive:NO];
}

- (void) reset {
    NSCalendarDate *due = [self dueDate];
    NSCalendarDate *today = [NSCalendarDate date];
    NSTimeInterval offset = [due timeIntervalSinceNow];
    
    [self setActive:YES];
    [self setAlerted:NO];
		
	//NSLog(@"original date was: %@", due);
	if(![self countdown]) {
		if(offset < 0) {
			long day = [today dayOfMonth];

			if([due timeIntervalSince1970] < [today timeIntervalSince1970])
				day += 1;
			
			due = [[[NSCalendarDate alloc] initWithYear:[today yearOfCommonEra]
												  month:[today monthOfYear]
													day:day
												   hour:[due hourOfDay]
												 minute:[due minuteOfHour]
												 second:0
											   timeZone:[NSTimeZone localTimeZone]] autorelease];
		}
	} else {
		due = [today dateByAddingYears:0 months:0 days:0 hours:0 minutes:0 seconds:[self countdown]];
	}

	[self setDueDate:due];
}

- (NSString *) _countdownStringRepFromHours:(unsigned char)hours minutes:(unsigned char)minutes seconds:(unsigned char)seconds {
	NSMutableString *formattedTime = [NSMutableString string];
	
	if(hours > 0) {
		[formattedTime appendFormat:@"%d h", hours];

		if(minutes > 0)
			[formattedTime appendFormat:@", %d m", minutes];
		[formattedTime appendFormat:@", %d s", seconds];
	} else if(minutes > 0) {
		[formattedTime appendFormat:@"%d m", minutes];
		[formattedTime appendFormat:@", %d s", seconds];
	} else if(seconds > 0) {
		[formattedTime appendFormat:@"%d s", seconds];
	} else if(seconds == 0) {
		formattedTime = nil;
	}

	return formattedTime;
}

// Getter & Setters
#pragma mark Getter & Setters

- (void)setSave:(BOOL)save { _save = save; }
- (BOOL)save { return _save; }

- (void) setSound:(NSString*)name {
	[name retain];
	[_soundName release];
	_soundName = name;
}

- (NSString *) sound {
	return _soundName;
}

- (void) setRepeatSound:(unsigned char)t { _repeatSound = t; }
- (unsigned char) repeatSound { return _repeatSound; }

- (void) setRepeats:(BOOL)r { _repeat = r; }
- (BOOL) repeats { return _repeat; }

- (void) setPlaySound:(BOOL)p { _playSound = p; }
- (BOOL) playSound { return _playSound; }

- (void) setActive:(BOOL)a { _active = a; }
- (BOOL) active { return _active; }

- (void) setAlerted:(BOOL)a { _alerted = a; }
- (BOOL) alerted { return _alerted; }

- (void) setMessage:(NSString *)m {
	[m retain];
	[_message release];
	_message = m;
}

- (NSString *) message { return _message; }

- (void) setSubject:(NSString *)s  {
	[s retain];
	[_subject release];
	_subject = s;
}

- (NSString *) subject {
	return _subject;
}

- (void) setCountdown:(unsigned long)c { _countdown = c; }
- (unsigned long) countdown { return _countdown; }

- (void) setDueDate:(NSCalendarDate *)d {
	[d retain];
	[_dueDate release];
	_dueDate = d;
}

- (NSCalendarDate *) dueDate { return _dueDate; }

- (NSString *) description  {
	id formattedTime;
	NSString *timeOfDay;
    unsigned char hours = 0, minutes=0, seconds=0;

    if([self countdown]==NO) {
        NSString *calendarFormat;
		NSCalendarDate *due = [self dueDate];

        //if([self active] == YES) {
            int today = [[NSCalendarDate calendarDate] dayOfMonth], nextDay = [due dayOfMonth];
            if( today == nextDay )
                calendarFormat = @"Today\nat %I:%M:%S %p";
            else if (today < nextDay)
                calendarFormat = @"Tomorrow\nat %I:%M:%S %p";
            else if (today == nextDay + 1)
                calendarFormat = @"Yesterday\nat %I:%M:%S %p";
            else if (today > nextDay)
                calendarFormat = [due descriptionWithCalendarFormat:@"%a %m/%d/%y\nat %I:%M:%S %p"];
        //}
        //else calendarForat = @"(%I:%M:%S %p)?";

        formattedTime = [due descriptionWithCalendarFormat:calendarFormat];
	} else {
		if([self active] == YES) {
			NSString *partialdescription;
			[self remainingTime:&hours minutes:&minutes seconds:&seconds timeOfDay:&timeOfDay];

			partialdescription = [self _countdownStringRepFromHours:hours minutes:minutes seconds:seconds];
			if(partialdescription) formattedTime = [@"in " stringByAppendingString:partialdescription];
			else formattedTime = @"Due Now!";
		} else {
			unsigned long timeInterval = [self countdown];
			[Reminder convertSecondsToTime:timeInterval :&hours :&minutes :&seconds];
			
			formattedTime = [NSMutableString string];
			[formattedTime appendFormat:@"(%@)",[self _countdownStringRepFromHours:hours minutes:minutes seconds:seconds]];
		}
	}

	return formattedTime;
}

- (NSImage *) repeatsImage {
	return [self repeats] ? [NSImage imageNamed:@"small_green_check"] : [NSImage imageNamed:@"small_red_cross"];
}

- (NSAttributedString *) when {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:(([self repeats] && [self active])?[NSColor blueColor]:([self active]?[NSColor blackColor]:[NSColor redColor]))
													 forKey:NSForegroundColorAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:[self description] attributes:dict];
    return [attrString autorelease];
}

- (NSString *) reminder {
	return [NSString stringWithFormat:@"%@: %@", [self subject], [self message]];
}

- (NSAttributedString *) formattedReminder {
	NSFont *boldFont = [NSFont boldSystemFontOfSize:12], *normalFont = [NSFont systemFontOfSize:12];
	NSDictionary *boldFormatDict = [NSDictionary dictionaryWithObjectsAndKeys:boldFont, NSFontAttributeName, (([self repeats] && [self active])?[NSColor blueColor]:([self active]?[NSColor blackColor]:[NSColor redColor])), NSForegroundColorAttributeName, nil], *romanFormatDict = [NSDictionary dictionaryWithObjectsAndKeys:normalFont, NSFontAttributeName, (([self repeats] && [self active])?[NSColor blueColor]:([self active]?[NSColor blackColor]:[NSColor redColor])), NSForegroundColorAttributeName, nil];
	NSMutableAttributedString *composedAttrString = [[[NSMutableAttributedString alloc] init] autorelease];
	
	[composedAttrString appendAttributedString:[[[NSAttributedString alloc] initWithString:[self subject] attributes:boldFormatDict] autorelease]];
	[composedAttrString appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", [self message]] attributes:romanFormatDict] autorelease]];
	
	return composedAttrString;
}
@end
