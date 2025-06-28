#import "ControllerLight.h"
#import <Foundation/Foundation.h>
#import <GameController/GameController.h>
#import <GameController/GCColor.h>

// RGB Cycle variables
static BOOL isRGBCycleEnabled = NO;
static NSTimer *rgbCycleTimer = nil;
static float currentHue = 0.0f;

// Police Lights variables
static BOOL isPoliceLightsEnabled = NO;
static NSTimer *policeLightsTimer = nil;
static BOOL isRedPhase = YES;

// Breathing Effect variables
static BOOL isBreathingEnabled = NO;
static NSTimer *breathingTimer = nil;
static float breathingIntensity = 0.0f;
static float breathingDirection = 1.0f;
static float breathingRed = 0.0f;
static float breathingGreen = 0.0f;
static float breathingBlue = 0.0f;

// Rainbow Wave variables
static BOOL isRainbowWaveEnabled = NO;
static NSTimer *rainbowWaveTimer = nil;
static float rainbowWaveOffset = 0.0f;

// Strobe Effect variables
static BOOL isStrobeEnabled = NO;
static NSTimer *strobeTimer = nil;
static BOOL isStrobeOn = YES;

// Pulse Effect variables
static BOOL isPulseEnabled = NO;
static NSTimer *pulseTimer = nil;
static float pulseIntensity = 0.0f;
static float pulseDirection = 1.0f;
static float pulseRed = 0.0f;
static float pulseGreen = 0.0f;
static float pulseBlue = 0.0f;

void setControllerLightColor(float red, float green, float blue) {
    for (GCController *controller in [GCController controllers]) {
        if (@available(iOS 14.0, *)) {
            if (controller.light) {
                [controller.light setColor:[[GCColor alloc] initWithRed:red green:green blue:blue]];
            }
        }
    }
}

void startRGBCycle() {
    if (rgbCycleTimer) return;
    
    isRGBCycleEnabled = YES;
    rgbCycleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer) {
        if (!isRGBCycleEnabled) {
            [timer invalidate];
            rgbCycleTimer = nil;
            return;
        }
        
        float h = currentHue;
        float c = 1.0f;
        float x = c * (1.0f - fabsf(fmodf(h * 6.0f, 2.0f) - 1.0f));
        
        float r, g, b;
        if (h < 1.0f/6.0f) {
            r = c; g = x; b = 0;
        } else if (h < 2.0f/6.0f) {
            r = x; g = c; b = 0;
        } else if (h < 3.0f/6.0f) {
            r = 0; g = c; b = x;
        } else if (h < 4.0f/6.0f) {
            r = 0; g = x; b = c;
        } else if (h < 5.0f/6.0f) {
            r = x; g = 0; b = c;
        } else {
            r = c; g = 0; b = x;
        }
        
        setControllerLightColor(r, g, b);
        
        currentHue += 0.01f;
        if (currentHue >= 1.0f) currentHue = 0.0f;
    }];
}

void stopRGBCycle() {
    isRGBCycleEnabled = NO;
    if (rgbCycleTimer) {
        [rgbCycleTimer invalidate];
        rgbCycleTimer = nil;
    }
}

void startPoliceLights() {
    if (policeLightsTimer) return;
    
    isPoliceLightsEnabled = YES;
    policeLightsTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer *timer) {
        if (!isPoliceLightsEnabled) {
            [timer invalidate];
            policeLightsTimer = nil;
            return;
        }
        
        if (isRedPhase) {
            setControllerLightColor(1.0f, 0.0f, 0.0f); // Red
        } else {
            setControllerLightColor(0.0f, 0.0f, 1.0f); // Blue
        }
        
        isRedPhase = !isRedPhase;
    }];
}

void stopPoliceLights() {
    isPoliceLightsEnabled = NO;
    if (policeLightsTimer) {
        [policeLightsTimer invalidate];
        policeLightsTimer = nil;
    }
}

void startBreathingEffect(float red, float green, float blue) {
    if (breathingTimer) return;
    
    breathingRed = red;
    breathingGreen = green;
    breathingBlue = blue;
    breathingIntensity = 0.0f;
    breathingDirection = 1.0f;
    isBreathingEnabled = YES;
    
    breathingTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer *timer) {
        if (!isBreathingEnabled) {
            [timer invalidate];
            breathingTimer = nil;
            return;
        }
        
        float intensity = 0.1f + (0.9f * breathingIntensity);
        setControllerLightColor(breathingRed * intensity, breathingGreen * intensity, breathingBlue * intensity);
        
        breathingIntensity += 0.02f * breathingDirection;
        if (breathingIntensity >= 1.0f) {
            breathingIntensity = 1.0f;
            breathingDirection = -1.0f;
        } else if (breathingIntensity <= 0.0f) {
            breathingIntensity = 0.0f;
            breathingDirection = 1.0f;
        }
    }];
}

void stopBreathingEffect() {
    isBreathingEnabled = NO;
    if (breathingTimer) {
        [breathingTimer invalidate];
        breathingTimer = nil;
    }
}

void startRainbowWave() {
    if (rainbowWaveTimer) return;
    
    isRainbowWaveEnabled = YES;
    rainbowWaveOffset = 0.0f;
    
    rainbowWaveTimer = [NSTimer scheduledTimerWithTimeInterval:0.08 repeats:YES block:^(NSTimer *timer) {
        if (!isRainbowWaveEnabled) {
            [timer invalidate];
            rainbowWaveTimer = nil;
            return;
        }
        
        float h = fmodf(rainbowWaveOffset, 1.0f);
        float c = 1.0f;
        float x = c * (1.0f - fabsf(fmodf(h * 6.0f, 2.0f) - 1.0f));
        
        float r, g, b;
        if (h < 1.0f/6.0f) {
            r = c; g = x; b = 0;
        } else if (h < 2.0f/6.0f) {
            r = x; g = c; b = 0;
        } else if (h < 3.0f/6.0f) {
            r = 0; g = c; b = x;
        } else if (h < 4.0f/6.0f) {
            r = 0; g = x; b = c;
        } else if (h < 5.0f/6.0f) {
            r = x; g = 0; b = c;
        } else {
            r = c; g = 0; b = x;
        }
        
        setControllerLightColor(r, g, b);
        
        rainbowWaveOffset += 0.02f;
    }];
}

void stopRainbowWave() {
    isRainbowWaveEnabled = NO;
    if (rainbowWaveTimer) {
        [rainbowWaveTimer invalidate];
        rainbowWaveTimer = nil;
    }
}

void startStrobeEffect() {
    if (strobeTimer) return;
    
    isStrobeEnabled = YES;
    isStrobeOn = YES;
    
    strobeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer) {
        if (!isStrobeEnabled) {
            [timer invalidate];
            strobeTimer = nil;
            return;
        }
        
        if (isStrobeOn) {
            setControllerLightColor(1.0f, 1.0f, 1.0f); // White
        } else {
            setControllerLightColor(0.0f, 0.0f, 0.0f); // Off
        }
        
        isStrobeOn = !isStrobeOn;
    }];
}

void stopStrobeEffect() {
    isStrobeEnabled = NO;
    if (strobeTimer) {
        [strobeTimer invalidate];
        strobeTimer = nil;
    }
}

void startPulseEffect(float red, float green, float blue) {
    if (pulseTimer) return;
    
    pulseRed = red;
    pulseGreen = green;
    pulseBlue = blue;
    pulseIntensity = 0.0f;
    pulseDirection = 1.0f;
    isPulseEnabled = YES;
    
    pulseTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 repeats:YES block:^(NSTimer *timer) {
        if (!isPulseEnabled) {
            [timer invalidate];
            pulseTimer = nil;
            return;
        }
        
        float intensity = 0.2f + (0.8f * pulseIntensity);
        setControllerLightColor(pulseRed * intensity, pulseGreen * intensity, pulseBlue * intensity);
        
        pulseIntensity += 0.03f * pulseDirection;
        if (pulseIntensity >= 1.0f) {
            pulseIntensity = 1.0f;
            pulseDirection = -1.0f;
        } else if (pulseIntensity <= 0.0f) {
            pulseIntensity = 0.0f;
            pulseDirection = 1.0f;
        }
    }];
}

void stopPulseEffect() {
    isPulseEnabled = NO;
    if (pulseTimer) {
        [pulseTimer invalidate];
        pulseTimer = nil;
    }
} 