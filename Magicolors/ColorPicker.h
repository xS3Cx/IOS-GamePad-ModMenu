#import <UIKit/UIKit.h>

@interface ColorPickerViewController : UIViewController

@property (nonatomic, copy) void (^colorSelectedHandler)(UIColor *color, NSString *gradientType);

- (void)controllerButtonPressed:(NSString *)button;

@end 