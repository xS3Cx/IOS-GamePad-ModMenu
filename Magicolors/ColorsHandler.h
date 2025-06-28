#import <UIKit/UIKit.h>

extern CGColorRef RightGradient;
extern CGColorRef blackColor;
extern CGColorRef LeftGradient;

@interface Colors : NSObject

+ (void)initializeColors;
+ (UIColor *)colorFromString:(NSString *)colorString defaultColor:(UIColor *)defaultColor;
+ (void)cleanup;

@end
