#ifndef Globals_h
#define Globals_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Magicolors/ColorsHandler.h"

// Gradient color variables
extern CGColorRef RightGradient;
extern CGColorRef blackColor;
extern CGColorRef LeftGradient;

// Function declarations
void initializeGradientColors(void);
NSArray* getGradientColors(void);
NSArray* getGradientLocations(void);
CGPoint getGradientStartPoint(void);
CGPoint getGradientEndPoint(void);

#endif /* Globals_h */
