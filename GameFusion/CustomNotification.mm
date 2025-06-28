#import <UIKit/UIKit.h>
#import "HVIcons/Heaven.h"

#define NOTIF_GREEN [UIColor colorWithRed:194.0/255.0 green:153.0/255.0 blue:247.0/255.0 alpha:1.0]

@interface CustomNotification : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *iconBarView;
@property (nonatomic, strong) UIView *greenLine;

+ (NSMutableArray *)activeNotifications;
- (void)showWithTitle:(NSString *)title description:(NSString *)descriptionText headerColor:(UIColor *)headerColor;
- (void)hide;

@end

@implementation CustomNotification

static NSMutableArray *_activeNotifications;

+ (NSMutableArray *)activeNotifications {
    if (!_activeNotifications) {
        _activeNotifications = [NSMutableArray array];
    }
    return _activeNotifications;
}

- (instancetype)initWithHeaderColor:(UIColor *)headerColor {
    self = [super init];
    if (self) {
        [self setupViewWithHeaderColor:headerColor];
    }
    return self;
}

- (void)setupViewWithHeaderColor:(UIColor *)headerColor {
    // Container
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:0.6];
    self.containerView.layer.cornerRadius = 12.0f;
    self.containerView.clipsToBounds = YES;
    [self addSubview:self.containerView];

    // Pasek po lewej
    self.iconBarView = [[UIView alloc] init];
    self.iconBarView.backgroundColor = headerColor;
    [self.containerView addSubview:self.iconBarView];

    // Zaokrąglone rogi tylko z lewej strony
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,50,100)
                                                   byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(12,12)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    self.iconBarView.layer.mask = maskLayer;

    // Ikona
    NSData* data = [[NSData alloc] initWithBase64EncodedString:[Heaven HEAVEN_ICON] options:0];
    UIImage* menuIconImage = [UIImage imageWithData:data];
    self.iconImageView = [[UIImageView alloc] initWithImage:menuIconImage];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.iconBarView addSubview:self.iconImageView];

    // Tytuł (GameFusion > NazwaSwitcha)
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.numberOfLines = 1;
    [self.containerView addSubview:self.titleLabel];

    // Zielona linia
    self.greenLine = [[UIView alloc] init];
    self.greenLine.backgroundColor = NOTIF_GREEN;
    [self.containerView addSubview:self.greenLine];

    // Description (na dole)
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.descriptionLabel.font = [UIFont systemFontOfSize:14];
    self.descriptionLabel.numberOfLines = 2;
    [self.containerView addSubview:self.descriptionLabel];

    // Tap to dismiss
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:tapGesture];
}

- (void)showWithTitle:(NSString *)title description:(NSString *)descriptionText headerColor:(UIColor *)headerColor {
    self.titleLabel.text = title;
    self.descriptionLabel.text = descriptionText;

    self.iconBarView.backgroundColor = headerColor;

    CGFloat padding = 10.0f;
    CGFloat barWidth = 50.0f;
    CGFloat width = 340.0f;
    CGFloat titleHeight = 20.0f;
    CGFloat lineHeight = 2.0f;
    CGFloat descHeight = 30.0f;
    CGFloat spacing = 1.0f;
    CGFloat totalHeight = padding + titleHeight + spacing + lineHeight + spacing + descHeight + padding;

    self.containerView.frame = CGRectMake(0, 0, width, totalHeight);
    self.iconBarView.frame = CGRectMake(0, 0, barWidth, totalHeight);
    
    // Zaokrągl maskę na nowo
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.iconBarView.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(12,12)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    self.iconBarView.layer.mask = maskLayer;

    // Ikona wyśrodkowana na pasku
    CGFloat iconSize = 28.0f;
    self.iconImageView.frame = CGRectMake((barWidth-iconSize)/2, (totalHeight-iconSize)/2, iconSize, iconSize);

    CGFloat textX = barWidth + padding/2;
    CGFloat textWidth = width - textX - padding/2;
    self.titleLabel.frame = CGRectMake(textX, padding, textWidth, titleHeight);
    self.greenLine.frame = CGRectMake(textX, CGRectGetMaxY(self.titleLabel.frame) + spacing, textWidth, lineHeight);
    self.descriptionLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.greenLine.frame) + spacing, textWidth, descHeight);

    // Oblicz pozycję Y na podstawie liczby aktywnych powiadomień
    CGFloat baseY = UIApplication.sharedApplication.statusBarFrame.size.height + 20.0f;
    CGFloat spacingBetweenNotifications = 10.0f;
    CGFloat y = baseY + ([CustomNotification.activeNotifications count] * (totalHeight + spacingBetweenNotifications));
    
    // Start offscreen right
    self.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width, y, width, totalHeight);

    // Dodaj do aktywnych powiadomień
    [CustomNotification.activeNotifications addObject:self];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];

    // Animate in
    self.greenLine.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.45 delay:0.0 usingSpringWithDamping:0.85 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width - width - 16.0f, y, width, totalHeight);
    } completion:nil];

    // Animate progress bar
    CGFloat displayDuration = 2.5; // Duration in seconds
    [UIView animateWithDuration:displayDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.greenLine.transform = CGAffineTransformMakeScale(0.01, 1.0);
    } completion:^(BOOL finished) {
        [self hide];
    }];
}

- (void)hide {
    // Animacja znikania całego powiadomienia
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        // Usuń z aktywnych powiadomień
        [CustomNotification.activeNotifications removeObject:self];
        
        // Przesuń pozostałe powiadomienia w górę
        CGFloat baseY = UIApplication.sharedApplication.statusBarFrame.size.height + 20.0f;
        CGFloat spacingBetweenNotifications = 10.0f;
        
        for (NSInteger i = 0; i < [CustomNotification.activeNotifications count]; i++) {
            CustomNotification *notification = CustomNotification.activeNotifications[i];
            CGFloat newY = baseY + (i * (notification.frame.size.height + spacingBetweenNotifications));
            
            [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                notification.frame = CGRectMake(notification.frame.origin.x, newY, notification.frame.size.width, notification.frame.size.height);
            } completion:nil];
        }
        
        [self removeFromSuperview];
    }];
}

@end 