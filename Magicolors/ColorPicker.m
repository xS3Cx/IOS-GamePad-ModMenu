#import "ColorPicker.h"
#import "Magicolors/ColorsHandler.h"
#import <objc/runtime.h>

// --- KONTROLER: obsługa i focus ---
typedef NS_ENUM(NSInteger, ColorPickerFocus) {
    ColorPickerFocusSegment = 0,
    ColorPickerFocusColorSlider,
    ColorPickerFocusSaturationSlider,
    ColorPickerFocusBrightnessSlider,
    ColorPickerFocusAlphaSlider,
    ColorPickerFocusPick,
    ColorPickerFocusSave,
    ColorPickerFocusCancel,
    ColorPickerFocusCount
};

@interface ColorPickerViewController () {
    ColorPickerFocus _focusIndex;
    NSArray *_focusOrder;
    UIView *_focusHighlight;
}
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UISegmentedControl *gradientSegment;
@property (nonatomic, strong) UISlider *colorSlider;
@property (nonatomic, strong) UISlider *saturationSlider;
@property (nonatomic, strong) UISlider *brightnessSlider;
@property (nonatomic, strong) UISlider *alphaSlider;
@property (nonatomic, strong) NSCache *thumbImageCache;
@property (nonatomic, strong) UIView *colorPreviewView;
@property (nonatomic, strong) UIButton *colorPickerButton;
@property (nonatomic, strong) UIButton *favoriteColorsButton;
@property (nonatomic, strong) UIView *favoritesContainer;
@property (nonatomic, strong) NSMutableArray *favoriteColors;
@end

@implementation ColorPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _thumbImageCache = [[NSCache alloc] init];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
    
    // Główny kontener
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 300)];
    _containerView.center = self.view.center;
    _containerView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    _containerView.layer.cornerRadius = 20;
    _containerView.clipsToBounds = YES;
    [self.view addSubview:_containerView];

    // Dodaj tylko linie gradientowe na górze i dole kontenera
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(0, 0, _containerView.frame.size.width, 1.5);
    topGradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    topGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    topGradient.startPoint = CGPointMake(0, 0.5);
    topGradient.endPoint = CGPointMake(1, 0.5);
    [_containerView.layer addSublayer:topGradient];

    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = CGRectMake(0, _containerView.frame.size.height - 1.5, _containerView.frame.size.width, 1.5);
    bottomGradient.colors = topGradient.colors;
    bottomGradient.locations = topGradient.locations;
    bottomGradient.startPoint = topGradient.startPoint;
    bottomGradient.endPoint = topGradient.endPoint;
    [_containerView.layer addSublayer:bottomGradient];

    // Tytuł
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _containerView.frame.size.width, 20)];
    titleLabel.text = @"NINJA FRAMEWORK";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    [_containerView addSubview:titleLabel];

    // Podtytuł
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, _containerView.frame.size.width, 15)];
    subtitleLabel.text = @"Color Picker";
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor lightGrayColor];
    subtitleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    [_containerView addSubview:subtitleLabel];

    // Kontener dla segmentu z gradientem
    UIView *segmentContainer = [[UIView alloc] initWithFrame:CGRectMake((_containerView.frame.size.width - (_containerView.frame.size.width - 120)) / 2, 50, _containerView.frame.size.width - 120, 25)];
    segmentContainer.layer.cornerRadius = 10;
    segmentContainer.clipsToBounds = YES;
    [_containerView addSubview:segmentContainer];

    // Dodaj gradienty do kontenera segmentu (tło + linie)
    [self addGradientsWithBackgroundToView:segmentContainer];

    // Segment Control ze zmienioną kolejnością
    _gradientSegment = [[UISegmentedControl alloc] initWithItems:@[@"Left", @"Both", @"Right"]];
    _gradientSegment.frame = CGRectMake(2, 2, segmentContainer.frame.size.width - 4, segmentContainer.frame.size.height - 4);
    _gradientSegment.selectedSegmentIndex = 1;  // Domyślnie "Both"
    
    // Dostosuj wygląd segmentu
    _gradientSegment.backgroundColor = [UIColor clearColor];
    [_gradientSegment setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont fontWithName:@"ArialRoundedMTBold" size:12],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    } forState:UIControlStateNormal];
    [_gradientSegment setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont fontWithName:@"ArialRoundedMTBold" size:12],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    } forState:UIControlStateSelected];
    
    // Usuń domyślne tło segmentu
    _gradientSegment.layer.borderWidth = 0;
    _gradientSegment.layer.borderColor = [UIColor clearColor].CGColor;
    
    [_gradientSegment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentContainer addSubview:_gradientSegment];

    // Zmienne dla wszystkich sliderów
    float sliderHeight = 20;
    float sliderSpacing = 35;
    float sliderWidth = _containerView.frame.size.width - 190;
    float sliderX = (_containerView.frame.size.width - sliderWidth) / 2;
    float labelWidth = 70; // Szerokość dla etykiet
    float labelX = sliderX - labelWidth - 10; // 10px odstępu między etykietą a sliderem

    // Suwak kolorów (RGB)
    _colorSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, 120, sliderWidth, sliderHeight)];
    _colorSlider.minimumValue = 0.0;
    _colorSlider.maximumValue = 1.0;
    _colorSlider.value = 0.0;
    
    _colorSlider.layer.cornerRadius = 10;
    _colorSlider.layer.masksToBounds = YES;
    
    // Tworzenie gradientu dla suwaka
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, _colorSlider.frame.size.width, 20);
    gradientLayer.cornerRadius = 10;
    gradientLayer.colors = @[
        (__bridge id)[UIColor redColor].CGColor,
        (__bridge id)[UIColor yellowColor].CGColor,
        (__bridge id)[UIColor greenColor].CGColor,
        (__bridge id)[UIColor cyanColor].CGColor,
        (__bridge id)[UIColor blueColor].CGColor,
        (__bridge id)[UIColor magentaColor].CGColor,
        (__bridge id)[UIColor redColor].CGColor
    ];
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    
    UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, NO, 0.0);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_colorSlider setMinimumTrackImage:gradientImage forState:UIControlStateNormal];
    [_colorSlider setMaximumTrackImage:gradientImage forState:UIControlStateNormal];
    
    [_colorSlider addTarget:self action:@selector(colorSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_containerView addSubview:_colorSlider];

    // Saturation - obok slidera
    UILabel *saturationLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 160 + 2, labelWidth, 15)];
    saturationLabel.text = @"Saturation";
    saturationLabel.textAlignment = NSTextAlignmentRight;
    saturationLabel.textColor = [UIColor whiteColor];
    saturationLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10];
    [_containerView addSubview:saturationLabel];
    
    _saturationSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, 160, sliderWidth, sliderHeight)];
    _saturationSlider.minimumValue = 0.0;
    _saturationSlider.maximumValue = 1.0;
    _saturationSlider.value = 1.0;
    [_saturationSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_containerView addSubview:_saturationSlider];
    
    // Konfiguracja dla saturation slidera
    _saturationSlider.layer.cornerRadius = 10; // Połowa wysokości
    _saturationSlider.layer.masksToBounds = YES;
    [self styleSlider:_saturationSlider];

    // Brightness - obok slidera
    UILabel *brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 160 + sliderSpacing + 2, labelWidth, 15)];
    brightnessLabel.text = @"Brightness";
    brightnessLabel.textAlignment = NSTextAlignmentRight;
    brightnessLabel.textColor = [UIColor whiteColor];
    brightnessLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10];
    [_containerView addSubview:brightnessLabel];
    
    _brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, 160 + sliderSpacing, sliderWidth, sliderHeight)];
    _brightnessSlider.minimumValue = 0.0;
    _brightnessSlider.maximumValue = 1.0;
    _brightnessSlider.value = 1.0;
    [_brightnessSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_containerView addSubview:_brightnessSlider];
    
    // Konfiguracja dla brightness slidera
    _brightnessSlider.layer.cornerRadius = 10;
    _brightnessSlider.layer.masksToBounds = YES;
    [self styleSlider:_brightnessSlider];

    // Alpha - obok slidera
    UILabel *alphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 160 + (sliderSpacing * 2) + 2, labelWidth, 15)];
    alphaLabel.text = @"Opacity";
    alphaLabel.textAlignment = NSTextAlignmentRight;
    alphaLabel.textColor = [UIColor whiteColor];
    alphaLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10];
    [_containerView addSubview:alphaLabel];
    
    _alphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, 160 + (sliderSpacing * 2), sliderWidth, sliderHeight)];
    _alphaSlider.minimumValue = 0.0;
    _alphaSlider.maximumValue = 1.0;
    _alphaSlider.value = 1.0;
    [_alphaSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_containerView addSubview:_alphaSlider];
    
    // Konfiguracja dla alpha slidera
    _alphaSlider.layer.cornerRadius = 10;
    _alphaSlider.layer.masksToBounds = YES;
    [self styleSlider:_alphaSlider];

    [self updateThumbColor];

    // Przyciski w jednym rzędzie
    CGFloat buttonWidth = 120;
    CGFloat buttonHeight = 35;
    CGFloat buttonSpacing = 20;
    CGFloat totalWidth = (buttonWidth * 3) + (buttonSpacing * 2);
    CGFloat startX = (_containerView.frame.size.width - totalWidth) / 2;
    CGFloat buttonY = _containerView.frame.size.height - 45;

    // Cancel button
    UIView *cancelContainer = [[UIView alloc] initWithFrame:CGRectMake(startX, buttonY, buttonWidth, buttonHeight)];
    cancelContainer.layer.cornerRadius = 10;
    cancelContainer.clipsToBounds = YES;
    [_containerView addSubview:cancelContainer];

    // Pick Color button
    UIView *pickColorContainer = [[UIView alloc] initWithFrame:CGRectMake(startX + buttonWidth + buttonSpacing, buttonY, buttonWidth, buttonHeight)];
    pickColorContainer.layer.cornerRadius = 10;
    pickColorContainer.clipsToBounds = YES;
    [_containerView addSubview:pickColorContainer];

    // Save button
    UIView *saveContainer = [[UIView alloc] initWithFrame:CGRectMake(startX + (buttonWidth + buttonSpacing) * 2, buttonY, buttonWidth, buttonHeight)];
    saveContainer.layer.cornerRadius = 10;
    saveContainer.clipsToBounds = YES;
    [_containerView addSubview:saveContainer];

    [self addGradientsWithBackgroundToView:cancelContainer];
    [self addGradientsWithBackgroundToView:pickColorContainer];
    [self addGradientsWithBackgroundToView:saveContainer];

    // Cancel button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = cancelContainer.bounds;
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelContainer addSubview:cancelButton];

    // Pick Color button
    _colorPickerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _colorPickerButton.frame = pickColorContainer.bounds;

    // Add icon and text
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    UIImage *eyedropperImage = [UIImage systemImageNamed:@"eyedropper" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:15]];
    attachment.image = [eyedropperImage imageWithTintColor:[UIColor whiteColor]];
    attachment.bounds = CGRectMake(0, -3, 15, 15);

    NSMutableAttributedString *buttonText = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [buttonText appendAttributedString:[[NSAttributedString alloc] initWithString:@" Pick"]];

    [_colorPickerButton setAttributedTitle:buttonText forState:UIControlStateNormal];
    [_colorPickerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_colorPickerButton addTarget:self action:@selector(startColorPicker) forControlEvents:UIControlEventTouchUpInside];
    [pickColorContainer addSubview:_colorPickerButton];

    // Save button
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.frame = saveContainer.bounds;
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveColor:) forControlEvents:UIControlEventTouchUpInside];
    [saveContainer addSubview:saveButton];

    [self loadCurrentColor];

    [self setupColorPreview];

    // Dodaj obserwatory zmian dla wszystkich suwaków
    [_colorSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_saturationSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_brightnessSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_alphaSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];

    // --- KONTROLER: focus init ---
    _focusOrder = @[ _gradientSegment, _colorSlider, _saturationSlider, _brightnessSlider, _alphaSlider, _colorPickerButton ];
    // Save/Cancel buttons
    UIButton *saveBtn = nil, *cancelBtn = nil;
    for (UIView *v in _containerView.subviews) {
        if ([v isKindOfClass:[UIView class]]) {
            for (UIView *sub in v.subviews) {
                if ([sub isKindOfClass:[UIButton class]]) {
                    UIButton *b = (UIButton *)sub;
                    if ([b.currentTitle isEqualToString:@"Save"]) saveBtn = b;
                    if ([b.currentTitle isEqualToString:@"Cancel"]) cancelBtn = b;
                }
            }
        }
    }
    if (saveBtn && cancelBtn) {
        _focusOrder = [_focusOrder arrayByAddingObjectsFromArray:@[saveBtn, cancelBtn]];
    }
    _focusIndex = ColorPickerFocusSegment;
    [self updateFocusHighlight];
}

- (void)updateFocusHighlight {
    if (_focusHighlight) [_focusHighlight removeFromSuperview];
    UIView *target = _focusOrder[_focusIndex];
    CGRect frame = [self.view convertRect:target.bounds fromView:target];
    _focusHighlight = [[UIView alloc] initWithFrame:frame];
    _focusHighlight.layer.borderColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0].CGColor;
    _focusHighlight.layer.borderWidth = 3.0;
    _focusHighlight.layer.cornerRadius = 8.0;
    _focusHighlight.userInteractionEnabled = NO;
    _focusHighlight.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.13];
    [self.view addSubview:_focusHighlight];
    [self.view bringSubviewToFront:_focusHighlight];
}

- (void)moveFocus:(NSInteger)delta {
    NSInteger newIndex = _focusIndex + delta;
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= _focusOrder.count) newIndex = _focusOrder.count-1;
    if (newIndex != _focusIndex) {
        _focusIndex = newIndex;
        [self updateFocusHighlight];
    }
}

- (void)controllerButtonPressed:(NSString *)button {
    if ([button isEqualToString:@"up"]) {
        [self moveFocus:-1];
    } else if ([button isEqualToString:@"down"]) {
        [self moveFocus:1];
    } else if ([button isEqualToString:@"left"]) {
        [self adjustCurrentSlider:-1];
    } else if ([button isEqualToString:@"right"]) {
        [self adjustCurrentSlider:1];
    } else if ([button isEqualToString:@"x"]) {
        [self activateCurrentFocus];
    } else if ([button isEqualToString:@"b"]) {
        [self cancel];
    }
}

- (void)adjustCurrentSlider:(NSInteger)dir {
    UISlider *slider = nil;
    if (_focusIndex == ColorPickerFocusColorSlider) slider = _colorSlider;
    else if (_focusIndex == ColorPickerFocusSaturationSlider) slider = _saturationSlider;
    else if (_focusIndex == ColorPickerFocusBrightnessSlider) slider = _brightnessSlider;
    else if (_focusIndex == ColorPickerFocusAlphaSlider) slider = _alphaSlider;
    if (slider) {
        float step = 0.01f * (dir > 0 ? 1 : -1);
        float newValue = slider.value + step;
        newValue = fmaxf(slider.minimumValue, fminf(slider.maximumValue, newValue));
        slider.value = newValue;
        [self sliderChanged:slider];
    } else if (_focusIndex == ColorPickerFocusSegment) {
        NSInteger idx = _gradientSegment.selectedSegmentIndex + dir;
        if (idx < 0) idx = 0;
        if (idx >= _gradientSegment.numberOfSegments) idx = _gradientSegment.numberOfSegments-1;
        if (idx != _gradientSegment.selectedSegmentIndex) {
            _gradientSegment.selectedSegmentIndex = idx;
            [self segmentChanged:_gradientSegment];
        }
    }
}

- (void)activateCurrentFocus {
    if (_focusIndex == ColorPickerFocusSegment) {
        // Przełącz segment
        NSInteger idx = _gradientSegment.selectedSegmentIndex + 1;
        if (idx >= _gradientSegment.numberOfSegments) idx = 0;
        _gradientSegment.selectedSegmentIndex = idx;
        [self segmentChanged:_gradientSegment];
    } else if (_focusIndex == ColorPickerFocusColorSlider) {
        // Nic, slider obsługiwany lewo/prawo
    } else if (_focusIndex == ColorPickerFocusSaturationSlider) {
        // Nic
    } else if (_focusIndex == ColorPickerFocusBrightnessSlider) {
        // Nic
    } else if (_focusIndex == ColorPickerFocusAlphaSlider) {
        // Nic
    } else if (_focusIndex == ColorPickerFocusPick) {
        [self startColorPicker];
    } else if (_focusIndex == ColorPickerFocusSave) {
        [self saveColor:nil];
    } else if (_focusIndex == ColorPickerFocusCancel) {
        [self cancel];
    }
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    [self loadCurrentColor];
}

- (void)loadCurrentColor {
    if (_gradientSegment.selectedSegmentIndex == 1) { // Now 1 is "Both"
        NSString *colorString = [[NSUserDefaults standardUserDefaults] objectForKey:@"CustomRightColor"];
        if (colorString) {
            NSArray *components = [colorString componentsSeparatedByString:@","];
            if (components.count == 4) {
                _colorSlider.value = [components[0] floatValue];
                [self updateThumbColor];
                [self updatePreviewColor]; // Dodaj aktualizację preview
            }
        }
    } else {
        NSString *key = (_gradientSegment.selectedSegmentIndex == 0) ? @"CustomLeftColor" : @"CustomRightColor";
        NSString *colorString = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        
        if (colorString) {
            NSArray *components = [colorString componentsSeparatedByString:@","];
            if (components.count == 4) {
                _colorSlider.value = [components[0] floatValue];
                [self updateThumbColor];
                [self updatePreviewColor]; // Dodaj aktualizację preview
            }
        }
    }
}

- (void)saveColor:(UIButton *)sender {
    if (self.colorSelectedHandler) {
        UIColor *selectedColor = [UIColor colorWithHue:_colorSlider.value 
                                          saturation:_saturationSlider.value 
                                          brightness:_brightnessSlider.value 
                                             alpha:_alphaSlider.value];
        
        if (_gradientSegment.selectedSegmentIndex == 1) { // Now 1 is "Both"
            self.colorSelectedHandler(selectedColor, @"both");
        } else {
            NSString *gradientType = (_gradientSegment.selectedSegmentIndex == 0) ? @"left" : @"right";
            self.colorSelectedHandler(selectedColor, gradientType);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorSliderChanged:(UISlider *)slider {
    [self updateThumbColor];
}

- (void)updateThumbColor {
    UIColor *currentColor = [UIColor colorWithHue:_colorSlider.value 
                                     saturation:_saturationSlider.value 
                                     brightness:_brightnessSlider.value 
                                        alpha:_alphaSlider.value];
    UIImage *thumbImage = [self createThumbImageWithColor:currentColor];
    [_colorSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    // Aktualizuj tła suwaków
    [self updateSliderBackgrounds];
    [self updatePreviewColor]; // Dodaj aktualizację preview
}

- (UIImage *)createThumbImageWithColor:(UIColor *)color {
    NSString *cacheKey = [NSString stringWithFormat:@"%@", color];
    UIImage *cachedImage = [_thumbImageCache objectForKey:cacheKey];
    if (cachedImage) return cachedImage;
    
    CGSize size = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect outerRect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, outerRect);
    
    CGRect innerRect = CGRectMake(2, 2, size.width - 4, size.height - 4);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, innerRect);
    
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_thumbImageCache setObject:thumbImage forKey:cacheKey];
    return thumbImage;
}

- (void)addGradientsWithBackgroundToView:(UIView *)view {
    CAGradientLayer *mainGradient = [CAGradientLayer layer];
    mainGradient.frame = view.bounds;
    mainGradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    mainGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    mainGradient.startPoint = CGPointMake(0, 0.5);
    mainGradient.endPoint = CGPointMake(1, 0.5);
    [view.layer insertSublayer:mainGradient atIndex:0];

    [self addGradientsToView:view];
}

- (void)addGradientsToView:(UIView *)view {
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(0, 0, view.frame.size.width, 1.5);
    topGradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    topGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    topGradient.startPoint = CGPointMake(0, 0.5);
    topGradient.endPoint = CGPointMake(1, 0.5);
    [view.layer addSublayer:topGradient];

    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = CGRectMake(0, view.frame.size.height - 1.5, view.frame.size.width, 1.5);
    bottomGradient.colors = topGradient.colors;
    bottomGradient.locations = topGradient.locations;
    bottomGradient.startPoint = topGradient.startPoint;
    bottomGradient.endPoint = topGradient.endPoint;
    [view.layer addSublayer:bottomGradient];
}

- (void)updateSliderBackgrounds {
    // Tło dla suwaka nasycenia
    CAGradientLayer *saturationGradient = [CAGradientLayer layer];
    saturationGradient.frame = CGRectMake(0, 0, _saturationSlider.frame.size.width, 20);
    saturationGradient.cornerRadius = 10;
    saturationGradient.colors = @[
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:0.0 brightness:_brightnessSlider.value alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:1.0 brightness:_brightnessSlider.value alpha:1.0].CGColor
    ];
    saturationGradient.startPoint = CGPointMake(0.0, 0.5);
    saturationGradient.endPoint = CGPointMake(1.0, 0.5);
    
    UIGraphicsBeginImageContextWithOptions(saturationGradient.frame.size, NO, 0.0);
    [saturationGradient renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *saturationImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [_saturationSlider setMinimumTrackImage:saturationImage forState:UIControlStateNormal];
    [_saturationSlider setMaximumTrackImage:saturationImage forState:UIControlStateNormal];
    
    // Tło dla suwaka jasności
    CAGradientLayer *brightnessGradient = [CAGradientLayer layer];
    brightnessGradient.frame = CGRectMake(0, 0, _brightnessSlider.frame.size.width, 20);
    brightnessGradient.cornerRadius = 10;
    brightnessGradient.colors = @[
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:_saturationSlider.value brightness:0.0 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:_saturationSlider.value brightness:1.0 alpha:1.0].CGColor
    ];
    brightnessGradient.startPoint = CGPointMake(0.0, 0.5);
    brightnessGradient.endPoint = CGPointMake(1.0, 0.5);
    
    UIGraphicsBeginImageContextWithOptions(brightnessGradient.frame.size, NO, 0.0);
    [brightnessGradient renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *brightnessImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [_brightnessSlider setMinimumTrackImage:brightnessImage forState:UIControlStateNormal];
    [_brightnessSlider setMaximumTrackImage:brightnessImage forState:UIControlStateNormal];
    
    // Zaktualizowany kod dla alpha slidera z szachownicą
    CGFloat sliderWidth = _alphaSlider.frame.size.width;
    CGFloat sliderHeight = 20;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sliderWidth, sliderHeight), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Dodaj zaokrąglone rogi do kontekstu
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, sliderWidth, sliderHeight) 
                                                   cornerRadius:10];
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    
    // Rysuj szachownicę
    CGFloat squareSize = 8;
    for (int row = 0; row < ceil(sliderHeight/squareSize); row++) {
        for (int col = 0; col < ceil(sliderWidth/squareSize); col++) {
            if ((row + col) % 2 == 0) {
                CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:1.0].CGColor);
            } else {
                CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:1.0].CGColor);
            }
            CGContextFillRect(context, CGRectMake(col * squareSize, row * squareSize, squareSize, squareSize));
        }
    }
    
    // Nałóż gradient przezroczystości z zaokrąglonymi rogami
    UIColor *currentColor = [UIColor colorWithHue:_colorSlider.value 
                                     saturation:_saturationSlider.value 
                                     brightness:_brightnessSlider.value 
                                        alpha:1.0];
    
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = @[
        (__bridge id)[currentColor colorWithAlphaComponent:0.0].CGColor,
        (__bridge id)[currentColor colorWithAlphaComponent:1.0].CGColor
    ];
    gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(sliderWidth, 0), 0);
    
    UIImage *alphaImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    [_alphaSlider setMinimumTrackImage:alphaImage forState:UIControlStateNormal];
    [_alphaSlider setMaximumTrackImage:alphaImage forState:UIControlStateNormal];
}

- (void)sliderChanged:(UISlider *)slider {
    [self updateThumbColor];
    [self updatePreviewColor]; // Dodaj aktualizację preview
}

- (void)styleSlider:(UISlider *)slider {
    // Ustaw małe kółko jako thumb dla wszystkich suwaków
    UIImage *thumbImage = [self createSmallThumbImage];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
}

- (UIImage *)createSmallThumbImage {
    CGSize size = CGSizeMake(15, 15);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect outerRect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, outerRect);
    
    CGRect innerRect = CGRectMake(1.5, 1.5, size.width - 3, size.height - 3);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.2 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(context, innerRect);
    
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbImage;
}

- (void)setupColorPreview {
    // Kontener dla podglądu
    CGFloat previewWidth = 120;
    CGFloat previewHeight = 20; // Taka sama wysokość jak slider
    _colorPreviewView = [[UIView alloc] initWithFrame:CGRectMake(
        (_containerView.frame.size.width - previewWidth) / 2,
        85,
        previewWidth,
        previewHeight
    )];
    _colorPreviewView.layer.cornerRadius = 10; // Takie samo zaokrąglenie jak slider
    _colorPreviewView.clipsToBounds = YES;
    [_containerView addSubview:_colorPreviewView];
    
    // Dodaj szachownicę dla przezroczystości
    UIView *checkerboardView = [[UIView alloc] initWithFrame:_colorPreviewView.bounds];
    checkerboardView.layer.cornerRadius = 10;
    checkerboardView.clipsToBounds = YES;
    [_colorPreviewView addSubview:checkerboardView];
    
    // Stwórz wzór szachownicy
    CGFloat squareSize = 4;
    for (int row = 0; row < ceil(previewHeight/squareSize); row++) {
        for (int col = 0; col < ceil(previewWidth/squareSize); col++) {
            if ((row + col) % 2 == 0) {
                UIView *square = [[UIView alloc] initWithFrame:CGRectMake(
                    col * squareSize,
                    row * squareSize,
                    squareSize,
                    squareSize
                )];
                square.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1.0];
                [checkerboardView addSubview:square];
            }
        }
    }
    
    // Dodaj warstwę koloru
    UIView *colorLayer = [[UIView alloc] initWithFrame:_colorPreviewView.bounds];
    colorLayer.layer.cornerRadius = 10;
    [_colorPreviewView addSubview:colorLayer];
    
    // Dodaj subtelną ramkę
    _colorPreviewView.layer.borderWidth = 0.5;
    _colorPreviewView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.1].CGColor;
    
    // Dodaj napis "Preview"
    UILabel *previewLabel = [[UILabel alloc] initWithFrame:_colorPreviewView.bounds];
    previewLabel.text = @"Preview";
    previewLabel.textAlignment = NSTextAlignmentCenter;
    previewLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium]; // Zmniejszona czcionka
    [_colorPreviewView addSubview:previewLabel];
    
    [self updatePreviewColor];
}

- (void)updatePreviewColor {
    UIColor *currentColor = [UIColor colorWithHue:_colorSlider.value 
                                     saturation:_saturationSlider.value 
                                     brightness:_brightnessSlider.value 
                                        alpha:_alphaSlider.value];
    
    // Znajdź warstwę koloru i zaktualizuj jej kolor tła
    for (UIView *subview in _colorPreviewView.subviews) {
        if (subview != [_colorPreviewView.subviews firstObject] && // nie szachownica
            ![subview isKindOfClass:[UILabel class]]) { // nie label
            subview.backgroundColor = currentColor;
            break;
        }
    }
    
    // Dostosuj kolor tekstu
    UILabel *previewLabel = [_colorPreviewView.subviews lastObject];
    CGFloat brightness;
    [currentColor getHue:NULL saturation:NULL brightness:&brightness alpha:NULL];
    previewLabel.textColor = (brightness > 0.6) ? 
        [UIColor colorWithWhite:0.0 alpha:0.7] : 
        [UIColor colorWithWhite:1.0 alpha:0.9];
}

- (void)startColorPicker {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *existingPicker = [window viewWithTag:1338];
    if (existingPicker) {
        [existingPicker removeFromSuperview];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Ukryj menu color pickera
        self.view.hidden = YES;
        
        // Zrób zrzut ekranu
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
        [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Pokaż menu z powrotem
        self.view.hidden = NO;
        
        // Stwórz widok pickera bez przyciemnienia
        UIView *pickerView = [[UIView alloc] initWithFrame:window.bounds];
        pickerView.tag = 1338;
        pickerView.backgroundColor = [UIColor clearColor];
        
        // Dodaj obrazek jako tło
        UIImageView *screenshotView = [[UIImageView alloc] initWithImage:screenshot];
        screenshotView.userInteractionEnabled = YES;
        screenshotView.frame = window.bounds;
        screenshotView.tag = 1337;
        screenshotView.alpha = 1.0; // Pełna nieprzezroczystość
        [pickerView addSubview:screenshotView];
        
        // Dodaj podgląd koloru (kursor)
        UIView *previewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 70)];
        previewContainer.tag = 1000;
        previewContainer.alpha = 0;
        
        // Podgląd koloru (kółko)
        UIView *colorPreview = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        colorPreview.layer.cornerRadius = 20;
        colorPreview.layer.borderWidth = 2;
        colorPreview.layer.borderColor = [UIColor whiteColor].CGColor;
        colorPreview.layer.shadowColor = [UIColor blackColor].CGColor;
        colorPreview.layer.shadowOffset = CGSizeMake(0, 2);
        colorPreview.layer.shadowOpacity = 0.5;
        colorPreview.layer.shadowRadius = 4;
        [previewContainer addSubview:colorPreview];
        
        // Trójkąt na dole (wskaźnik)
        CAShapeLayer *triangle = [CAShapeLayer layer];
        UIBezierPath *trianglePath = [UIBezierPath bezierPath];
        [trianglePath moveToPoint:CGPointMake(20, 45)];
        [trianglePath addLineToPoint:CGPointMake(30, 45)];
        [trianglePath addLineToPoint:CGPointMake(25, 55)];
        [trianglePath closePath];
        
        triangle.path = trianglePath.CGPath;
        triangle.fillColor = [UIColor whiteColor].CGColor;
        [previewContainer.layer addSublayer:triangle];
        
        [pickerView addSubview:previewContainer];
        
        // Dodaj gesty
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeColorPicker:)];
        [screenshotView addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleColorPick:)];
        [screenshotView addGestureRecognizer:panGesture];
        
        // Dodaj gest dotknięcia dla natychmiastowego wyboru koloru
        UITapGestureRecognizer *pickColorTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleColorPick:)];
        [pickColorTapGesture requireGestureRecognizerToFail:tapGesture];
        [screenshotView addGestureRecognizer:pickColorTapGesture];
        
        [window addSubview:pickerView];
    });
}

- (void)closeColorPicker:(UIGestureRecognizer *)gesture {
    UIView *pickerView = gesture.view;
    if (!pickerView) {
        pickerView = [[[UIApplication sharedApplication] keyWindow] viewWithTag:1338];
    }
    
    // Pokaż menu z powrotem
    self.view.hidden = NO;
    
    [pickerView removeFromSuperview];
}

- (void)handleColorPick:(UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:gesture.view.superview];
    UIView *pickerView = gesture.view.superview;
    
    // Pobierz screenshot z UIImageView
    UIImageView *screenshotView = (UIImageView *)gesture.view;
    UIImage *screenshot = screenshotView.image;
    if (!screenshot) return;
    
    // Przelicz punkt na współrzędne obrazu
    CGFloat scale = screenshot.scale;
    CGPoint imagePoint = CGPointMake(location.x * scale, location.y * scale);
    
    UIColor *pickedColor = [self colorAtPoint:imagePoint inImage:screenshot];
    if (pickedColor) {
        // Aktualizuj podgląd koloru (kursor)
        UIView *previewContainer = [pickerView viewWithTag:1000];
        UIView *colorPreview = previewContainer.subviews.firstObject;
        colorPreview.backgroundColor = pickedColor;
        
        // Pozycjonuj podgląd nad palcem
        CGPoint previewPosition = CGPointMake(
            location.x - previewContainer.frame.size.width / 2,
            location.y - previewContainer.frame.size.height - 10
        );
        
        // Ogranicz pozycję do granic ekranu
        if (previewPosition.x < 0) previewPosition.x = 0;
        if (previewPosition.x > pickerView.frame.size.width - previewContainer.frame.size.width)
            previewPosition.x = pickerView.frame.size.width - previewContainer.frame.size.width;
        if (previewPosition.y < 0) previewPosition.y = 0;
        
        previewContainer.frame = CGRectMake(
            previewPosition.x,
            previewPosition.y,
            previewContainer.frame.size.width,
            previewContainer.frame.size.height
        );
        
        // Pokaż podgląd
        if (previewContainer.alpha < 1) {
            [UIView animateWithDuration:0.2 animations:^{
                previewContainer.alpha = 1;
            }];
        }
        
        // Aktualizuj suwaki gdy gest się kończy
        if (gesture.state == UIGestureRecognizerStateEnded) {
            CGFloat hue, saturation, brightness, alpha;
            if ([pickedColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
                _colorSlider.value = hue;
                _saturationSlider.value = saturation;
                _brightnessSlider.value = brightness;
                _alphaSlider.value = alpha;
                
                [self updateThumbColor];
                [self updatePreviewColor];
                
                // Pokaż menu z powrotem przed zamknięciem pickera
                self.view.hidden = NO;
                
                [self closeColorPicker:nil];
            }
        }
    }
}

- (UIColor *)colorAtPoint:(CGPoint)point inImage:(UIImage *)image {
    // Upewnij się, że punkt jest w granicach obrazu
    if (point.x < 0 || point.y < 0 ||
        point.x >= image.size.width * image.scale ||
        point.y >= image.size.height * image.scale) {
        return nil;
    }
    
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    // Stwórz kontekst bitmapy
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt8 *rawData = (UInt8 *)calloc(height * width * bytesPerPixel, sizeof(UInt8));
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                               bitsPerComponent, bytesPerRow, colorSpace,
                                               kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // Narysuj obraz w kontekście
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    // Oblicz indeks piksela
    NSInteger x = (NSInteger)point.x;
    NSInteger y = (NSInteger)point.y;
    NSInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    
    // Pobierz komponenty koloru
    CGFloat red   = (CGFloat)rawData[byteIndex] / 255.0;
    CGFloat green = (CGFloat)rawData[byteIndex + 1] / 255.0;
    CGFloat blue  = (CGFloat)rawData[byteIndex + 2] / 255.0;
    CGFloat alpha = (CGFloat)rawData[byteIndex + 3] / 255.0;
    
    // Zwolnij zasoby
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rawData);
    
    // Stwórz i zwróć kolor
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end 