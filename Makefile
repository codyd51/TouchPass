ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = TouchPass
TouchPass_FILES = Tweak.xm
TouchPass_FRAMEWORKS = UIKit QuartzCore CoreGraphics
TouchPass_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
