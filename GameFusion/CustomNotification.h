#import <UIKit/UIKit.h>

@interface CustomNotification : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *iconBarView;
@property (nonatomic, strong) UIView *greenLine;

- (instancetype)initWithHeaderColor:(UIColor *)headerColor;
- (void)showWithTitle:(NSString *)title description:(NSString *)descriptionText headerColor:(UIColor *)headerColor;
- (void)hide;

+ (void)showNotificationWithTitle:(NSString *)title description:(NSString *)descriptionText headerColor:(UIColor *)headerColor;

@end 