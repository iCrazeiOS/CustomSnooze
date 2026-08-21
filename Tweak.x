#import <Foundation/Foundation.h>
#import <rootless.h>

static NSDictionary *prefs;
static BOOL tweakEnabled = YES;
static int alarmDuration = 9;
static int bedtimeDuration = 10;

%hook MTUserDefaults
-(NSInteger)integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue {
	if ([key isEqualToString:@"MTAlarmSnoozeDuration"]) {
		return alarmDuration;
	}
	if ([key isEqualToString:@"MTBedtimeSnoozeDuration"]) {
		return bedtimeDuration;
	}
	return %orig;
}
%end

static void loadPrefs() {
	prefs = [NSDictionary dictionaryWithContentsOfFile:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.icraze.customsnoozeprefs.plist")];
	tweakEnabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
	alarmDuration = prefs[@"alarmDuration"] ? [prefs[@"alarmDuration"] intValue] : 9;
	bedtimeDuration = prefs[@"bedtimeDuration"] ? [prefs[@"bedtimeDuration"] intValue] : 10;
}

%ctor {
	loadPrefs();
	if (!tweakEnabled) return;

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.icraze.customsnoozeprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	%init;
}
