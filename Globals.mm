#import "Globals.h"

// Initialize gradient colors
void initializeGradientColors(void) {
    [Colors initializeColors];
}

// Get gradient colors array
NSArray* getGradientColors(void) {
    return @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
}

// Get gradient locations
NSArray* getGradientLocations(void) {
    return @[@0.0, @0.3, @0.7, @1.0];
}

// Get gradient start and end points
CGPoint getGradientStartPoint(void) {
    return CGPointMake(0, 0.5);
}

CGPoint getGradientEndPoint(void) {
    return CGPointMake(1, 0.5);
} 