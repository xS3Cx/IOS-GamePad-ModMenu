THEOS_DEVICE_IP = 192.168.0.104 # install to device from pc
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

# 0 to treat warnings as errors, 1 otherwise.
IGNORE_WARNINGS=1

# 0 to compile for rootful jailbreaks, 1 otherwise.
ROOTLESS = 1

ifeq ($(ROOTLESS), 1)
THEOS_PACKAGE_SCHEME = rootless
endif 


# only set this  to 1 if you are on mobile theos
# assuming you have an sdk at your theos sdks directory
# this will include c++ headers and other needed headers for your project so you don't need to manually include them or something like that
# if some c++ headers are still missing in your sdk like "initializer_list" then manually copy them to your c++ headers directory and not your project folder
# for example in my case c++ headers directory is located at /private/var/theos/sdks/iPhoneOS11.2.sdk/usr/include/c++/4.2.1/
# please note, do not include c++ headers in your theos includes to enable c++ which is a ghetto solution and use this approach instead
MOBILE_THEOS=0
ifeq ($(MOBILE_THEOS),1)
  # path to your sdk
  SDK_PATH = $(THEOS)/sdks/iPhoneOS16.5.sdk/
  $(info ===> Setting SYSROOT to $(SDK_PATH)...)
  SYSROOT = $(SDK_PATH)
else
  TARGET = iphone:clang:latest:14.0
endif


## Common frameworks ##
PROJ_COMMON_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText

## source files ##
KITTYMEMORY_SRC = $(wildcard KittyMemory/*.cpp)
SCLALERTVIEW_SRC =  $(wildcard SCLAlertView/*.m)
MENU_SRC = Menu.mm

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GameFusion

GameFusion_CFLAGS = -fobjc-arc -I.
GameFusion_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG -I.

ifeq ($(IGNORE_WARNINGS),1)
  GameFusion_CFLAGS += -w
  GameFusion_CCFLAGS += -w
endif


GameFusion_FILES = GameFusion.xm $(MENU_SRC) $(KITTYMEMORY_SRC) $(SCLALERTVIEW_SRC) $(wildcard *.m) $(wildcard *.mm) $(wildcard */*.m) $(wildcard GameFusion/*.xm) $(wildcard GameFusion/*.m) $(wildcard GameFusion/*.mm) $(wildcard */*.mm) $(wildcard */*.cpp)

GameFusion_LIBRARIES += substrate

GameFusion_OBJ_FILES = DobbyHook/libdobby.a



GameFusion_FRAMEWORKS = $(PROJ_COMMON_FRAMEWORKS) SpriteKit
# GO_EASY_ON_ME = 1

include $(THEOS_MAKE_PATH)/tweak.mk

internal-package-check::
	@chmod 777 versionCheck.sh # Give permission to script 	
	@./versionCheck.sh # Script to verify template's current version

after-install::
	install.exec "killall -9  || :"
