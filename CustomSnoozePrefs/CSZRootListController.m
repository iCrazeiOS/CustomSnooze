#import "CSZRootListController.h"

@implementation CSZRootListController
-(void)loadView {
	[super loadView];
	// [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring)]];
}

// -(void)restartTimerDaemon {
// 	pid_t pid;

// 	char *killall_args[] = {"killall", "-9", "mobiletimerd", NULL};
// 	posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char * const *)killall_args, NULL);

// 	waitpid(pid, NULL, 0);

// 	char *launchctl_args[] = {"launchctl", "start", "com.apple.mobiletimerd", NULL};
// 	posix_spawn(&pid, ROOT_PATH("/bin/launchctl"), NULL, NULL, (char * const *)launchctl_args, NULL);
// }

-(NSString *)plistPathForFilename:(NSString *)filename {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", filename];
	return ROOT_PATH_NS_VAR(path);
}

-(id)readPreferenceValue:(PSSpecifier *)specifier {
	NSString *path = [self plistPathForFilename:specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSString *path = [self plistPathForFilename:specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
}

-(NSArray *)specifiers {
	if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	return _specifiers;
}

-(void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/iCrazeiOS/CustomSnooze"] options:@{} completionHandler:nil];
}

-(void)twitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://x.com/iCrazeiOS"] options:@{} completionHandler:nil];
}

-(void)paypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/iCrazeiOS/2.50"] options:@{} completionHandler:nil];
}

-(void)openTweakForSpecifier:(PSSpecifier *)specifier {
	NSString *bundleID = specifier.properties[@"bundleIdentifier"];

	// web depiction fallback
	NSString *url = [@"https://havoc.app/package/" stringByAppendingString:[[bundleID componentsSeparatedByString:@"."] lastObject]];

	UIApplication *app = [UIApplication sharedApplication];
	// sileo
	if ([app canOpenURL:[NSURL URLWithString:@"sileo://"]]) {
		url = [NSString stringWithFormat:@"sileo://package/%@", bundleID];
	}
	// zebra
	else if ([app canOpenURL:[NSURL URLWithString:@"zbra://"]]) {
		url = [NSString stringWithFormat:@"zbra://packages/%@?source=https://havoc.app", bundleID];
	}

	[app openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}
@end
