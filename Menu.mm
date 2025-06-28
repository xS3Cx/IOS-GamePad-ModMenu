//
//  Menu.m
//  ModMenu
//
//  Created by Joey on 3/14/19.
//  Copyright © 2019 Joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"
#import <objc/runtime.h>
#import "HVIcons/Heaven.h"
#import "SupportFile/NakanoYotsuba.h"
#import "GameFusion/GamepadInput.h"
#import "GameFusion/CustomNotification.h"
#import "GameFusion/ControllerLight.h"

@interface Menu ()

@property (assign, nonatomic) CGPoint lastMenuLocation;
@property (strong, nonatomic) UILabel *menuTitle;
@property (strong, nonatomic) UIView *header;
@property (strong, nonatomic) UIView *footer;
@property (assign, nonatomic) BOOL isMenuVisible;
@property (assign, nonatomic) NSInteger selectedSwitchIndex;
@property (strong, nonatomic) UIView *selectionIndicator;
@property (strong, nonatomic) UILabel *counterLabel;
@property (strong, nonatomic) NSArray *subMenus;
@property (assign, nonatomic) NSInteger currentMenuIndex;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) NSMutableArray *subMenuSwitches;
@property (strong, nonatomic) UILabel *leftTitleLabel;
@property (strong, nonatomic) UIImageView *infoIcon;

@end


@implementation Menu

NSUserDefaults *defaults;

UIScrollView *scrollView;
CGFloat menuWidth;
CGFloat scrollViewX;
NSString *credits;
UIColor *switchOnColor;
NSString *switchTitleFont;
UIColor *switchTitleColor;
UIColor *infoButtonColor;
NSString *menuIconBase64;
NSString *menuButtonBase64;
float scrollViewHeight = 0;
BOOL hasRestoredLastSession = false;
UIButton *menuButton;

const char *frameworkName = NULL;

UIWindow *mainWindow;


// init the menu
// global variabls, extern in Macros.h
Menu *menu = [Menu alloc];
Switches *switches = [Switches alloc];


-(id)initWithTitle:(NSString *)title_ titleColor:(UIColor *)titleColor_ titleFont:(NSString *)titleFont_ credits:(NSString *)credits_ headerColor:(UIColor *)headerColor_ switchOffColor:(UIColor *)switchOffColor_ switchOnColor:(UIColor *)switchOnColor_ switchTitleFont:(NSString *)switchTitleFont_ switchTitleColor:(UIColor *)switchTitleColor_ infoButtonColor:(UIColor *)infoButtonColor_ maxVisibleSwitches:(int)maxVisibleSwitches_ menuWidth:(CGFloat )menuWidth_ menuIcon:(NSString *)menuIconBase64_ menuButton:(NSString *)menuButtonBase64_ subMenuNames:(NSArray *)subMenuNames_ {
    mainWindow = [UIApplication sharedApplication].keyWindow;
    defaults = [NSUserDefaults standardUserDefaults];

    menuWidth = menuWidth_;
    switchOnColor = switchOnColor_;
    credits = credits_;
    switchTitleFont = switchTitleFont_;
    switchTitleColor = switchTitleColor_;
    infoButtonColor = infoButtonColor_;
    menuButtonBase64 = menuButtonBase64_;

    // Base of the Menu UI.
    self = [super initWithFrame:CGRectMake(0,0,menuWidth_, maxVisibleSwitches_ * 50 + 90)];
    self.center = mainWindow.center;
    self.layer.opacity = 0.0f;
    self.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:1.0];
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = YES;
    
    
    
    // Enable text sharpness
    self.layer.allowsEdgeAntialiasing = YES;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Add blur effect to menu background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.bounds;
    blurView.layer.cornerRadius = 10.0f;
    blurView.clipsToBounds = YES;
    [self addSubview:blurView];

    // Main header with reduced height (50)
    self.header = [[UIView alloc]initWithFrame:CGRectMake(0, 1, menuWidth_, 50)];
    self.header.backgroundColor = [headerColor_ colorWithAlphaComponent:0.8];
    CAShapeLayer *headerLayer = [CAShapeLayer layer];
    headerLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.header.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    self.header.layer.mask = headerLayer;
    [self addSubview:self.header];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:[Heaven HEAVEN_ICON] options:0];
    UIImage* menuIconImage = [UIImage imageWithData:data];

    UIButton *menuIcon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuIcon.frame = CGRectMake((menuWidth_ - 50) / 2, 1, 50, 50); // Centered horizontally
    menuIcon.backgroundColor = [UIColor clearColor];
    [menuIcon setBackgroundImage:menuIconImage forState:UIControlStateNormal];

    [menuIcon addTarget:self action:@selector(menuIconTapped) forControlEvents:UIControlEventTouchDown];
    [self.header addSubview:menuIcon];

    // Second header with "Main Menu" text
    UIView *secondHeader = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.header.frame), menuWidth_, 30)];
    secondHeader.backgroundColor = [headerColor_ colorWithAlphaComponent:0.8];
    [self addSubview:secondHeader];


    // Add version label on the left
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 30)];
    versionLabel.text = @"v1.0.0";
    versionLabel.textColor = [UIColor colorWithRed:171.0/255.0 green:137.0/255.0 blue:249.0/255.0 alpha:1.0];
    versionLabel.font = [UIFont fontWithName:switchTitleFont_ size:12];
    versionLabel.textAlignment = NSTextAlignmentLeft;
    versionLabel.tag = 999; // Tag dla labela z wersją
    [secondHeader addSubview:versionLabel];



    UILabel *mainMenuLabel = [[UILabel alloc] initWithFrame:secondHeader.bounds];
    mainMenuLabel.text = @"Main Menu";
    mainMenuLabel.textColor = [UIColor whiteColor];
    mainMenuLabel.font = [UIFont fontWithName:switchTitleFont_ size:12];
    mainMenuLabel.textAlignment = NSTextAlignmentCenter;
    mainMenuLabel.layer.allowsEdgeAntialiasing = YES;
    mainMenuLabel.layer.shouldRasterize = YES;
    mainMenuLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
    mainMenuLabel.tag = 888; // Tag dla labela z Main Menu
    [secondHeader addSubview:mainMenuLabel];

    // Add counter label to second header
    self.counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(menuWidth_ - 60, 0, 50, 30)];
    self.counterLabel.textColor = [UIColor colorWithRed:171.0/255.0 green:137.0/255.0 blue:249.0/255.0 alpha:1.0];
    self.counterLabel.textAlignment = NSTextAlignmentRight;
    self.counterLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    [secondHeader addSubview:self.counterLabel];

    // Add blur effect to scrollView
    UIBlurEffect *scrollBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *scrollBlurView = [[UIVisualEffectView alloc] initWithEffect:scrollBlurEffect];
    scrollBlurView.frame = CGRectMake(0, CGRectGetMaxY(secondHeader.frame), menuWidth_, CGRectGetHeight(self.bounds) - CGRectGetMaxY(secondHeader.frame));
    [self addSubview:scrollBlurView];

    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(secondHeader.frame), menuWidth_, CGRectGetHeight(self.bounds) - CGRectGetMaxY(secondHeader.frame) - 20)];
    scrollView.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:1.0];
    [self addSubview:scrollView];

    // we need this for the switches, do not remove.
    scrollViewX = CGRectGetMinX(scrollView.self.bounds);

    // Footer with three dots
    self.footer = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 20, menuWidth_, 20)];
    self.footer.backgroundColor = headerColor_;
    CAShapeLayer *footerLayer = [CAShapeLayer layer];
    footerLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.footer.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    self.footer.layer.mask = footerLayer;
    
    // Add three dots
    UILabel *dotsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuWidth_, 20)];
    dotsLabel.text = @"•••";
    dotsLabel.textColor = [UIColor whiteColor];
    dotsLabel.textAlignment = NSTextAlignmentCenter;
    dotsLabel.font = [UIFont systemFontOfSize:16];
    [self.footer addSubview:dotsLabel];
    
    [self addSubview:self.footer];

 
    UIPanGestureRecognizer *dragMenuRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(menuDragged:)];
    [self.header addGestureRecognizer:dragMenuRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMenu:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.header addGestureRecognizer:tapGestureRecognizer];

    [mainWindow addSubview:self];
    [self showMenuButton];

    self.isMenuVisible = NO;
    self.selectedSwitchIndex = 0;
    
    // Initialize sub-menus array
    self.subMenus = subMenuNames_;
    self.currentMenuIndex = 0;

    // Create main scroll view for sub-menus
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(secondHeader.frame), menuWidth_, maxVisibleSwitches_ * 30)];
    self.mainScrollView.backgroundColor = [UIColor clearColor];
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.mainScrollView];

    // Add sub-menu items
    CGFloat subMenuY = 0;
    for (NSInteger i = 0; i < self.subMenus.count; i++) {
        UIView *subMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, subMenuY, menuWidth_, 30)];
        subMenuView.backgroundColor = [UIColor clearColor];
        subMenuView.tag = i; // Use tag to identify sub-menu
        
        UILabel *subMenuLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, menuWidth_ - 20, 30)];
        subMenuLabel.text = self.subMenus[i];
        subMenuLabel.textColor = switchTitleColor;
        subMenuLabel.font = [UIFont fontWithName:switchTitleFont size:12];
        subMenuLabel.textAlignment = NSTextAlignmentLeft;
        [subMenuView addSubview:subMenuLabel];
        
        [self.mainScrollView addSubview:subMenuView];
        subMenuY += 30;
    }
    
    // Set main scroll view content size
    self.mainScrollView.contentSize = CGSizeMake(menuWidth_, self.subMenus.count * 30);

    // Create content scroll view for switches
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 
                                                                           CGRectGetMaxY(secondHeader.frame), 
                                                                           menuWidth_, 
                                                                           CGRectGetHeight(self.bounds) - CGRectGetMaxY(secondHeader.frame) - 20)];
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.hidden = YES; // Initially hidden
    [self addSubview:self.contentScrollView];

    // Move selection indicator to main scroll view
    self.selectionIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 30)];
    self.selectionIndicator.backgroundColor = [UIColor colorWithRed:171.0/255.0 green:137.0/255.0 blue:249.0/255.0 alpha:1.0];
    self.selectionIndicator.layer.cornerRadius = 1.5;
    self.selectionIndicator.clipsToBounds = YES;
    self.selectionIndicator.layer.zPosition = 1.0;
    [self.mainScrollView addSubview:self.selectionIndicator];
    
    // Add gamepad button handling
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleGamepadInput:)
                                               name:@"GamepadInputNotification"
                                             object:nil];
    
    // Start gamepad monitoring
    [GamepadInput startMonitoring];
    
    // --- INFO BARS LIKE ON THE SCREENSHOT ---
    // Pozycjonowanie względem footera
    CGFloat infoBarWidth = self.footer.frame.size.width; // Account for scale
    CGFloat infoBarHeight = self.footer.frame.size.height; // Account for scale
    CGFloat infoBarSpacing = 15;
    
    // Create info bar with exact same frame as footer but scaled
    UIView *infoBar1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, infoBarWidth, infoBarHeight)];
    infoBar1.backgroundColor = headerColor_;
    infoBar1.layer.cornerRadius = 5.0f;
    infoBar1.clipsToBounds = YES;
    infoBar1.alpha = 0.0f; // Start hidden
    
    // Add rounded corners mask exactly like footer
    CAShapeLayer *infoBarLayer = [CAShapeLayer layer];
    infoBarLayer.path = [UIBezierPath bezierPathWithRoundedRect:infoBar1.bounds 
                                               byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight 
                                                     cornerRadii:(CGSize){5.0, 5.0}].CGPath; // Reduced corner radius
    infoBar1.layer.mask = infoBarLayer;
    
    UILabel *infoLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, infoBarWidth - 10, 20)];
    infoLabel1.text = @"Select a feature to see its description";
    infoLabel1.textColor = [UIColor whiteColor];
    infoLabel1.textAlignment = NSTextAlignmentCenter;
    infoLabel1.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    infoLabel1.numberOfLines = 0; // Allow multiple lines
    infoLabel1.lineBreakMode = NSLineBreakByWordWrapping;
    
    // Add SF Symbol info icon
    self.infoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    self.infoIcon.image = [UIImage systemImageNamed:@"info.circle"];
    self.infoIcon.tintColor = [UIColor colorWithRed:171.0/255.0 green:137.0/255.0 blue:249.0/255.0 alpha:1.0];
    self.infoIcon.contentMode = UIViewContentModeScaleAspectFit;
    [infoBar1 addSubview:self.infoIcon];
    
    // Adjust label frame to account for icon
    infoLabel1.frame = CGRectMake(30, 5, infoBarWidth - 35, 20);
    [infoBar1 addSubview:infoLabel1];
    
    [mainWindow addSubview:infoBar1];

    // Store reference for dragging
    objc_setAssociatedObject(self, "infoBar1", infoBar1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, "infoLabel1", infoLabel1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Initialize sub-menu switches array
    self.subMenuSwitches = [NSMutableArray arrayWithCapacity:self.subMenus.count];
    for (NSInteger i = 0; i < self.subMenus.count; i++) {
        [self.subMenuSwitches addObject:[NSMutableArray array]];
    }
    
    return self;
}

// Detects whether the menu is being touched and sets a lastMenuLocation.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.lastMenuLocation = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    [super touchesBegan:touches withEvent:event];
}

// Update the menu's location when it's being dragged
- (void)menuDragged:(UIPanGestureRecognizer *)pan {
    CGPoint newLocation = [pan translationInView:self.superview];
    self.frame = CGRectMake(self.lastMenuLocation.x + newLocation.x, self.lastMenuLocation.y + newLocation.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    // Update info bar position
    [self updateInfoBarPosition];
}

- (void)hideMenu:(UITapGestureRecognizer *)tap {
    if(tap == nil || tap.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 0.0f;
            menuButton.alpha = 1.0f;
            
            // Hide info bar
            UIView *infoBar1 = objc_getAssociatedObject(self, "infoBar1");
            if (infoBar1) {
                infoBar1.alpha = 0.0f;
            }
        }];
        self.isMenuVisible = NO;
    }
}

-(void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer == nil || tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        menuButton.alpha = 0.0f;
        
        // Ensure proper scroll view visibility based on current state
        if (self.mainScrollView.hidden && self.contentScrollView.hidden) {
            // If both are hidden, we're in main menu state
            self.mainScrollView.hidden = NO;
            self.contentScrollView.hidden = YES;
        }
        
        // Restore second header text based on current state
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIView class]] && view.frame.size.height == 30) {
                for (UIView *subview in view.subviews) {
                    if ([subview isKindOfClass:[UILabel class]] && subview.tag == 888) {
                        if (!self.mainScrollView.hidden) {
                            ((UILabel *)subview).text = @"Main Menu";
                        } else {
                            ((UILabel *)subview).text = self.subMenus[self.currentMenuIndex];
                        }
                        break;
                    }
                }
                break;
            }
        }
        
        // Restore content in contentScrollView if we're in sub-menu
        if (self.contentScrollView.hidden == NO) {
            // Clear existing content
            for (UIView *view in self.contentScrollView.subviews) {
                [view removeFromSuperview];
            }
            
            // Add switches for the current sub-menu
            NSMutableArray *switches = self.subMenuSwitches[self.currentMenuIndex];
            CGFloat yOffset = 0;
            
            for (UIView *switch_ in switches) {
                switch_.frame = CGRectMake(0, yOffset, menuWidth, 30);
                [self.contentScrollView addSubview:switch_];
                yOffset += 30;
            }
            
            // Update content scroll view size
            self.contentScrollView.contentSize = CGSizeMake(menuWidth, yOffset);
            
            // Move selection indicator to content scroll view
            [self.selectionIndicator removeFromSuperview];
            [self.contentScrollView addSubview:self.selectionIndicator];
        } else {
            // Move selection indicator to main scroll view
            [self.selectionIndicator removeFromSuperview];
            [self.mainScrollView addSubview:self.selectionIndicator];
        }
        
        // Calculate menu height based on current state
        CGFloat contentHeight;
        if (!self.mainScrollView.hidden) {
            // Main menu - calculate height based on sub-menus
            contentHeight = MIN(self.subMenus.count * 30, 8 * 30);
        } else {
            // Sub-menu - calculate height based on switches in current sub-menu
            NSMutableArray *switches = self.subMenuSwitches[self.currentMenuIndex];
            contentHeight = MIN(switches.count * 30, 8 * 30);
        }
        
        CGFloat newHeight = CGRectGetMaxY(self.header.frame) + 30 + contentHeight + 20; // header + second header + content + footer
        
        // Animate menu frame change
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
            
            // Update blur view frame
            for (UIView *subview in self.subviews) {
                if ([subview isKindOfClass:[UIVisualEffectView class]]) {
                    subview.frame = self.bounds;
                    break;
                }
            }
            
            // Update footer position
            self.footer.frame = CGRectMake(0, newHeight - 20, menuWidth, 20);
            
            // Update scroll view frames based on current state
            if (!self.mainScrollView.hidden) {
                // Main menu
                self.mainScrollView.frame = CGRectMake(0, 
                                                     CGRectGetMaxY(self.header.frame) + 30,
                                                     menuWidth,
                                                     contentHeight);
            } else {
                // Sub-menu
                self.contentScrollView.frame = CGRectMake(0, 
                                                        CGRectGetMaxY(self.header.frame) + 30,
                                                        menuWidth,
                                                        contentHeight);
            }
        }];
        
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 1.0f;
            
            // Show and position info bar
            UIView *infoBar1 = objc_getAssociatedObject(self, "infoBar1");
            if (infoBar1) {
                infoBar1.alpha = 1.0f;
                [self updateInfoBarPosition];
            }
        }];
        self.isMenuVisible = YES;
        
        // Initialize counter label
        if (!self.mainScrollView.hidden) {
            self.counterLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(self.selectedSwitchIndex + 1), (long)self.subMenus.count];
        } else {
            NSMutableArray *switches = self.subMenuSwitches[self.currentMenuIndex];
            self.counterLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(self.selectedSwitchIndex + 1), (long)switches.count];
        }
        
        // Restore selection indicator position
        [self updateSelectionIndicator];
    }
    // We should only have to do this once (first launch)
    if(!hasRestoredLastSession) {
        restoreLastSession();
        hasRestoredLastSession = true;
    }
}


/**********************************************************************************************
     This function will be called when the menu has been opened for the first time on launch.
     It'll handle the correct background color and patches the switches do.
***********************************************************************************************/
void restoreLastSession() {
    BOOL isOn = false;

    for(id switch_ in scrollView.subviews) {
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
            for(int i = 0; i < memoryPatches.size(); i++) {
                if(isOn){
                    memoryPatches[i].Modify();
                } else {
                    memoryPatches[i].Restore();
                }
            }
            
            // Update status label
            for(UIView *subview in [switch_ subviews]) {
                if([subview isKindOfClass:[UILabel class]] && [((UILabel*)subview).text isEqualToString:@"ON"] || [((UILabel*)subview).text isEqualToString:@"OFF"]) {
                    ((UILabel*)subview).text = isOn ? @"ON" : @"OFF";
                    ((UILabel*)subview).textColor = isOn ? switchOnColor : [UIColor grayColor];
                    break;
                }
            }
        }

        if([switch_ isKindOfClass:[TextFieldSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            // Update status label
            for(UIView *subview in [switch_ subviews]) {
                if([subview isKindOfClass:[UILabel class]] && [((UILabel*)subview).text isEqualToString:@"ON"] || [((UILabel*)subview).text isEqualToString:@"OFF"]) {
                    ((UILabel*)subview).text = isOn ? @"ON" : @"OFF";
                    ((UILabel*)subview).textColor = isOn ? switchOnColor : [UIColor grayColor];
                    break;
                }
            }
        }

        if([switch_ isKindOfClass:[SliderSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            // Update status label
            for(UIView *subview in [switch_ subviews]) {
                if([subview isKindOfClass:[UILabel class]] && [((UILabel*)subview).text isEqualToString:@"ON"] || [((UILabel*)subview).text isEqualToString:@"OFF"]) {
                    ((UILabel*)subview).text = isOn ? @"ON" : @"OFF";
                    ((UILabel*)subview).textColor = isOn ? switchOnColor : [UIColor grayColor];
                    break;
                }
            }
        }
    }
}

-(void)showMenuButton {
    NSData* data = [[NSData alloc] initWithBase64EncodedString:menuButtonBase64 options:0];
    UIImage* menuButtonImage = [UIImage imageWithData:data];

    menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuButton.frame = CGRectMake((mainWindow.frame.size.width/2), (mainWindow.frame.size.height/2), 50, 50);
    
    // Add rounded square background
    menuButton.backgroundColor = [self.header.backgroundColor colorWithAlphaComponent:0.8];
    menuButton.layer.cornerRadius = 10.0f;
    menuButton.clipsToBounds = YES;
    
    [menuButton setBackgroundImage:menuButtonImage forState:UIControlStateNormal];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMenu:)];
    [menuButton addGestureRecognizer:tapGestureRecognizer];

    [menuButton addTarget:self action:@selector(buttonDragged:withEvent:)
       forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:menuButton];
}

// handler for when the user is draggin the menu.
- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];

    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;

    button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);
}

// When the menu icon(on the header) has been tapped, we want to show proper credits!
-(void)menuIconTapped {
    [self showPopup:self.menuTitle.text description:credits];
    self.layer.opacity = 0.0f;
}

-(void)showPopup:(NSString *)title_ description:(NSString *)description_ {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];

    alert.shouldDismissOnTapOutside = NO;
    alert.customViewColor = [UIColor purpleColor];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

    [alert addButton: @"Ok!" actionBlock: ^(void) {
        self.layer.opacity = 1.0f;
    }];

    [alert showInfo:title_ subTitle:description_ closeButtonTitle:nil duration:9999999.0f];
}

/*******************************************************************
    This method adds the given switch to the menu's scrollview.
    it also add's an action for when the switch is being clicked.
********************************************************************/
- (void)addSwitchToMenu:(id)switch_ {
    [switch_ addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchDown];
    scrollViewHeight += 30;
    scrollView.contentSize = CGSizeMake(menuWidth, scrollViewHeight);
    [scrollView addSubview:switch_];
    
    // Calculate content height (limited to 8 switches)
    CGFloat contentHeight = MIN(scrollViewHeight, 8 * 30); // 8 switches * 30 height each
    
    // Update menu frame height
    CGFloat newHeight = CGRectGetMaxY(self.header.frame) + 30 + contentHeight + 20; // header + second header + content + footer
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
    
    // Update blur view frame
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIVisualEffectView class]]) {
            subview.frame = self.bounds;
            break;
        }
    }
    
    // Update footer position
    self.footer.frame = CGRectMake(0, newHeight - 20, menuWidth, 20);
    
    // Update info bar position
    [self updateInfoBarPosition];
}

/*********************************************************************************************
    This method does the following handles the behaviour when a switch has been clicked
    TextfieldSwitch and SliderSwitch only change from color based on whether it's on or not.
    A OffsetSwitch does too, but it also applies offset patches
***********************************************************************************************/
-(void)switchClicked:(id)switch_ {
    BOOL isOn = [defaults boolForKey:[switch_ getPreferencesKey]];

    if([switch_ isKindOfClass:[OffsetSwitch class]]) {
        if(!isOn) {
            std::vector<MemoryPatch> patches = [switch_ getMemoryPatches];
            for(int i = 0; i < patches.size(); i++) {
                patches[i].Modify();
            }
            
            // Handle light bar color switches
            NSString *switchName = [switch_ getPreferencesKey];
            if ([switchName isEqualToString:@"Light Red"]) {
                setControllerLightColor(1.0, 0.0, 0.0);
            } else if ([switchName isEqualToString:@"Light Green"]) {
                setControllerLightColor(0.0, 1.0, 0.0);
            } else if ([switchName isEqualToString:@"Light Blue"]) {
                setControllerLightColor(0.0, 0.0, 1.0);
            } else if ([switchName isEqualToString:@"Light Yellow"]) {
                setControllerLightColor(1.0, 1.0, 0.0);
            } else if ([switchName isEqualToString:@"Light Purple"]) {
                setControllerLightColor(0.5, 0.0, 0.5);
            } else if ([switchName isEqualToString:@"Light Cyan"]) {
                setControllerLightColor(0.0, 1.0, 1.0);
            } else if ([switchName isEqualToString:@"Light White"]) {
                setControllerLightColor(1.0, 1.0, 1.0);
            } else if ([switchName isEqualToString:@"RGB Cycle"]) {
                startRGBCycle();
            } else if ([switchName isEqualToString:@"Police Lights"]) {
                startPoliceLights();
            } else if ([switchName isEqualToString:@"Breathing Red"]) {
                startBreathingEffect(1.0, 0.0, 0.0);
            } else if ([switchName isEqualToString:@"Breathing Green"]) {
                startBreathingEffect(0.0, 1.0, 0.0);
            } else if ([switchName isEqualToString:@"Breathing Blue"]) {
                startBreathingEffect(0.0, 0.0, 1.0);
            } else if ([switchName isEqualToString:@"Breathing Purple"]) {
                startBreathingEffect(0.5, 0.0, 0.5);
            } else if ([switchName isEqualToString:@"Rainbow Wave"]) {
                startRainbowWave();
            } else if ([switchName isEqualToString:@"Strobe Effect"]) {
                startStrobeEffect();
            } else if ([switchName isEqualToString:@"Pulse Red"]) {
                startPulseEffect(1.0, 0.0, 0.0);
            } else if ([switchName isEqualToString:@"Pulse Green"]) {
                startPulseEffect(0.0, 1.0, 0.0);
            } else if ([switchName isEqualToString:@"Pulse Blue"]) {
                startPulseEffect(0.0, 0.0, 1.0);
            } else if ([switchName isEqualToString:@"Pulse Orange"]) {
                startPulseEffect(1.0, 0.5, 0.0);
            } else if ([switchName isEqualToString:@"Pulse Pink"]) {
                startPulseEffect(1.0, 0.0, 0.5);
            }
        } else {
            std::vector<MemoryPatch> patches = [switch_ getUnpatchMemoryPatches];
            for(int i = 0; i < patches.size(); i++) {
                patches[i].Modify();
            }
            
            // Reset light bar color when switch is turned off
            NSString *switchName = [switch_ getPreferencesKey];
            if ([switchName isEqualToString:@"Light Red"] || 
                [switchName isEqualToString:@"Light Green"] || 
                [switchName isEqualToString:@"Light Blue"] ||
                [switchName isEqualToString:@"Light Yellow"] ||
                [switchName isEqualToString:@"Light Purple"] ||
                [switchName isEqualToString:@"Light Cyan"] ||
                [switchName isEqualToString:@"Light White"]) {
                setControllerLightColor(0.0, 0.4, 1.0); // Default blue color
            } else if ([switchName isEqualToString:@"RGB Cycle"]) {
                stopRGBCycle();
                setControllerLightColor(0.0, 0.4, 1.0); // Reset to default blue
            } else if ([switchName isEqualToString:@"Police Lights"]) {
                stopPoliceLights();
                setControllerLightColor(0.0, 0.4, 1.0); // Reset to default blue
            } else if ([switchName isEqualToString:@"Breathing Red"] ||
                       [switchName isEqualToString:@"Breathing Green"] ||
                       [switchName isEqualToString:@"Breathing Blue"] ||
                       [switchName isEqualToString:@"Breathing Purple"]) {
                stopBreathingEffect();
                setControllerLightColor(0.0, 0.4, 1.0); // Reset to default blue
            } else if ([switchName isEqualToString:@"Rainbow Wave"]) {
                stopRainbowWave();
                setControllerLightColor(0.0, 0.4, 1.0); // Reset to default blue
            } else if ([switchName isEqualToString:@"Strobe Effect"]) {
                stopStrobeEffect();
                setControllerLightColor(0.0, 0.4, 1.0); // Reset to default blue
            } else if ([switchName isEqualToString:@"Pulse Red"] ||
                       [switchName isEqualToString:@"Pulse Green"] ||
                       [switchName isEqualToString:@"Pulse Blue"] ||
                       [switchName isEqualToString:@"Pulse Orange"] ||
                       [switchName isEqualToString:@"Pulse Pink"]) {
                stopPulseEffect();
                setControllerLightColor(0.0, 0.4, 1.0); // Reset to default blue
            }
        }
    }

    // Update status label with animation
    UILabel *statusLabel = [[switch_ subviews] objectAtIndex:1];
    if ([statusLabel isKindOfClass:[UILabel class]]) {
        [UIView animateWithDuration:0.3 animations:^{
            statusLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            statusLabel.text = !isOn ? @"ON" : @"OFF";
            statusLabel.textColor = !isOn ? [UIColor colorWithRed:171.0/255.0 green:137.0/255.0 blue:249.0/255.0 alpha:1.0] : [UIColor grayColor];
            [UIView animateWithDuration:0.3 animations:^{
                statusLabel.alpha = 1.0;
            }];
        }];
    }

    // Update pref value
    [defaults setBool:!isOn forKey:[switch_ getPreferencesKey]];
    
    // Show notification
    UIColor *headerColor = self.header.backgroundColor;
    CustomNotification *notification = [[CustomNotification alloc] initWithHeaderColor:headerColor];
    NSString *functionName = [switch_ getPreferencesKey];
    NSString *descriptionText = @"";
    if ([switch_ respondsToSelector:@selector(getDescription)]) {
        descriptionText = [switch_ getDescription];
    }
    NSString *statusText = !isOn ? @"ON" : @"OFF";
    NSString *title = [NSString stringWithFormat:@"GameFusion ⥃ %@ [%@]", functionName, statusText];
    [notification showWithTitle:title description:descriptionText headerColor:headerColor];
}
-(void)setFrameworkName:(const char *)name_ {
    frameworkName = name_;
}

-(const char *)getFrameworkName {
    return frameworkName;
}

-(void)handleGamepadInput:(NSNotification *)notification {
    NSString *action = notification.userInfo[@"action"];
    
    if ([action isEqualToString:@"show"]) {
        [self showMenu:nil];
    } else if ([action isEqualToString:@"hide"]) {
        [self hideMenu:nil];
    } else if ([action isEqualToString:@"up"]) {
        // Move selection up
        if (!self.mainScrollView.hidden) {
            // Main menu navigation
            if (self.selectedSwitchIndex > 0) {
                self.selectedSwitchIndex--;
                [self updateSelectionIndicator];
            }
        } else {
            // Sub-menu navigation
            NSInteger maxIndex = [self getMaxSwitchIndexForCurrentMenu];
            if (self.selectedSwitchIndex > 0) {
                self.selectedSwitchIndex--;
                [self updateSelectionIndicator];
            }
        }
    } else if ([action isEqualToString:@"down"]) {
        // Move selection down
        if (!self.mainScrollView.hidden) {
            // Main menu navigation
            if (self.selectedSwitchIndex < self.subMenus.count - 1) {
                self.selectedSwitchIndex++;
                [self updateSelectionIndicator];
            }
        } else {
            // Sub-menu navigation
            NSInteger maxIndex = [self getMaxSwitchIndexForCurrentMenu];
            if (self.selectedSwitchIndex < maxIndex) {
                self.selectedSwitchIndex++;
                [self updateSelectionIndicator];
            }
        }
    } else if ([action isEqualToString:@"select"]) {
        // Activate selected item
        if (!self.mainScrollView.hidden) {
            // Show selected sub-menu content
            [self showSubMenuContent:self.selectedSwitchIndex];
        } else {
            // Activate selected switch
            NSMutableArray *switches = self.subMenuSwitches[self.currentMenuIndex];
            if (self.selectedSwitchIndex < switches.count) {
                UIView *selectedView = switches[self.selectedSwitchIndex];
                if ([selectedView isKindOfClass:[OffsetSwitch class]]) {
                    OffsetSwitch *switch_ = (OffsetSwitch *)selectedView;
                    [self switchClicked:switch_];
                } else if ([selectedView isKindOfClass:[TextFieldSwitch class]]) {
                    TextFieldSwitch *switch_ = (TextFieldSwitch *)selectedView;
                    [self switchClicked:switch_];
                } else if ([selectedView isKindOfClass:[SliderSwitch class]]) {
                    SliderSwitch *switch_ = (SliderSwitch *)selectedView;
                    [self switchClicked:switch_];
                }
            }
        }
    } else if ([action isEqualToString:@"back"]) {
        // Return to main menu
        if (self.mainScrollView.hidden) {
            [self returnToMainMenu];
        }
    }
}

-(NSInteger)getMaxSwitchIndexForCurrentMenu {
    if (self.mainScrollView.hidden) {
        NSMutableArray *switches = self.subMenuSwitches[self.currentMenuIndex];
        return switches.count - 1;
    }
    return self.subMenus.count - 1;
}

-(void)updateSelectionIndicator {
    if (!self.mainScrollView.hidden) {
        // Update main menu selection
        UIView *selectedView = [self.mainScrollView.subviews objectAtIndex:self.selectedSwitchIndex];
        if (selectedView) {
            [UIView animateWithDuration:0.2 animations:^{
                self.selectionIndicator.frame = CGRectMake(0, 
                                                         selectedView.frame.origin.y,
                                                         3,
                                                         selectedView.frame.size.height);
                selectedView.backgroundColor = [self.header.backgroundColor colorWithAlphaComponent:0.3];
            }];
            
            // Reset other items
            for (UIView *view in self.mainScrollView.subviews) {
                if (view != selectedView && view != self.selectionIndicator) {
                    [UIView animateWithDuration:0.2 animations:^{
                        view.backgroundColor = [UIColor clearColor];
                    }];
                }
            }
            
            // Update counter
            self.counterLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(self.selectedSwitchIndex + 1), (long)self.subMenus.count];
            
            // Update info bar
            UIView *infoBar1 = objc_getAssociatedObject(self, "infoBar1");
            UILabel *infoLabel1 = objc_getAssociatedObject(self, "infoLabel1");
            if (infoBar1 && infoLabel1) {
                NSString *text = @"";
                if (!self.mainScrollView.hidden) {
                    text = [NSString stringWithFormat:@"Navigate to %@", self.subMenus[self.selectedSwitchIndex]];
                } else {
                    if ([selectedView isKindOfClass:[OffsetSwitch class]]) {
                        text = [(OffsetSwitch *)selectedView getDescription];
                    } else if ([selectedView isKindOfClass:[TextFieldSwitch class]]) {
                        text = [(TextFieldSwitch *)selectedView getDescription];
                    } else if ([selectedView isKindOfClass:[SliderSwitch class]]) {
                        text = [(SliderSwitch *)selectedView getDescription];
                    }
                }
                
                [UIView animateWithDuration:0.3 animations:^{
                    infoLabel1.text = text;
                    
                    // Calculate required height for the text
                    CGSize maxSize = CGSizeMake(menuWidth - 35, CGFLOAT_MAX); // Adjusted for icon
                    CGSize textSize = [text boundingRectWithSize:maxSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:@{NSFontAttributeName: infoLabel1.font}
                                                       context:nil].size;
                    
                    // Add padding
                    CGFloat newHeight = textSize.height + 10;
                    CGFloat defaultHeight = 20; // Original default height
                    newHeight = MAX(newHeight, defaultHeight);
                    
                    // Update info bar frame with animation
                    CGRect newFrame = infoBar1.frame;
                    newFrame.size.height = newHeight;
                    infoBar1.frame = newFrame;
                    
                    // Update label frame with animation
                    infoLabel1.frame = CGRectMake(30, 5, menuWidth - 35, textSize.height);
                    
                    // Update icon position with animation
                    self.infoIcon.frame = CGRectMake(5, (newHeight - 20) / 2, 20, 20);
                    
                    // Update corner radius mask
                    CAShapeLayer *infoBarLayer = [CAShapeLayer layer];
                    infoBarLayer.path = [UIBezierPath bezierPathWithRoundedRect:infoBar1.bounds 
                                                               byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight 
                                                                     cornerRadii:(CGSize){5.0, 5.0}].CGPath;
                    infoBar1.layer.mask = infoBarLayer;
                } completion:^(BOOL finished) {
                    // Ensure final position is correct
                    [self updateInfoBarPosition];
                }];
            }
            
            // Ensure selected item is visible with animation
            [UIView animateWithDuration:0.3 animations:^{
                [self.mainScrollView scrollRectToVisible:selectedView.frame animated:NO];
            }];
        }
    } else {
        // Update content view selection
        NSMutableArray *switches = self.subMenuSwitches[self.currentMenuIndex];
        if (self.selectedSwitchIndex < switches.count) {
            UIView *selectedView = switches[self.selectedSwitchIndex];
            [UIView animateWithDuration:0.2 animations:^{
                self.selectionIndicator.frame = CGRectMake(0, 
                                                         selectedView.frame.origin.y,
                                                         3,
                                                         selectedView.frame.size.height);
                selectedView.backgroundColor = [self.header.backgroundColor colorWithAlphaComponent:0.3];
            }];
            
            // Reset other items
            for (UIView *view in self.contentScrollView.subviews) {
                if (view != selectedView && view != self.selectionIndicator) {
                    [UIView animateWithDuration:0.2 animations:^{
                        view.backgroundColor = [UIColor clearColor];
                    }];
                }
            }
            
            // Update counter
            self.counterLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(self.selectedSwitchIndex + 1), (long)switches.count];
            
            // Update info bar
            UIView *infoBar1 = objc_getAssociatedObject(self, "infoBar1");
            UILabel *infoLabel1 = objc_getAssociatedObject(self, "infoLabel1");
            if (infoBar1 && infoLabel1) {
                NSString *text = @"";
                if ([selectedView isKindOfClass:[OffsetSwitch class]]) {
                    text = [(OffsetSwitch *)selectedView getDescription];
                } else if ([selectedView isKindOfClass:[TextFieldSwitch class]]) {
                    text = [(TextFieldSwitch *)selectedView getDescription];
                } else if ([selectedView isKindOfClass:[SliderSwitch class]]) {
                    text = [(SliderSwitch *)selectedView getDescription];
                }
                
                [UIView animateWithDuration:0.3 animations:^{
                    infoLabel1.text = text;
                    
                    // Calculate required height for the text
                    CGSize maxSize = CGSizeMake(menuWidth - 35, CGFLOAT_MAX); // Adjusted for icon
                    CGSize textSize = [text boundingRectWithSize:maxSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:@{NSFontAttributeName: infoLabel1.font}
                                                       context:nil].size;
                    
                    // Add padding
                    CGFloat newHeight = textSize.height + 10;
                    CGFloat defaultHeight = 20; // Original default height
                    newHeight = MAX(newHeight, defaultHeight);
                    
                    // Update info bar frame with animation
                    CGRect newFrame = infoBar1.frame;
                    newFrame.size.height = newHeight;
                    infoBar1.frame = newFrame;
                    
                    // Update label frame with animation
                    infoLabel1.frame = CGRectMake(30, 5, menuWidth - 35, textSize.height);
                    
                    // Update icon position with animation
                    self.infoIcon.frame = CGRectMake(5, (newHeight - 20) / 2, 20, 20);
                    
                    // Update corner radius mask
                    CAShapeLayer *infoBarLayer = [CAShapeLayer layer];
                    infoBarLayer.path = [UIBezierPath bezierPathWithRoundedRect:infoBar1.bounds 
                                                               byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight 
                                                                     cornerRadii:(CGSize){5.0, 5.0}].CGPath;
                    infoBar1.layer.mask = infoBarLayer;
                } completion:^(BOOL finished) {
                    // Ensure final position is correct
                    [self updateInfoBarPosition];
                }];
            }
            
            // Ensure selected item is visible with animation
            [UIView animateWithDuration:0.3 animations:^{
                [self.contentScrollView scrollRectToVisible:selectedView.frame animated:NO];
            }];
        }
    }
}

-(void)activateSelectedSwitch {
    if (!self.mainScrollView.hidden) {
        // Show content for selected sub-menu
        [self showSubMenuContent:self.selectedSwitchIndex];
    } else {
        // Activate selected switch in content view
        NSMutableArray *switches = self.subMenuSwitches[self.currentMenuIndex];
        if (self.selectedSwitchIndex < switches.count) {
            UIView *selectedView = switches[self.selectedSwitchIndex];
            if ([selectedView isKindOfClass:[OffsetSwitch class]] || 
                [selectedView isKindOfClass:[TextFieldSwitch class]] || 
                [selectedView isKindOfClass:[SliderSwitch class]]) {
                [self switchClicked:selectedView];
            }
        }
    }
}

-(void)showSubMenuContent:(NSInteger)menuIndex {
    // Store current menu index
    self.currentMenuIndex = menuIndex;
    
    // Hide main scroll view and show content scroll view
    self.mainScrollView.hidden = YES;
    self.contentScrollView.hidden = NO;
    
    // Update second header text
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIView class]] && view.frame.size.height == 30) {
            for (UIView *subview in view.subviews) {
                if ([subview isKindOfClass:[UILabel class]] && subview.tag == 888) {
                    ((UILabel *)subview).text = self.subMenus[menuIndex];
                    break;
                }
            }
            break;
        }
    }
    
    // Clear existing content
    for (UIView *view in self.contentScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    // Add switches for the selected sub-menu
    NSMutableArray *switches = self.subMenuSwitches[menuIndex];
    CGFloat yOffset = 0;
    
    for (UIView *switch_ in switches) {
        switch_.frame = CGRectMake(0, yOffset, menuWidth, 30);
        [self.contentScrollView addSubview:switch_];
        yOffset += 30;
    }
    
    // Update content scroll view size
    self.contentScrollView.contentSize = CGSizeMake(menuWidth, yOffset);
    
    // Calculate content height (limited to 8 switches)
    CGFloat contentHeight = MIN(yOffset, 8 * 30); // 8 switches * 30 height each
    
    // Calculate new menu height
    CGFloat newHeight = CGRectGetMaxY(self.header.frame) + 30 + contentHeight + 20; // header + second header + content + footer
    
    // Animate menu frame change
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
        
        // Update blur view frame
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.frame = self.bounds;
                break;
            }
        }
        
        // Update footer position
        self.footer.frame = CGRectMake(0, newHeight - 20, menuWidth, 20);
        
        // Update content scroll view frame
        self.contentScrollView.frame = CGRectMake(0, 
                                                CGRectGetMaxY(self.header.frame) + 30,
                                                menuWidth,
                                                contentHeight);
    }];
    
    // Update info bar position
    [self updateInfoBarPosition];
    
    // Reset selection index
    self.selectedSwitchIndex = 0;
    
    // Move selection indicator to content scroll view
    [self.selectionIndicator removeFromSuperview];
    [self.contentScrollView addSubview:self.selectionIndicator];
    
    // Update indicator position
    self.selectionIndicator.frame = CGRectMake(0, 0, 3, 30);
    
    [self updateSelectionIndicator];
}

// Add new method to handle main menu return
-(void)returnToMainMenu {
    self.mainScrollView.hidden = NO;
    self.contentScrollView.hidden = YES;
    self.selectedSwitchIndex = self.currentMenuIndex;
    
    // Update second header text back to "Main Menu"
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIView class]] && view.frame.size.height == 30) {
            for (UIView *subview in view.subviews) {
                if ([subview isKindOfClass:[UILabel class]] && subview.tag == 888) {
                    ((UILabel *)subview).text = @"Main Menu";
                    break;
                }
            }
            break;
        }
    }
    
    // Calculate main menu height (limited to 8 items)
    CGFloat mainMenuHeight = MIN(self.subMenus.count * 30, 8 * 30);
    
    // Calculate new menu height
    CGFloat newHeight = CGRectGetMaxY(self.header.frame) + 30 + mainMenuHeight + 20; // header + second header + content + footer
    
    // Animate menu frame change
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
        
        // Update blur view frame
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UIVisualEffectView class]]) {
                subview.frame = self.bounds;
                break;
            }
        }
        
        // Update footer position
        self.footer.frame = CGRectMake(0, newHeight - 20, menuWidth, 20);
        
        // Update main scroll view frame
        self.mainScrollView.frame = CGRectMake(0, 
                                             CGRectGetMaxY(self.header.frame) + 30,
                                             menuWidth,
                                             mainMenuHeight);
    }];
    
    // Update info bar position
    [self updateInfoBarPosition];
    
    // Move selection indicator back to main scroll view
    [self.selectionIndicator removeFromSuperview];
    [self.mainScrollView addSubview:self.selectionIndicator];
    
    // Update indicator position
    UIView *selectedView = [self.mainScrollView.subviews objectAtIndex:self.selectedSwitchIndex];
    if (selectedView) {
        self.selectionIndicator.frame = CGRectMake(0, selectedView.frame.origin.y, 3, selectedView.frame.size.height);
    }
    
    [self updateSelectionIndicator];
}

-(void)addSwitchToSubMenu:(id)switch_ subMenuIndex:(NSInteger)subMenuIndex {
    if (subMenuIndex >= 0 && subMenuIndex < self.subMenus.count) {
        [self.subMenuSwitches[subMenuIndex] addObject:switch_];
        [switch_ addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchDown];
    }
}

// Add new helper method to update info bar position
-(void)updateInfoBarPosition {
    UIView *infoBar1 = objc_getAssociatedObject(self, "infoBar1");
    if (infoBar1 && self.isMenuVisible) {
        CGFloat infoBarSpacing = 15;
        CGRect footerFrame = self.footer.frame;
        
        [UIView animateWithDuration:0.3 animations:^{
            infoBar1.frame = CGRectMake(self.frame.origin.x + footerFrame.origin.x,
                                      self.frame.origin.y + self.frame.size.height + infoBarSpacing,
                                      footerFrame.size.width,
                                      infoBar1.frame.size.height);
        }];
    }
}

// Add new method to handle smooth scrolling
-(void)scrollToView:(UIView *)view inScrollView:(UIScrollView *)scrollView {
    CGRect rect = [view convertRect:view.bounds toView:scrollView];
    [UIView animateWithDuration:0.3 animations:^{
        [scrollView scrollRectToVisible:rect animated:NO];
    }];
}

// Override scrollViewDidScroll to add smooth scrolling
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Add smooth scrolling effect
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
}

@end // End of menu class!


/********************************
    OFFSET SWITCH STARTS HERE!
*********************************/

@implementation OffsetSwitch {
    UILabel *statusLabel;
}

- (id)initHackNamed:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::vector<uint64_t>)patchOffsets_ patchBytes:(std::vector<std::string>)patchBytes_
    unpatchOffsets:(std::vector<uint64_t>)unpatchOffsets_ unpatchBytes:(std::vector<std::string>)unpatchBytes_ {
    description = description_;
    preferencesKey = hackName_;

    if(patchOffsets_.size() != patchBytes_.size() || unpatchOffsets_.size() != unpatchBytes_.size()){
        [menu showPopup:@"Invalid input count" description:[NSString stringWithFormat:@"Offsets array input count (%d) is not equal to the bytes array input count (%d)", (int)patchOffsets_.size(), (int)patchBytes_.size()]];
    } else {
        // Store offsets and bytes for later use
        patchOffsets = patchOffsets_;
        patchBytes = patchBytes_;
        unpatchOffsets = unpatchOffsets_;
        unpatchBytes = unpatchBytes_;
    }

   self = [super initWithFrame:CGRectMake(0, scrollViewX + scrollViewHeight, menuWidth, 30)];
    self.backgroundColor = [UIColor clearColor];

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, menuWidth - 80, 30)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:12];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:switchLabel];

    // Add status label for ON/OFF
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(menuWidth - 70, 0, 60, 30)];
    statusLabel.text = @"OFF";
    statusLabel.textColor = [UIColor grayColor];
    statusLabel.font = [UIFont fontWithName:switchTitleFont size:12];
    statusLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:statusLabel];

    return self;
}

-(void)showInfo:(UIGestureRecognizer *)gestureRec {
    if(gestureRec.state == UIGestureRecognizerStateEnded) {
        [menu showPopup:[self getPreferencesKey] description:[self getDescription]];
        menu.layer.opacity = 0.0f;
    }
}

-(NSString *)getPreferencesKey {
    return preferencesKey;
}

-(NSString *)getDescription {
    return description;
}

- (std::vector<MemoryPatch>)getMemoryPatches {
    std::vector<MemoryPatch> patches;
    for(int i = 0; i < patchOffsets.size(); i++) {
        // Convert hex string to unsigned int
        unsigned int patchData;
        std::stringstream ss;
        ss << std::hex << patchBytes[i];
        ss >> patchData;
        
        // Apply patch using vm function with the converted data
        if(!vm(patchOffsets[i], patchData)) {
            [menu showPopup:@"Invalid patch" description:[NSString stringWithFormat:@"Failing offset: 0x%llx, please re-check the hex you entered.", patchOffsets[i]]];
        }
    }
    return patches;
}

- (std::vector<MemoryPatch>)getUnpatchMemoryPatches {
    std::vector<MemoryPatch> patches;
    for(int i = 0; i < unpatchOffsets.size(); i++) {
        // Convert hex string to unsigned int
        unsigned int unpatchData;
        std::stringstream ss;
        ss << std::hex << unpatchBytes[i];
        ss >> unpatchData;
        
        // Apply patch using vm function with the converted data
        if(!vm(unpatchOffsets[i], unpatchData)) {
            [menu showPopup:@"Invalid unpatch" description:[NSString stringWithFormat:@"Failing offset: 0x%llx, please re-check the hex you entered.", unpatchOffsets[i]]];
        }
    }
    return patches;
}

@end //end of OffsetSwitch class


/**************************************
    TEXTFIELD SWITCH STARTS HERE!
    - Note that this extends from OffsetSwitch.
***************************************/

@implementation TextFieldSwitch {
}

- (id)initTextfieldNamed:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;

    self = [super initWithFrame:CGRectMake(0, scrollViewX + scrollViewHeight, menuWidth, 30)];
    self.backgroundColor = [UIColor clearColor];

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, menuWidth - 80, 30)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:12];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:switchLabel];

    textfieldValue = [[UITextField alloc]initWithFrame:CGRectMake(menuWidth - 70, 5, 60, 20)];
    textfieldValue.layer.borderWidth = 1.0f;
    textfieldValue.layer.borderColor = [UIColor colorWithRed:171.0/255.0 green:137.0/255.0 blue:249.0/255.0 alpha:1.0].CGColor;
    textfieldValue.layer.cornerRadius = 5.0f;
    textfieldValue.textColor = switchTitleColor;
    textfieldValue.textAlignment = NSTextAlignmentCenter;
    textfieldValue.delegate = self;
    textfieldValue.backgroundColor = [menu.header.backgroundColor colorWithAlphaComponent:0.8];
    textfieldValue.font = [UIFont fontWithName:switchTitleFont size:12];

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        textfieldValue.text = [[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey];
    }

    [self addSubview:textfieldValue];

    return self;
}

// so when click "return" the keyboard goes way, got it from internet. Common thing apparantly
-(BOOL)textFieldShouldReturn:(UITextField*)textfieldValue_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    [defaults setObject:textfieldValue_.text forKey:[self getSwitchValueKey]];
    [textfieldValue_ resignFirstResponder];

    return true;
}

-(NSString *)getSwitchValueKey {
    return switchValueKey;
}

@end // end of TextFieldSwitch Class


/*******************************
    SLIDER SWITCH STARTS HERE!
    - Note that this extends from TextFieldSwitch
 *******************************/

@implementation SliderSwitch {
    UISlider *sliderValue;
    float valueOfSlider;
}

- (id)initSliderNamed:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_{
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 30)];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:14];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    sliderValue = [[UISlider alloc]initWithFrame:CGRectMake(menuWidth / 4 - 20, switchLabel.self.bounds.origin.x - 4 + switchLabel.self.bounds.size.height, menuWidth / 2 + 20, 20)];
    sliderValue.thumbTintColor = sliderColor_;
    sliderValue.minimumTrackTintColor = switchTitleColor;
    sliderValue.maximumTrackTintColor = switchTitleColor;
    sliderValue.minimumValue = minimumValue_;
    sliderValue.maximumValue = maximumValue_;
    sliderValue.continuous = true;
    [sliderValue addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueOfSlider = sliderValue.value;

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        sliderValue.value = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
        switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:sliderValue];

    return self;
}

-(void)sliderValueChanged:(UISlider *)slider_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", [self getPreferencesKey], slider_.value];
    [defaults setFloat:slider_.value forKey:[self getSwitchValueKey]];
}

@end // end of SliderSwitch class





@implementation Switches


-(void)addSwitch:(NSString *)hackName_ description:(NSString *)description_ {
    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:std::vector<uint64_t>{} patchBytes:std::vector<std::string>{}
        unpatchOffsets:std::vector<uint64_t>{} unpatchBytes:std::vector<std::string>{}];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::initializer_list<uint64_t>)patchOffsets_ patchBytes:(std::initializer_list<std::string>)patchBytes_
    unpatchOffsets:(std::initializer_list<uint64_t>)unpatchOffsets_ unpatchBytes:(std::initializer_list<std::string>)unpatchBytes_ {
    
    std::vector<uint64_t> patchOffsetVector;
    std::vector<std::string> patchBytesVector;
    std::vector<uint64_t> unpatchOffsetVector;
    std::vector<std::string> unpatchBytesVector;

    patchOffsetVector.insert(patchOffsetVector.begin(), patchOffsets_.begin(), patchOffsets_.end());
    patchBytesVector.insert(patchBytesVector.begin(), patchBytes_.begin(), patchBytes_.end());
    unpatchOffsetVector.insert(unpatchOffsetVector.begin(), unpatchOffsets_.begin(), unpatchOffsets_.end());
    unpatchBytesVector.insert(unpatchBytesVector.begin(), unpatchBytes_.begin(), unpatchBytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:patchOffsetVector patchBytes:patchBytesVector
        unpatchOffsets:unpatchOffsetVector unpatchBytes:unpatchBytesVector];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addTextfieldSwitch:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToMenu:textfieldSwitch];
}

- (void)addSliderSwitch:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToMenu:sliderSwitch];
}

- (NSString *)getValueFromSwitch:(NSString *)name {

    //getting the correct key for the saved input.
    NSString *correctKey =  [name stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];

    if([[NSUserDefaults standardUserDefaults] objectForKey:correctKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:correctKey];
    }
    else if([[NSUserDefaults standardUserDefaults] floatForKey:correctKey]) {
        NSString *sliderValue = [NSString stringWithFormat:@"%f", [[NSUserDefaults standardUserDefaults] floatForKey:correctKey]];
        return sliderValue;
    }

    return 0;
}

-(bool)isSwitchOn:(NSString *)switchName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:switchName];
}

- (void)addOffsetSwitchToSubMenu:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::initializer_list<uint64_t>)patchOffsets_ patchBytes:(std::initializer_list<std::string>)patchBytes_
    unpatchOffsets:(std::initializer_list<uint64_t>)unpatchOffsets_ unpatchBytes:(std::initializer_list<std::string>)unpatchBytes_
    subMenuIndex:(NSInteger)subMenuIndex {
    
    std::vector<uint64_t> patchOffsetVector;
    std::vector<std::string> patchBytesVector;
    std::vector<uint64_t> unpatchOffsetVector;
    std::vector<std::string> unpatchBytesVector;

    patchOffsetVector.insert(patchOffsetVector.begin(), patchOffsets_.begin(), patchOffsets_.end());
    patchBytesVector.insert(patchBytesVector.begin(), patchBytes_.begin(), patchBytes_.end());
    unpatchOffsetVector.insert(unpatchOffsetVector.begin(), unpatchOffsets_.begin(), unpatchOffsets_.end());
    unpatchBytesVector.insert(unpatchBytesVector.begin(), unpatchBytes_.begin(), unpatchBytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:patchOffsetVector patchBytes:patchBytesVector
        unpatchOffsets:unpatchOffsetVector unpatchBytes:unpatchBytesVector];
    [menu addSwitchToSubMenu:offsetPatch subMenuIndex:subMenuIndex];
}

- (void)addTextfieldSwitchToSubMenu:(NSString *)hackName_ description:(NSString *)description_ 
    inputBorderColor:(UIColor *)inputBorderColor_ subMenuIndex:(NSInteger)subMenuIndex {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToSubMenu:textfieldSwitch subMenuIndex:subMenuIndex];
}

- (void)addSliderSwitchToSubMenu:(NSString *)hackName_ description:(NSString *)description_ 
    minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_
    subMenuIndex:(NSInteger)subMenuIndex {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToSubMenu:sliderSwitch subMenuIndex:subMenuIndex];
}

// Self Menu methods
- (void)addOffsetSwitchToSelfMenu:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::initializer_list<uint64_t>)patchOffsets_ patchBytes:(std::initializer_list<std::string>)patchBytes_
    unpatchOffsets:(std::initializer_list<uint64_t>)unpatchOffsets_ unpatchBytes:(std::initializer_list<std::string>)unpatchBytes_ {
    
    std::vector<uint64_t> patchOffsetVector;
    std::vector<std::string> patchBytesVector;
    std::vector<uint64_t> unpatchOffsetVector;
    std::vector<std::string> unpatchBytesVector;

    patchOffsetVector.insert(patchOffsetVector.begin(), patchOffsets_.begin(), patchOffsets_.end());
    patchBytesVector.insert(patchBytesVector.begin(), patchBytes_.begin(), patchBytes_.end());
    unpatchOffsetVector.insert(unpatchOffsetVector.begin(), unpatchOffsets_.begin(), unpatchOffsets_.end());
    unpatchBytesVector.insert(unpatchBytesVector.begin(), unpatchBytes_.begin(), unpatchBytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:patchOffsetVector patchBytes:patchBytesVector
        unpatchOffsets:unpatchOffsetVector unpatchBytes:unpatchBytesVector];
    [menu addSwitchToSubMenu:offsetPatch subMenuIndex:0];
}

- (void)addTextfieldSwitchToSelfMenu:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToSubMenu:textfieldSwitch subMenuIndex:0];
}

- (void)addSliderSwitchToSelfMenu:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToSubMenu:sliderSwitch subMenuIndex:0];
}

// Weapon Menu methods
- (void)addOffsetSwitchToWeaponMenu:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::initializer_list<uint64_t>)patchOffsets_ patchBytes:(std::initializer_list<std::string>)patchBytes_
    unpatchOffsets:(std::initializer_list<uint64_t>)unpatchOffsets_ unpatchBytes:(std::initializer_list<std::string>)unpatchBytes_ {
    
    std::vector<uint64_t> patchOffsetVector;
    std::vector<std::string> patchBytesVector;
    std::vector<uint64_t> unpatchOffsetVector;
    std::vector<std::string> unpatchBytesVector;

    patchOffsetVector.insert(patchOffsetVector.begin(), patchOffsets_.begin(), patchOffsets_.end());
    patchBytesVector.insert(patchBytesVector.begin(), patchBytes_.begin(), patchBytes_.end());
    unpatchOffsetVector.insert(unpatchOffsetVector.begin(), unpatchOffsets_.begin(), unpatchOffsets_.end());
    unpatchBytesVector.insert(unpatchBytesVector.begin(), unpatchBytes_.begin(), unpatchBytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:patchOffsetVector patchBytes:patchBytesVector
        unpatchOffsets:unpatchOffsetVector unpatchBytes:unpatchBytesVector];
    [menu addSwitchToSubMenu:offsetPatch subMenuIndex:1];
}

- (void)addTextfieldSwitchToWeaponMenu:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToSubMenu:textfieldSwitch subMenuIndex:1];
}

- (void)addSliderSwitchToWeaponMenu:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToSubMenu:sliderSwitch subMenuIndex:1];
}

// GamePad Menu methods
- (void)addOffsetSwitchToGamePadMenu:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::initializer_list<uint64_t>)patchOffsets_ patchBytes:(std::initializer_list<std::string>)patchBytes_
    unpatchOffsets:(std::initializer_list<uint64_t>)unpatchOffsets_ unpatchBytes:(std::initializer_list<std::string>)unpatchBytes_ {
    
    std::vector<uint64_t> patchOffsetVector;
    std::vector<std::string> patchBytesVector;
    std::vector<uint64_t> unpatchOffsetVector;
    std::vector<std::string> unpatchBytesVector;

    patchOffsetVector.insert(patchOffsetVector.begin(), patchOffsets_.begin(), patchOffsets_.end());
    patchBytesVector.insert(patchBytesVector.begin(), patchBytes_.begin(), patchBytes_.end());
    unpatchOffsetVector.insert(unpatchOffsetVector.begin(), unpatchOffsets_.begin(), unpatchOffsets_.end());
    unpatchBytesVector.insert(unpatchBytesVector.begin(), unpatchBytes_.begin(), unpatchBytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:patchOffsetVector patchBytes:patchBytesVector
        unpatchOffsets:unpatchOffsetVector unpatchBytes:unpatchBytesVector];
    [menu addSwitchToSubMenu:offsetPatch subMenuIndex:2];
}

- (void)addTextfieldSwitchToGamePadMenu:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToSubMenu:textfieldSwitch subMenuIndex:2];
}

- (void)addSliderSwitchToGamePadMenu:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToSubMenu:sliderSwitch subMenuIndex:2];
}

// Menu Settings methods
- (void)addOffsetSwitchToMenuSettings:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::initializer_list<uint64_t>)patchOffsets_ patchBytes:(std::initializer_list<std::string>)patchBytes_
    unpatchOffsets:(std::initializer_list<uint64_t>)unpatchOffsets_ unpatchBytes:(std::initializer_list<std::string>)unpatchBytes_ {
    
    std::vector<uint64_t> patchOffsetVector;
    std::vector<std::string> patchBytesVector;
    std::vector<uint64_t> unpatchOffsetVector;
    std::vector<std::string> unpatchBytesVector;

    patchOffsetVector.insert(patchOffsetVector.begin(), patchOffsets_.begin(), patchOffsets_.end());
    patchBytesVector.insert(patchBytesVector.begin(), patchBytes_.begin(), patchBytes_.end());
    unpatchOffsetVector.insert(unpatchOffsetVector.begin(), unpatchOffsets_.begin(), unpatchOffsets_.end());
    unpatchBytesVector.insert(unpatchBytesVector.begin(), unpatchBytes_.begin(), unpatchBytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:patchOffsetVector patchBytes:patchBytesVector
        unpatchOffsets:unpatchOffsetVector unpatchBytes:unpatchBytesVector];
    [menu addSwitchToSubMenu:offsetPatch subMenuIndex:3];
}

- (void)addTextfieldSwitchToMenuSettings:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToSubMenu:textfieldSwitch subMenuIndex:3];
}

- (void)addSliderSwitchToMenuSettings:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToSubMenu:sliderSwitch subMenuIndex:3];
}

// Universal methods to add switches to sub-menu by name
- (void)addOffsetSwitchToSubMenuByName:(NSString *)hackName_ description:(NSString *)description_ 
    patchOffsets:(std::initializer_list<uint64_t>)patchOffsets_ patchBytes:(std::initializer_list<std::string>)patchBytes_
    unpatchOffsets:(std::initializer_list<uint64_t>)unpatchOffsets_ unpatchBytes:(std::initializer_list<std::string>)unpatchBytes_
    subMenuName:(NSString *)subMenuName_ {
    
    // Find sub-menu index by name
    NSInteger subMenuIndex = -1;
    for (NSInteger i = 0; i < menu.subMenus.count; i++) {
        if ([menu.subMenus[i] isEqualToString:subMenuName_]) {
            subMenuIndex = i;
            break;
        }
    }
    
    if (subMenuIndex == -1) {
        NSLog(@"Sub-menu with name '%@' not found!", subMenuName_);
        return;
    }
    
    std::vector<uint64_t> patchOffsetVector;
    std::vector<std::string> patchBytesVector;
    std::vector<uint64_t> unpatchOffsetVector;
    std::vector<std::string> unpatchBytesVector;

    patchOffsetVector.insert(patchOffsetVector.begin(), patchOffsets_.begin(), patchOffsets_.end());
    patchBytesVector.insert(patchBytesVector.begin(), patchBytes_.begin(), patchBytes_.end());
    unpatchOffsetVector.insert(unpatchOffsetVector.begin(), unpatchOffsets_.begin(), unpatchOffsets_.end());
    unpatchBytesVector.insert(unpatchBytesVector.begin(), unpatchBytes_.begin(), unpatchBytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:patchOffsetVector patchBytes:patchBytesVector
        unpatchOffsets:unpatchOffsetVector unpatchBytes:unpatchBytesVector];
    [menu addSwitchToSubMenu:offsetPatch subMenuIndex:subMenuIndex];
}

- (void)addTextfieldSwitchToSubMenuByName:(NSString *)hackName_ description:(NSString *)description_ 
    inputBorderColor:(UIColor *)inputBorderColor_ subMenuName:(NSString *)subMenuName_ {
    
    // Find sub-menu index by name
    NSInteger subMenuIndex = -1;
    for (NSInteger i = 0; i < menu.subMenus.count; i++) {
        if ([menu.subMenus[i] isEqualToString:subMenuName_]) {
            subMenuIndex = i;
            break;
        }
    }
    
    if (subMenuIndex == -1) {
        NSLog(@"Sub-menu with name '%@' not found!", subMenuName_);
        return;
    }
    
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToSubMenu:textfieldSwitch subMenuIndex:subMenuIndex];
}

- (void)addSliderSwitchToSubMenuByName:(NSString *)hackName_ description:(NSString *)description_ 
    minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_
    subMenuName:(NSString *)subMenuName_ {
    
    // Find sub-menu index by name
    NSInteger subMenuIndex = -1;
    for (NSInteger i = 0; i < menu.subMenus.count; i++) {
        if ([menu.subMenus[i] isEqualToString:subMenuName_]) {
            subMenuIndex = i;
            break;
        }
    }
    
    if (subMenuIndex == -1) {
        NSLog(@"Sub-menu with name '%@' not found!", subMenuName_);
        return;
    }
    
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToSubMenu:sliderSwitch subMenuIndex:subMenuIndex];
}

// New method for switches that don't use patching (like light bar controls)
- (void)addSimpleSwitchToSubMenuByName:(NSString *)hackName_ description:(NSString *)description_ 
    subMenuName:(NSString *)subMenuName_ {
    
    // Find sub-menu index by name
    NSInteger subMenuIndex = -1;
    for (NSInteger i = 0; i < menu.subMenus.count; i++) {
        if ([menu.subMenus[i] isEqualToString:subMenuName_]) {
            subMenuIndex = i;
            break;
        }
    }
    
    if (subMenuIndex == -1) {
        NSLog(@"Sub-menu with name '%@' not found!", subMenuName_);
        return;
    }
    
    // Create a simple switch without any patching functionality
    OffsetSwitch *simpleSwitch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ 
        patchOffsets:std::vector<uint64_t>{} patchBytes:std::vector<std::string>{}
        unpatchOffsets:std::vector<uint64_t>{} unpatchBytes:std::vector<std::string>{}];
    [menu addSwitchToSubMenu:simpleSwitch subMenuIndex:subMenuIndex];
}

@end
