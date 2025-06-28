#import "GamepadInput.h"

@implementation GamepadInput

static BOOL isMonitoring = NO;
static BOOL isMenuVisible = NO;

+ (void)startMonitoring {
    if (isMonitoring) return;
    
    isMonitoring = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleControllerConnection:)
                                               name:GCControllerDidConnectNotification
                                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleControllerDisconnection:)
                                               name:GCControllerDidDisconnectNotification
                                             object:nil];
    
    for (GCController *controller in [GCController controllers]) {
        [self setupController:controller];
    }
}

+ (void)stopMonitoring {
    if (!isMonitoring) return;
    
    isMonitoring = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)handleControllerConnection:(NSNotification *)notification {
    [self setupController:notification.object];
}

+ (void)handleControllerDisconnection:(NSNotification *)notification {
}

+ (void)setupController:(GCController *)controller {
    if (!controller.extendedGamepad) return;
    
    GCExtendedGamepad *gamepad = controller.extendedGamepad;
    
    gamepad.leftShoulder.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) {
            isMenuVisible = !isMenuVisible;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GamepadInputNotification"
                                                              object:nil
                                                            userInfo:@{@"action": isMenuVisible ? @"show" : @"hide"}];
        }
    };
    
    void (^dpadHandler)(NSString *) = ^(NSString *action) {
        if (isMenuVisible) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GamepadInputNotification"
                                                              object:nil
                                                            userInfo:@{@"action": action}];
        }
    };
    
    gamepad.dpad.up.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) dpadHandler(@"up");
    };
    
    gamepad.dpad.down.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) dpadHandler(@"down");
    };

    gamepad.dpad.left.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) dpadHandler(@"left");
    };

    gamepad.dpad.right.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) dpadHandler(@"right");
    };
    
    gamepad.buttonX.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed && isMenuVisible) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GamepadInputNotification"
                                                              object:nil
                                                            userInfo:@{@"action": @"select"}];
        }
    };

    gamepad.buttonB.pressedChangedHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed && isMenuVisible) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GamepadInputNotification"
                                                              object:nil
                                                            userInfo:@{@"action": @"back"}];
        }
    };
}

@end 