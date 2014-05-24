#import <UIKit/UIKit.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIButton.h>
#import <UIKit/UIScrollView.h>
#import <UIKit/UIAlertView.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UILabel.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIGraphics.h>
#import "substrate.h"

@interface SBLockScreenScrollView : UIScrollView
@end

@interface SBLockScreenViewController : NSObject
+(id)sharedInstance;
@end

@interface SBLockScreenManager : NSObject
+(id)sharedInstance;
-(BOOL)attemptUnlockWithPasscode:(id)fp8;
@end

@interface SBLockScreenView : UIView
- (void)scrollToPage:(long long)arg1 animated:(BOOL)arg2;
@end

SBLockScreenScrollView* wind;
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
SBLockScreenView* sbLSView;
int height = [[UIScreen mainScreen] bounds].size.height;
int width = [[UIScreen mainScreen] bounds].size.width;
NS_INLINE CGFloat calc(CGFloat percent) { return percent * height; }
NSString *originalPasscode;
BOOL unlockedOnce = false;

%hook SBLockScreenView

-(void)setCustomSlideToUnlockText:(id)arg1 {
	%orig(@"tap to unlock");
	sbLSView = self;

	SBLockScreenViewController* lockViewController = MSHookIvar<SBLockScreenViewController*>([%c(SBLockScreenManager) sharedInstance], "_lockScreenViewController");
	SBLockScreenView* lockView = MSHookIvar<SBLockScreenView*>(lockViewController, "_view");
	wind = MSHookIvar<SBLockScreenScrollView*>(lockView, "_foregroundScrollView");

	button = [[UIButton alloc] init];
	[button addTarget:self action:@selector(unlock) forControlEvents:UIControlEventTouchUpInside];
	[button setTitle:@" " forState:UIControlStateNormal];
	//button.titleLabel.font = [UIFont systemFontOfSize: 20];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.frame = CGRectMake(0, 0, 150, 50);
	button.center = CGPointMake(160+width, calc(.862676056));

	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(unlockWithLongPress:)];
    	[button addGestureRecognizer:longPress];

	wind.scrollEnabled = NO;

	[wind addSubview:button];

}

%new
-(void)unlock {
	[UIView animateWithDuration:0.75 animations:^(void) {
		sbLSView scrollToPage:0 animated:YES];
	}];
}

%new
-(void)unlockWithLongPress:(UILongPressGestureRecognizer*)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		if (unlockedOnce) {
			[(SBLockScreenManager *)[objc_getClass("SBLockScreenManager") sharedInstance] attemptUnlockWithPasscode:[NSString stringWithFormat:@"%@", originalPasscode]];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unlock your device" message:@"Unlock your device each respring/reboot" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
}

%end

%hook SBDeviceLockController
-(BOOL)attemptDeviceUnlockWithPassword:(NSString *)passcode appRequested:(BOOL)requested {
	if (%orig) {
		originalPasscode = passcode;
		unlockedOnce = true;
	}

	return %orig;
}
%end

%hook SBFGlintyStringView

-(int)chevronStyle {
	return 0;
}

 -(void)setChevronStyle:(int) style {
	%orig(0);
}


%end
