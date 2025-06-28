#import "Magicolors/ColorsHandler.h"

// Definicja zmiennych
CGColorRef RightGradient;
CGColorRef blackColor;
CGColorRef LeftGradient;

// Statyczne zmienne klasowe
static UIColor *defaultColor;
static NSCache *colorCache;

@implementation Colors

+ (void)initialize {
    if (self == [Colors class]) {
        defaultColor = [UIColor colorWithRed:0.765 
                                     green:0.710 
                                      blue:0.910 
                                     alpha:1.0];
        colorCache = [[NSCache alloc] init];
        colorCache.countLimit = 50; // Limit cache'owanych kolorów
    }
}

+ (void)initializeColors {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Najpierw wyczyść stare kolory
    [self cleanup];
    
    // Ustaw domyślne kolory, jeśli nie ma zapisanych
    UIColor *rightColor = [self colorFromString:[defaults objectForKey:@"CustomRightColor"] 
                                 defaultColor:defaultColor];
    UIColor *leftColor = [self colorFromString:[defaults objectForKey:@"CustomLeftColor"]
                                defaultColor:defaultColor];
    UIColor *bothColor = [self colorFromString:[defaults objectForKey:@"CustomBothColor"]
                                defaultColor:defaultColor];
    // Przypisz nowe kolory
    RightGradient = CGColorRetain(rightColor.CGColor);
    blackColor = CGColorRetain([UIColor colorWithWhite:0 alpha:0.5].CGColor);
    LeftGradient = CGColorRetain(leftColor.CGColor);
    
    // Upewnij się, że wszystkie kolory są zainicjalizowane
    if (!RightGradient || !blackColor || !LeftGradient) {
        // Fallback na domyślne kolory
        if (!RightGradient) RightGradient = CGColorRetain(defaultColor.CGColor);
        if (!blackColor) blackColor = CGColorRetain([UIColor colorWithWhite:0 alpha:0.5].CGColor);
        if (!LeftGradient) LeftGradient = CGColorRetain(defaultColor.CGColor);
    }
}

+ (UIColor *)colorFromString:(NSString *)colorString defaultColor:(UIColor *)defaultColor {
    if (!colorString) return defaultColor;
    
    // Sprawdź cache
    UIColor *cachedColor = [colorCache objectForKey:colorString];
    if (cachedColor) return cachedColor;
    
    NSArray *components = [colorString componentsSeparatedByString:@","];
    if (components.count != 4) return defaultColor;
    
    @try {
        float red = MIN(1.0, MAX(0.0, [components[0] floatValue]));
        float green = MIN(1.0, MAX(0.0, [components[1] floatValue]));
        float blue = MIN(1.0, MAX(0.0, [components[2] floatValue]));
        float alpha = MIN(1.0, MAX(0.0, [components[3] floatValue]));
        
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [colorCache setObject:color forKey:colorString];
        return color;
    }
    @catch (NSException *exception) {
        return defaultColor;
    }
}

// Dodaj metodę czyszczenia
+ (void)cleanup {
    if (RightGradient) {
        CGColorRelease(RightGradient);
        RightGradient = NULL;
    }
    if (blackColor) {
        CGColorRelease(blackColor);
        blackColor = NULL;
    }
    if (LeftGradient) {
        CGColorRelease(LeftGradient);
        LeftGradient = NULL;
    }
}

@end
