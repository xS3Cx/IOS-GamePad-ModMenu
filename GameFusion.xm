#import "Macros.h"
#import "HVIcons/Heaven.h"
#import "GameFusion/Layout.h"
#import <GameController/GameController.h>
#import <GameController/GCColor.h>
#import "GameFusion/ControllerLight.h"
#import <mach-o/dyld.h>
#import "DobbyHook/dobby.h"

uint64_t getModuleBaseAddress(const char* moduleName) {
    uint64_t baseAddress = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char* name = _dyld_get_image_name(i);
        if (moduleName == NULL || strstr(name, moduleName) != NULL) {
            baseAddress = (uint64_t)_dyld_get_image_header(i);
            break;
        }
    }
    return baseAddress;
}

void setup() {
  
    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Light Red")
        description:NSSENCRYPT("Sets controller light bar to red")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Light Green")
        description:NSSENCRYPT("Sets controller light bar to green")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Light Blue")
        description:NSSENCRYPT("Sets controller light bar to blue")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Light Yellow")
        description:NSSENCRYPT("Sets controller light bar to yellow")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Light Purple")
        description:NSSENCRYPT("Sets controller light bar to purple")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Light Cyan")
        description:NSSENCRYPT("Sets controller light bar to cyan")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Light White")
        description:NSSENCRYPT("Sets controller light bar to white")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("RGB Cycle")
        description:NSSENCRYPT("Enables smooth RGB color cycling")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Police Lights")
        description:NSSENCRYPT("Red and blue lights alternating like police lights")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Breathing Red")
        description:NSSENCRYPT("Smooth breathing effect in red color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Breathing Green")
        description:NSSENCRYPT("Smooth breathing effect in green color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Breathing Blue")
        description:NSSENCRYPT("Smooth breathing effect in blue color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Breathing Purple")
        description:NSSENCRYPT("Smooth breathing effect in purple color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Rainbow Wave")
        description:NSSENCRYPT("Smooth rainbow wave effect")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Strobe Effect")
        description:NSSENCRYPT("Fast white strobe light effect")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Pulse Red")
        description:NSSENCRYPT("Fast pulsing effect in red color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Pulse Green")
        description:NSSENCRYPT("Fast pulsing effect in green color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Pulse Blue")
        description:NSSENCRYPT("Fast pulsing effect in blue color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Pulse Orange")
        description:NSSENCRYPT("Fast pulsing effect in orange color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Pulse Pink")
        description:NSSENCRYPT("Fast pulsing effect in pink color")
        subMenuName:NSSENCRYPT("GamePad Menu")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Blank Function 1")
        description:NSSENCRYPT("Blank function without patch")
        subMenuName:NSSENCRYPT("SUB MENU 1")];

    [switches addSimpleSwitchToSubMenuByName:NSSENCRYPT("Blank Function 2")
        description:NSSENCRYPT("Blank function without patch")
        subMenuName:NSSENCRYPT("SUB MENU 1")];

    [switches addOffsetSwitchToSubMenuByName:NSSENCRYPT("Test Function 3")
        description:NSSENCRYPT("Offset function with patch")
        patchOffsets:{0x100394E60, 0x100394da0}
        patchBytes:{"0x00f0271e", "0x08050011"}
        unpatchOffsets:{0x100394E60, 0x100394da0}
        unpatchBytes:{"0x0008211E", "0x68060034"}
        subMenuName:NSSENCRYPT("SUB MENU 1")];

    [switches addOffsetSwitchToSubMenuByName:NSSENCRYPT("Test Function 4")
        description:NSSENCRYPT("Offset function with patch")
        patchOffsets:{0x100394E60, 0x100394da0}
        patchBytes:{"0x00f0271e", "0x08050011"}
        unpatchOffsets:{0x100394E60, 0x100394da0}
        unpatchBytes:{"0x0008211E", "0x68060034"}
        subMenuName:NSSENCRYPT("SUB MENU 1")];

}

void setupMenu() {

  [menu setFrameworkName:NULL];

  NSArray *subMenuNames = @[NSSENCRYPT("SUB MENU 1"), NSSENCRYPT("GamePad Menu")];

  menu = [[Menu alloc]  
            initWithTitle:NSSENCRYPT("GameFusion")
            titleColor:[UIColor whiteColor]
            titleFont:NSSENCRYPT("ArialRoundedMTBold")
            credits:NSSENCRYPT("This Mod Menu has been made by andr, do not share this without proper credits and my permission. \n\nEnjoy!")
            headerColor:UIColorFromHex(0x0d0d0d)
            switchOffColor:UIColorFromHex(0x2e2f36)
            switchOnColor:UIColorFromHex(0x8674ef)
            switchTitleFont:NSSENCRYPT("ArialRoundedMTBold")
            switchTitleColor:[UIColor whiteColor]
            infoButtonColor:UIColorFromHex(0xC3B5E8)
            maxVisibleSwitches:5
            menuWidth:250
            menuIcon:@""
            menuButton:[Heaven HEAVEN_ICON]
            subMenuNames:subMenuNames];

    setup();

}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
  timer(3) {
    setupMenu();
  });
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}