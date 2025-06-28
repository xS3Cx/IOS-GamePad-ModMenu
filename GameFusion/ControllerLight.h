#ifndef ControllerLight_h
#define ControllerLight_h

#ifdef __cplusplus
extern "C" {
#endif

void setControllerLightColor(float red, float green, float blue);
void startRGBCycle(void);
void stopRGBCycle(void);
void startPoliceLights(void);
void stopPoliceLights(void);
void startBreathingEffect(float red, float green, float blue);
void stopBreathingEffect(void);
void startRainbowWave(void);
void stopRainbowWave(void);
void startStrobeEffect(void);
void stopStrobeEffect(void);
void startPulseEffect(float red, float green, float blue);
void stopPulseEffect(void);

#ifdef __cplusplus
}
#endif

#endif /* ControllerLight_h */ 