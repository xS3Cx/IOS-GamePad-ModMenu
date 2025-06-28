//
//  Menu.h
//  ModMenu
//
//  Created by Joey on 3/14/19.
//  Copyright © 2019 Joey. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "KittyMemory/MemoryPatch.hpp"
#import "SCLAlertView/SCLAlertView.h"

#import <vector>
#import <initializer_list>

@class OffsetSwitch;
@class TextFieldSwitch;
@class SliderSwitch;
@class Switches;

@interface Menu : UIView

-(id)initWithTitle:(NSString *)title_ titleColor:(UIColor *)titleColor_ titleFont:(NSString *)titleFont_ credits:(NSString *)credits_ headerColor:(UIColor *)headerColor_ switchOffColor:(UIColor *)switchOffColor_ switchOnColor:(UIColor *)switchOnColor_ switchTitleFont:(NSString *)switchTitleFont_ switchTitleColor:(UIColor *)switchTitleColor_ infoButtonColor:(UIColor *)infoButtonColor_ maxVisibleSwitches:(int)maxVisibleSwitches_ menuWidth:(CGFloat )menuWidth_ menuIcon:(NSString *)menuIconBase64_ menuButton:(NSString *)menuButtonBase64_ subMenuNames:(NSArray *)subMenuNames_;
-(void)setFrameworkName:(const char *)name_;
-(const char *)getFrameworkName;

-(void)showMenuButton;
-(void)addSwitchToMenu:(id)switch_;
-(void)addSwitchToSubMenu:(id)switch_ subMenuIndex:(NSInteger)subMenuIndex;
-(void)showPopup:(NSString *)title_ description:(NSString *)description_;

@end

@interface OffsetSwitch : UIButton {
	NSString *preferencesKey;
	NSString *description;
    UILabel *switchLabel;
    std::vector<uint64_t> patchOffsets;
    std::vector<std::string> patchBytes;
    std::vector<uint64_t> unpatchOffsets;
    std::vector<std::string> unpatchBytes;
}

- (id)initHackNamed:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::vector<uint64_t>)patchOffsets_ patchBytes:(std::vector<std::string>)patchBytes_
    unpatchOffsets:(std::vector<uint64_t>)unpatchOffsets_ unpatchBytes:(std::vector<std::string>)unpatchBytes_;
-(void)showInfo:(UIGestureRecognizer *)gestureRec;

-(NSString *)getPreferencesKey;
-(NSString *)getDescription;
- (std::vector<MemoryPatch>)getMemoryPatches;
- (std::vector<MemoryPatch>)getUnpatchMemoryPatches;

@end

@interface TextFieldSwitch : OffsetSwitch<UITextFieldDelegate> {
    UITextField *textfieldValue;
    UIView *customKeyboard;
    NSArray *keyboardButtons;
    NSInteger selectedKeyIndex;
    BOOL isKeyboardVisible;
    NSString *switchValueKey;
}

- (id)initTextfieldNamed:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_;
- (void)showKeyboard;
- (void)hideKeyboard;
- (NSString *)getSwitchValueKey;
- (UITextField *)getTextField;
- (BOOL)isKeyboardVisible;

@end

@interface SliderSwitch : TextFieldSwitch

- (id)initSliderNamed:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_;

@end


@interface Switches : UIButton

-(void)addSwitch:(NSString *)hackName_ description:(NSString *)description_;

// Universal methods to add switches to sub-menu by name
- (void)addOffsetSwitchToSubMenuByName:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::initializer_list<uint64_t>)patchOffsets_ patchBytes:(std::initializer_list<std::string>)patchBytes_
    unpatchOffsets:(std::initializer_list<uint64_t>)unpatchOffsets_ unpatchBytes:(std::initializer_list<std::string>)unpatchBytes_
    subMenuName:(NSString *)subMenuName_;

- (void)addTextfieldSwitchToSubMenuByName:(NSString *)hackName_ description:(NSString *)description_ 
    inputBorderColor:(UIColor *)inputBorderColor_ subMenuName:(NSString *)subMenuName_;

- (void)addSliderSwitchToSubMenuByName:(NSString *)hackName_ description:(NSString *)description_ 
    minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_
    subMenuName:(NSString *)subMenuName_;

// New method for switches that don't use patching (like light bar controls)
- (void)addSimpleSwitchToSubMenuByName:(NSString *)hackName_ description:(NSString *)description_ 
    subMenuName:(NSString *)subMenuName_;

- (NSString *)getValueFromSwitch:(NSString *)name;
-(bool)isSwitchOn:(NSString *)switchName;

@end
