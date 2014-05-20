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

@interface SBLockScreenView : UIView
- (void)scrollToPage:(long long)arg1 animated:(BOOL)arg2;
@end

SBLockScreenScrollView* wind;
UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
SBLockScreenView* sbLSView;
int height = [[UIScreen mainScreen] bounds].size.height;
int width = [[UIScreen mainScreen] bounds].size.width;
NS_INLINE CGFloat calc(CGFloat percent) { return percent * height; }

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

	wind.scrollEnabled = NO;

	[wind addSubview:button];

}

%new
-(void)unlock {
	[sbLSView scrollToPage:0 animated:YES];
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