#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dispatch/dispatch.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <mach/processor_info.h>
#import <IOKit/IOKitLib.h>
#import <GameController/GameController.h>
#import <WebKit/WebKit.h>

#import "Magicolors/ColorsHandler.h"
#import <sys/stat.h>
#import <mach-o/dyld.h>
#import "Globals.h"
#import "Layout.h"
#import "HVIcons/Heaven.h"

#define kS 0.8
#define kCR 5.0
#define kTM 12
#define kSM 10
#define kLW 100
#define kLH 20
#define kLS 3
#define kP 2
#define kGH 2

typedef NS_ENUM(NSInteger, LI) {CL,TL,FL,GL,EL,PL,VL,EL2};

static UIView *gL[8]={0};
static UILabel *wM=nil;
static UIView *topWC=nil;
static dispatch_source_t _t;
static double FPSPerSecond = 0;
static dispatch_queue_t _tQ;
static BOOL iLLH=NO;
static UIWindow *overlayWindow = nil;
static WKWebView *topBannerWebView = nil;
static UIButton *topIcon = nil;
static UIView *iconCircle = nil;
static CGFloat bannerWidth = 200;
static CGFloat bannerHeight = 30;
static CGFloat wW = 0;
static CGFloat wH = 0;
static CGFloat lM = 18;
static CGFloat bM = 12;

// FPS counter variables
static double FPS_temp = 0;
static double starttick = 0;
static double endtick = 0;
static double deltatick = 0;
static double frameend = 0;
static double framedelta = 0;
static double frameavg = 0;

// Labels for time and FPS
static UILabel *timeLabel = nil;
static UILabel *fpsLabel = nil;

void frameTick() {
    if (starttick == 0) starttick = CACurrentMediaTime()*1000.0;
    endtick = CACurrentMediaTime()*1000.0;
    framedelta = endtick - frameend;
    frameavg = ((9*frameavg) + framedelta) / 10;
    FPSPerSecond = 1000.0f / (double)frameavg;
    frameend = endtick;
    
    FPS_temp++;
    deltatick = endtick - starttick;
    if (deltatick >= 1000.0f) {
        starttick = CACurrentMediaTime()*1000.0;
        FPSPerSecond = FPS_temp - 1;
        FPS_temp = 0;
    }
}

static void updateLabels() {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
    }
    
    if (timeLabel) {
        timeLabel.text = [NSString stringWithFormat:@"TIME: %@", [formatter stringFromDate:[NSDate date]]];
    }
    
    if (fpsLabel) {
        fpsLabel.text = [NSString stringWithFormat:@"FPS: %.1f", FPSPerSecond];
    }
}

static void sRT(void) {
    if (_t) {
        dispatch_source_cancel(_t);
        _t = nil;
    }
    
    _tQ = dispatch_queue_create("a0.cruexengine.fps", DISPATCH_QUEUE_SERIAL);
    _t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _tQ);
    
    if (_t) {
        dispatch_source_set_timer(_t, DISPATCH_TIME_NOW, (uint64_t)(0.1 * NSEC_PER_SEC), 0);
        dispatch_source_set_event_handler(_t, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                updateLabels();
            });
        });
        dispatch_resume(_t);
    }
}

static NSString *getHTMLContent() {
    return @"<!DOCTYPE html>"
           @"<html lang=\"en\">"
           @"<head>"
           @"    <meta charset=\"UTF-8\">"
           @"    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
           @"    <title>Top Banner</title>"
           @"    <style>"
           @"        body {"
           @"            margin: 0;"
           @"            padding: 0;"
           @"            background: #000;"
           @"            font-family: Arial, sans-serif;"
           @"        }"
           @"        .top-banner-container {"
           @"            position: fixed;"
           @"            top: 0;"
           @"            left: 50%;"
           @"            transform: translateX(-50%);"
           @"            width: 200px;"
           @"            height: 30px;"
           @"            z-index: 0;"
           @"        }"
           @"        .animated-border-box, .animated-border-box-glow {"
           @"            max-height: 630px;"
           @"            max-width: 200px;"
           @"            height: 100%;"
           @"            width: 100%;"
           @"            position: absolute;"
           @"            overflow: hidden;"
           @"            z-index: 0;"
           @"            border-radius: 10px;"
           @"        }"
           @"        .animated-border-box-glow {"
           @"            overflow: hidden;"
           @"            filter: blur(20px);"
           @"        }"
           @"        .animated-border-box:before, .animated-border-box-glow:before {"
           @"            content: '';"
           @"            z-index: -2;"
           @"            text-align: center;"
           @"            top: 50%;"
           @"            left: 50%;"
           @"            transform: translate(-50%, -50%) rotate(0deg);"
           @"            position: absolute;"
           @"            width: 99999px;"
           @"            height: 99999px;"
           @"            background-repeat: no-repeat;"
           @"            background-position: 0 0;"
           @"            background-image: conic-gradient(rgba(0,0,0,0), rgba(156,130,240,1), rgba(0,0,0,0) 25%);"
           @"            animation: rotate 4s linear infinite;"
           @"        }"
           @"        .animated-border-box:after {"
           @"            content: '';"
           @"            position: absolute;"
           @"            z-index: -1;"
           @"            left: 5px;"
           @"            top: 5px;"
           @"            width: calc(100% - 10px);"
           @"            height: calc(100% - 10px);"
           @"            background: rgb(13, 13, 13);"
           @"            border-radius: 7px;"
           @"        }"
           @"        @keyframes rotate {"
           @"            100% {"
           @"                transform: translate(-50%, -50%) rotate(1turn);"
           @"            }"
           @"        }"
           @"        .top-banner {"
           @"            position: relative;"
           @"            width: 100%;"
           @"            height: 100%;"
           @"            display: flex;"
           @"            align-items: center;"
           @"            justify-content: space-between;"
           @"            padding: 0 10px;"
           @"            box-sizing: border-box;"
           @"            z-index: 1;"
           @"        }"
           @"        .battery-container {"
           @"            display: flex;"
           @"            align-items: center;"
           @"            gap: 3px;"
           @"        }"
           @"        .battery-icon {"
           @"            width: 18px;"
           @"            height: 12px;"
           @"            color: white;"
           @"        }"
           @"        .battery-label {"
           @"            color: white;"
           @"            font-size: 9px;"
           @"            font-weight: bold;"
           @"        }"
           @"        .gamepad-container {"
           @"            display: flex;"
           @"            align-items: center;"
           @"            gap: 3px;"
           @"        }"
           @"        .gamepad-icon {"
           @"            width: 22px;"
           @"            height: 12px;"
           @"            color: white;"
           @"        }"
           @"    </style>"
           @"</head>"
           @"<body>"
           @"    <div class=\"top-banner-container\">"
           @"        <div class=\"animated-border-box-glow\"></div>"
           @"        <div class=\"animated-border-box\"></div>"
           @"        <div class=\"top-banner\">"
           @"            <div class=\"battery-container\">"
           @"                <svg class=\"battery-icon\" viewBox=\"0 0 24 24\" fill=\"currentColor\">"
           @"                    <path d=\"M16,20H8V6H16M16.67,4H15V2H9V4H7.33A1.33,1.33 0 0,0 6,5.33V20.67C6,21.4 6.6,22 7.33,22H16.67A1.33,1.33 0 0,0 18,20.67V5.33C18,4.6 17.4,4 16.67,4Z\"/>"
           @"                </svg>"
           @"                <span class=\"battery-label\">85%</span>"
           @"            </div>"
           @"            <div class=\"gamepad-container\">"
           @"                <svg class=\"gamepad-icon\" viewBox=\"0 0 24 24\" fill=\"currentColor\">"
           @"                    <path d=\"M21,6H3C1.9,6 1,6.9 1,8v8c0,1.1 0.9,2 2,2h18c1.1,0 2,-0.9 2,-2V8C23,6.9 22.1,6 21,6M11,13H8v3H6v-3H3v-2h3V8h2v3h3V13M15.5,15c-0.83,0 -1.5,-0.67 -1.5,-1.5s0.67,-1.5 1.5,-1.5s1.5,0.67 1.5,1.5S16.33,15 15.5,15M19.5,15c-0.83,0 -1.5,-0.67 -1.5,-1.5s0.67,-1.5 1.5,-1.5s1.5,0.67 1.5,1.5S20.33,15 19.5,15Z\"/>"
           @"                </svg>"
           @"                <span class=\"battery-label\">N/A</span>"
           @"            </div>"
           @"        </div>"
           @"    </div>"
           @"</body>"
           @"</html>";
}

@interface GH:NSObject
+(void)uGL:(UIView*)v;
+(void)aGTV:(UIView*)v;
@end

@implementation GH
+(void)uGL:(UIView*)v {
    v.backgroundColor = [UIColor colorWithRed:0x0d/255.0 green:0x0d/255.0 blue:0x0d/255.0 alpha:1.0];
    
    // Add single clean border
    v.layer.borderWidth = 1.0;
    v.layer.borderColor = [UIColor colorWithRed:156/255.0 green:130/255.0 blue:240/255.0 alpha:1.0].CGColor;
    
    // Add strong shadow glow
    v.layer.shadowColor = [UIColor colorWithRed:156/255.0 green:130/255.0 blue:240/255.0 alpha:1.0].CGColor;
    v.layer.shadowOffset = CGSizeZero;
    v.layer.shadowRadius = 8.0;
    v.layer.shadowOpacity = 1.0;
    v.layer.masksToBounds = NO;
    
    // Add additional glow layer (without border)
    CALayer *glowLayer = [CALayer layer];
    glowLayer.frame = v.bounds;
    glowLayer.cornerRadius = v.layer.cornerRadius;
    glowLayer.shadowColor = [UIColor colorWithRed:156/255.0 green:130/255.0 blue:240/255.0 alpha:1.0].CGColor;
    glowLayer.shadowOffset = CGSizeZero;
    glowLayer.shadowRadius = 12.0;
    glowLayer.shadowOpacity = 1.0;
    glowLayer.masksToBounds = NO;
    [v.layer addSublayer:glowLayer];
}

+(void)aGTV:(UIView*)v {
    [self uGL:v];
}
@end

@interface VF:NSObject
+(UIView*)cLWF:(CGRect)f t:(NSString*)t aR:(BOOL)aR;
+(UIView*)cHVWF:(CGRect)f;
+(UIView*)cWWF:(CGRect)f;
+(UIView*)cBWF:(CGRect)f;
@end

@implementation VF
+(UIView*)cLWF:(CGRect)f t:(NSString*)t aR:(BOOL)aR{
    UIFont*font=[UIFont fontWithName:@"ArialRoundedMTBold" size:10*kS];
    CGSize tS=[t sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat iconBarWidth = 40.0f;
    CGFloat tW = tS.width + kP*2 + iconBarWidth + 16;
    
    CGRect cF=CGRectMake(f.origin.x,f.origin.y,tW,f.size.height*kS);
    
    // Create main container
    UIView*cV=[[UIView alloc]initWithFrame:cF];
    cV.backgroundColor=[UIColor clearColor];
    
    // Create background view
    UIView*bV=[[UIView alloc]initWithFrame:cV.bounds];
    bV.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:0.6];
    bV.layer.cornerRadius=kCR;
    bV.clipsToBounds=YES;
    [cV addSubview:bV];

    // Create label with proper frame
    CGFloat labelX;
    CGFloat labelWidth;
    
    if ([t isEqualToString:@"TIME"] || [t isEqualToString:@"FPS"]) {
        labelX = 25;
        labelWidth = tW - 25;
    } else {
        labelX = iconBarWidth + 8;
        labelWidth = tW - iconBarWidth - 16;
    }
    
    UILabel*l=[[UILabel alloc]initWithFrame:CGRectMake(labelX, -1, labelWidth, f.size.height)];
    if([t isEqualToString:@"TIME"]) {
        l.text = @"TIME: 00:00";
        cV.tag = 0x1234;
        timeLabel = l;
    } else if([t isEqualToString:@"FPS"]) {
        l.text = @"FPS: 0.0";
        cV.tag = 0x1235;
        fpsLabel = l;
    } else {
        l.text = t;
    }
    l.font=font;
    l.textAlignment=NSTextAlignmentCenter;
    l.textColor=[UIColor whiteColor];
    l.backgroundColor=[UIColor clearColor];
    [cV addSubview:l];
    
    return cV;
}

+(UIView*)cHVWF:(CGRect)f{
    UIView*hV=[self cLWF:f t:@"HEAVEN" aR:YES];
    hV.tag=0xDEAD;
    UILabel*l=[hV.subviews lastObject];
    if([l isKindOfClass:[UILabel class]]){l.numberOfLines=1;l.textAlignment=NSTextAlignmentCenter;}
    return hV;
}

+(UIView*)cWWF:(CGRect)f{
    UIView*wC=[[UIView alloc]initWithFrame:f];
    wC.backgroundColor=[UIColor clearColor];
    wC.layer.cornerRadius=kCR;
    wC.clipsToBounds=YES;
    wC.tag=0xC0DE;
    
    // Create main container with semi-transparent background
    UIView *mainContainer = [[UIView alloc] initWithFrame:wC.bounds];
    mainContainer.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:0.6];
    mainContainer.layer.cornerRadius = kCR;
    mainContainer.clipsToBounds = YES;
    [wC addSubview:mainContainer];
    
    // Create icon bar view
    CGFloat iconBarWidth = 40.0f;
    UIView *iconBarView = [[UIView alloc] init];
    iconBarView.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:0.6];
    iconBarView.layer.cornerRadius = kCR;
    iconBarView.clipsToBounds = YES;
    [mainContainer addSubview:iconBarView];
    
    // Add icon
    NSData* data = [[NSData alloc] initWithBase64EncodedString:[Heaven HEAVEN_ICON] options:0];
    UIImage* menuIconImage = [UIImage imageWithData:data];
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:menuIconImage];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [iconBarView addSubview:iconImageView];
    
    // Create attributed string first
    NSMutableAttributedString*aS=[[NSMutableAttributedString alloc]initWithString:@"GAME FUSION"];
    [aS addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"ArialRoundedMTBold" size:10*kS]} range:NSMakeRange(0,aS.length)];
    
    // Calculate text size
    CGSize textSize = [aS boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, f.size.height)
                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      context:nil].size;
    
    // Adjust container width with minimal padding
    CGFloat containerWidth = textSize.width + 16 + iconBarWidth; // Added icon bar width
    CGRect newFrame = CGRectMake(f.origin.x, f.origin.y, containerWidth, f.size.height);
    wC.frame = newFrame;
    mainContainer.frame = wC.bounds;
    
    // Position icon bar
    iconBarView.frame = CGRectMake(0, 0, iconBarWidth, f.size.height);
    
    // Add rounded corners to icon bar
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:iconBarView.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(kCR,kCR)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    iconBarView.layer.mask = maskLayer;
    
    // Position icon
    CGFloat iconSize = 24.0f;
    iconImageView.frame = CGRectMake((iconBarWidth - iconSize) / 2, (f.size.height - iconSize) / 2, iconSize, iconSize);
    
    // Create label with proper frame
    wM = [[UILabel alloc] initWithFrame:CGRectMake(iconBarWidth + 8, 0, containerWidth - iconBarWidth - 16, f.size.height)];
    wM.backgroundColor = [UIColor clearColor];
    wM.textAlignment = NSTextAlignmentCenter;
    wM.textColor = UIColor.whiteColor;
    wM.attributedText = aS;
    
    [mainContainer addSubview:wM];
    return wC;
}

+(UIView*)cBWF:(CGRect)f{
    UIView*wC=[[UIView alloc]initWithFrame:f];
    wC.backgroundColor=[UIColor clearColor];
    wC.layer.cornerRadius=kCR;
    wC.clipsToBounds=YES;
    wC.tag=0xC0DE;
    
    // Create main container with semi-transparent background
    UIView *mainContainer = [[UIView alloc] initWithFrame:wC.bounds];
    mainContainer.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:0.6];
    mainContainer.layer.cornerRadius = kCR;
    mainContainer.clipsToBounds = YES;
    [wC addSubview:mainContainer];
    
    // Create icon bar view
    CGFloat iconBarWidth = 40.0f;
    UIView *iconBarView = [[UIView alloc] init];
    iconBarView.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:0.6];
    iconBarView.layer.cornerRadius = kCR;
    iconBarView.clipsToBounds = YES;
    [mainContainer addSubview:iconBarView];
    
    // Add icon
    NSData* data = [[NSData alloc] initWithBase64EncodedString:[Heaven HEAVEN_ICON] options:0];
    UIImage* menuIconImage = [UIImage imageWithData:data];
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:menuIconImage];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [iconBarView addSubview:iconImageView];
    
    // Create attributed string first
    NSMutableAttributedString*aS=[[NSMutableAttributedString alloc]initWithString:@"T.ME/CRUEXGG DEVELOPED BY ALEX ZERO"];
    [aS addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"ArialRoundedMTBold" size:10*kS]} range:NSMakeRange(0,13)];
    [aS addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"ArialRoundedMTBold" size:9*kS]} range:NSMakeRange(13,aS.length-13)];
    
    // Calculate text size
    CGSize textSize = [aS boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, f.size.height)
                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      context:nil].size;
    
    // Adjust container width with minimal padding
    CGFloat containerWidth = textSize.width + 16 + iconBarWidth; // Added icon bar width
    CGRect newFrame = CGRectMake(f.origin.x, f.origin.y, containerWidth, f.size.height);
    wC.frame = newFrame;
    mainContainer.frame = wC.bounds;
    
    // Position icon bar
    iconBarView.frame = CGRectMake(0, 0, iconBarWidth, f.size.height);
    
    // Add rounded corners to icon bar
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:iconBarView.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(kCR,kCR)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    iconBarView.layer.mask = maskLayer;
    
    // Position icon
    CGFloat iconSize = 24.0f;
    iconImageView.frame = CGRectMake((iconBarWidth - iconSize) / 2, (f.size.height - iconSize) / 2, iconSize, iconSize);
    
    // Create label with proper frame
    wM = [[UILabel alloc] initWithFrame:CGRectMake(iconBarWidth + 8, 0, containerWidth - iconBarWidth - 16, f.size.height)];
    wM.backgroundColor = [UIColor clearColor];
    wM.textAlignment = NSTextAlignmentCenter;
    wM.textColor = UIColor.whiteColor;
    wM.attributedText = aS;
    
    [mainContainer addSubview:wM];
    return wC;
}
@end

@interface DS:NSObject
+(NSDictionary*)gS;
+(float)gT;
@end

@implementation DS
+(float)gT{return fmin(fmax(30.0+[self gCU]*0.5+[self gMU]*0.2,30.0),95.0);}
+(float)gCU{
    processor_info_array_t cI;
    mach_msg_type_number_t nCI;
    natural_t nC=0;
    float tU=0;
    if(host_processor_info(mach_host_self(),PROCESSOR_CPU_LOAD_INFO,&nC,&cI,&nCI)==KERN_SUCCESS)
        for(unsigned i=0;i<nC;i++){
            float iU=cI[CPU_STATE_USER+(CPU_STATE_MAX*i)];
            float t=iU+cI[CPU_STATE_SYSTEM+(CPU_STATE_MAX*i)]+cI[CPU_STATE_IDLE+(CPU_STATE_MAX*i)];
            if(t>0)tU+=(iU/t)*100.0;
        }
    return tU/nC;
}

+(float)gMU{
    mach_port_t hP=mach_host_self();
    mach_msg_type_number_t hS=sizeof(vm_statistics_data_t)/sizeof(integer_t);
    vm_size_t pS;
    vm_statistics_data_t vS;
    host_page_size(hP,&pS);
    if(host_statistics(hP,HOST_VM_INFO,(host_info_t)&vS,&hS)==KERN_SUCCESS){
        unsigned long mU=(vS.active_count+vS.inactive_count+vS.wire_count)*pS;
        unsigned long mT=[NSProcessInfo processInfo].physicalMemory;
        return (float)mU/(float)mT*100.0;
    }
    return 0.0;
}

+(NSDictionary*)gS{
    UIDevice*d=[UIDevice currentDevice];
    d.batteryMonitoringEnabled=YES;
    return @{@"battery":@(d.batteryLevel*100),@"cpu":@([self gCU]),@"ram":@([self gMU]),@"temperature":@([self gT])};
}
@end

static void uLS(UIView*lV,NSString*nT){
    UILabel*l=[lV.subviews lastObject];
    l.text=nT;
    CGSize tS=[nT sizeWithAttributes:@{NSFontAttributeName:l.font}];
    
    // Check if this is TIME or FPS watermark
    BOOL isTimeOrFPS = [l.text isEqualToString:@"TIME"] || [l.text isEqualToString:@"FPS"];
    CGFloat iconBarWidth = isTimeOrFPS ? 26 : 40.0f;
    CGFloat nW = tS.width + kP*2 + (isTimeOrFPS ? 32 : iconBarWidth + 16);
    
    if(l.textAlignment==NSTextAlignmentRight)
        lV.frame=CGRectMake(lV.superview.frame.size.width-nW-kSM,lV.frame.origin.y,nW,lV.frame.size.height);
    else
        lV.frame=CGRectMake(lV.frame.origin.x,lV.frame.origin.y,nW,lV.frame.size.height);
    
    UIView*bV=[lV.subviews firstObject];
    bV.frame=lV.bounds;
    
    // Adjust label frame based on watermark type
    if (isTimeOrFPS) {
        l.frame = CGRectMake(32, -1, nW-32, lV.frame.size.height);
    } else {
        l.frame = CGRectMake(iconBarWidth + 8, -1, nW-iconBarWidth-16, lV.frame.size.height);
    }
    
    for(CALayer*layer in bV.layer.sublayers)
        if([layer isKindOfClass:[CAGradientLayer class]])
            layer.frame=CGRectMake(0,layer.frame.origin.y,nW,layer.frame.size.height);
}

static void uL(void){
    static NSDateFormatter*f=nil;
    if(!f){f=[[NSDateFormatter alloc]init];[f setDateFormat:@"HH:mm"];}
    
    // Update time watermark
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if(window) {
        UIView *timeWC = [window viewWithTag:0x1234];
        if(timeWC) {
            NSString *timeStr = [f stringFromDate:[NSDate date]];
            // Znajdź etykietę w kontenerze
            for(UIView *subview in timeWC.subviews) {
                if([subview isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)subview;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        label.text = [NSString stringWithFormat:@"TIME: %@", timeStr];
                    });
                    break;
                }
            }
        }
        
        // Update FPS watermark
        UIView *fpsWC = [window viewWithTag:0x1235];
        if(fpsWC) {
            NSString *fpsStr = [NSString stringWithFormat:@"FPS: %.1f", FPSPerSecond];
            for(UIView *subview in fpsWC.subviews) {
                if([subview isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)subview;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        label.text = fpsStr;
                    });
                    break;
                }
            }
        }
    }
}

static void initializeUI(UIWindow *window) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [Colors initializeColors];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Create overlay window
            if (!overlayWindow) {
                overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                overlayWindow.windowLevel = UIWindowLevelStatusBar + 1;
                overlayWindow.backgroundColor = [UIColor clearColor];
                overlayWindow.userInteractionEnabled = NO;
                overlayWindow.hidden = NO;
            }
            
            // Initialize watermark dimensions
            wW = overlayWindow.frame.size.width/4*kS;
            wH = kLH*kS;
            
            // Create WebView for top banner
            WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
            topBannerWebView = [[WKWebView alloc] initWithFrame:CGRectMake((overlayWindow.frame.size.width - bannerWidth) / 2, 0, bannerWidth, bannerHeight) configuration:config];
            topBannerWebView.backgroundColor = [UIColor clearColor];
            topBannerWebView.opaque = NO;
            topBannerWebView.scrollView.scrollEnabled = NO;
            topBannerWebView.userInteractionEnabled = NO;
            topBannerWebView.layer.cornerRadius = 10;
            topBannerWebView.clipsToBounds = YES;
            [overlayWindow addSubview:topBannerWebView];
            
            // Load HTML content
            [topBannerWebView loadHTMLString:getHTMLContent() baseURL:nil];
            
            // Add observer for app state changes
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                            object:nil
                                                             queue:[NSOperationQueue mainQueue]
                                                        usingBlock:^(NSNotification *notification) {
                // Reload WebView content when app becomes active
                [topBannerWebView loadHTMLString:getHTMLContent() baseURL:nil];
            }];
            
            // Create icon circle
            iconCircle = [[UIView alloc] initWithFrame:CGRectMake((overlayWindow.frame.size.width - 40) / 2, 0, 40, 40)];
            iconCircle.layer.cornerRadius = 20;
            
            // Add glow effect
            iconCircle.layer.shadowColor = [UIColor colorWithRed:156/255.0 green:130/255.0 blue:240/255.0 alpha:1.0].CGColor;
            iconCircle.layer.shadowOffset = CGSizeZero;
            iconCircle.layer.shadowRadius = 8;
            iconCircle.layer.shadowOpacity = 1.0;
            iconCircle.layer.masksToBounds = NO;
            
            // Add blur effect
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurView.frame = iconCircle.bounds;
            blurView.layer.cornerRadius = 20;
            blurView.clipsToBounds = YES;
            [iconCircle addSubview:blurView];
            
            [overlayWindow addSubview:iconCircle];
            
            // Add top centered icon
            NSData* data = [[NSData alloc] initWithBase64EncodedString:[Heaven HEAVEN_ICON] options:0];
            UIImage* menuIconImage = [UIImage imageWithData:data];
            
            topIcon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            topIcon.frame = CGRectMake(5, 5, 30, 30);
            topIcon.backgroundColor = [UIColor clearColor];
            [topIcon setBackgroundImage:menuIconImage forState:UIControlStateNormal];
            [iconCircle addSubview:topIcon];
            
            // Start monitoring device battery
            [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
                UIDevice *device = [UIDevice currentDevice];
                device.batteryMonitoringEnabled = YES;
                float batteryLevel = device.batteryLevel;
                
                if (batteryLevel >= 0) {
                    NSString *js = [NSString stringWithFormat:@"document.querySelector('.battery-container .battery-label').textContent = '%.0f%%'", batteryLevel * 100];
                    [topBannerWebView evaluateJavaScript:js completionHandler:nil];
                } else {
                    [topBannerWebView evaluateJavaScript:@"document.querySelector('.battery-container .battery-label').textContent = 'N/A'" completionHandler:nil];
                }
            }];
            
            // Start monitoring gamepad battery
            [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
                if (@available(iOS 14.0, *)) {
                    NSArray *controllers = [GCController controllers];
                    if (controllers.count > 0) {
                        GCController *controller = controllers.firstObject;
                        if (controller.battery) {
                            float batteryLevel = controller.battery.batteryLevel;
                            NSString *js = [NSString stringWithFormat:@"document.querySelector('.gamepad-container .battery-label').textContent = '%.0f%%'", batteryLevel * 100];
                            [topBannerWebView evaluateJavaScript:js completionHandler:nil];
                        } else {
                            [topBannerWebView evaluateJavaScript:@"document.querySelector('.gamepad-container .battery-label').textContent = 'N/A'" completionHandler:nil];
                        }
                    } else {
                        [topBannerWebView evaluateJavaScript:@"document.querySelector('.gamepad-container .battery-label').textContent = 'N/A'" completionHandler:nil];
                    }
                }
            }];
            
            NSArray*lC=@[];
            __block CGFloat lY=kTM*kS,rY=kTM*kS;
            [lC enumerateObjectsUsingBlock:^(NSDictionary*c,NSUInteger i,BOOL*s){
                BOOL aR=[c[@"align"]boolValue],iRS=[c[@"side"]isEqualToString:@"right"];
                CGFloat y=iRS?rY:lY,x=aR?overlayWindow.frame.size.width-(kLW*kS)-(kSM*kS):kSM*kS;
                gL[i]=[VF cLWF:CGRectMake(x,y,kLW*kS,kLH*kS)t:c[@"text"]aR:aR];
                [overlayWindow addSubview:gL[i]];
                if(iRS)rY+=(kLH+kLS)*kS;else lY+=(kLH+kLS)*kS;
            }];
            
            CGFloat wW=overlayWindow.frame.size.width/4*kS,wH=kLH*kS,lM=18,bM=12;
            // Bottom watermark
            UIView*wC=[VF cBWF:CGRectMake(lM,overlayWindow.frame.size.height-wH-bM,wW,wH)];
            [overlayWindow addSubview:wC];
            
            // Top watermark with GAME FUSION text and icon
            UIView*topWC=[VF cWWF:CGRectMake(lM,bM,wW,wH)];
            [overlayWindow addSubview:topWC];
            
            // TIME watermark
            UIView*timeWC=[VF cLWF:CGRectMake(lM,bM+wH+8,wW,wH) t:@"TIME" aR:NO];
            timeWC.tag = 0x1234;
            
            // Add background for time icon
            UIView *timeIconBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, timeWC.frame.size.height)];
            timeIconBg.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:0.6];
            timeIconBg.layer.cornerRadius = kCR;
            timeIconBg.clipsToBounds = YES;
            [timeWC addSubview:timeIconBg];
            
            // Add rounded corners to icon background
            UIBezierPath *timeMaskPath = [UIBezierPath bezierPathWithRoundedRect:timeIconBg.bounds
                                                       byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                                                             cornerRadii:CGSizeMake(kCR,kCR)];
            CAShapeLayer *timeMaskLayer = [CAShapeLayer layer];
            timeMaskLayer.path = timeMaskPath.CGPath;
            timeIconBg.layer.mask = timeMaskLayer;
            
            // Add SF Symbol for time
            UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, (timeWC.frame.size.height-12)/2, 12, 12)];
            if (@available(iOS 13.0, *)) {
                timeIcon.image = [UIImage systemImageNamed:@"clock.fill"];
            } else {
                timeIcon.image = [UIImage systemImageNamed:@"timer"];
            }
            timeIcon.tintColor = [UIColor whiteColor];
            timeIcon.contentMode = UIViewContentModeScaleAspectFit;
            [timeWC addSubview:timeIcon];
            
            // Adjust TIME label frame and alignment
            UILabel *timeLabel = [timeWC.subviews lastObject];
            if ([timeLabel isKindOfClass:[UILabel class]]) {
                timeLabel.frame = CGRectMake(32, -1, wW-32, timeWC.frame.size.height);
                timeLabel.textAlignment = NSTextAlignmentCenter;
                timeLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            }
            
            [overlayWindow addSubview:timeWC];
            
            // FPS watermark
            UIView*fpsWC=[VF cLWF:CGRectMake(lM,bM+(wH+8)*2,wW,wH) t:@"FPS" aR:NO];
            fpsWC.tag = 0x1235;
            
            // Add background for FPS icon
            UIView *fpsIconBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26, fpsWC.frame.size.height)];
            fpsIconBg.backgroundColor = [UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:0.6];
            fpsIconBg.layer.cornerRadius = kCR;
            fpsIconBg.clipsToBounds = YES;
            [fpsWC addSubview:fpsIconBg];
            
            // Add rounded corners to icon background
            UIBezierPath *fpsMaskPath = [UIBezierPath bezierPathWithRoundedRect:fpsIconBg.bounds
                                                       byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                                                             cornerRadii:CGSizeMake(kCR,kCR)];
            CAShapeLayer *fpsMaskLayer = [CAShapeLayer layer];
            fpsMaskLayer.path = fpsMaskPath.CGPath;
            fpsIconBg.layer.mask = fpsMaskLayer;
            
            // Add SF Symbol for FPS
            UIImageView *fpsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, (fpsWC.frame.size.height-12)/2, 12, 12)];
            UIImage *fpsImage = [UIImage systemImageNamed:@"gauge.with.needle.fill"];
            if (!fpsImage) {
                fpsImage = [UIImage systemImageNamed:@"chart.bar.fill"];
            }
            fpsIcon.image = fpsImage;
            fpsIcon.tintColor = [UIColor whiteColor];
            fpsIcon.contentMode = UIViewContentModeScaleAspectFit;
            [fpsWC addSubview:fpsIcon];
            
            // Adjust FPS label frame and alignment
            UILabel *fpsLabel = [fpsWC.subviews lastObject];
            if ([fpsLabel isKindOfClass:[UILabel class]]) {
                fpsLabel.frame = CGRectMake(32, -1, wW-32, fpsWC.frame.size.height);
                fpsLabel.textAlignment = NSTextAlignmentCenter;
                fpsLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            }
            
            [overlayWindow addSubview:fpsWC];
            
            sRT();
            [[NSNotificationCenter defaultCenter]addObserver:[UIWindow class]selector:@selector(hGU:)name:@"UpdateGradientColors" object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:[UIWindow class]selector:@selector(hLLT:)name:@"ToggleLayoutLabels" object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:[UIWindow class]selector:@selector(hMRC:)name:@"MenuRoundingChanged" object:nil];
            
            // Force initial update
            uL();
        });
    });
}

%hook UIApplication
-(void)setKeyWindow:(UIWindow *)window {
    %orig;
    if(window) {
        initializeUI(window);
    }
}
%end

%hook UIWindow
-(void)makeKeyAndVisible {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        initializeUI(self);
        sRT();
    });
}

-(void)layoutSubviews {
    %orig;
    if(gL[CL]) { // If UI is initialized
        // Update watermark dimensions
        wW = self.frame.size.width/4*kS;
        wH = kLH*kS;
        
        for(int i = 0; i < 8; i++) {
            if(gL[i]) {
                [self bringSubviewToFront:gL[i]];
            }
        }
        if(wM) {
            [self bringSubviewToFront:wM.superview];
            // Update bottom watermark position
            wM.superview.frame = CGRectMake(lM, self.frame.size.height-wH-bM, wW, wH);
        }
        if(topWC) {
            [self bringSubviewToFront:topWC];
            // Update top watermark position
            topWC.frame = CGRectMake(lM, bM, wW, wH);
            
            // Update TIME watermark position
            UIView *timeWC = [self viewWithTag:0x1234];
            if(timeWC) {
                timeWC.frame = CGRectMake(lM, bM+wH+8, wW, wH);
                [self bringSubviewToFront:timeWC];
            }
            
            // Update FPS watermark position
            UIView *fpsWC = [self viewWithTag:0x1235];
            if(fpsWC) {
                fpsWC.frame = CGRectMake(lM, bM+(wH+8)*2, wW, wH);
                [self bringSubviewToFront:fpsWC];
            }
        }
        if(topBannerWebView) {
            topBannerWebView.frame = CGRectMake((self.frame.size.width - bannerWidth) / 2, 0, bannerWidth, bannerHeight);
            [self bringSubviewToFront:topBannerWebView];
        }
        if(iconCircle) {
            iconCircle.frame = CGRectMake((self.frame.size.width - 40) / 2, 0, 40, 40);
            [self bringSubviewToFront:iconCircle];
        }
        if(topIcon) {
            topIcon.frame = CGRectMake(5, 5, 30, 30);
            [self bringSubviewToFront:topIcon];
        }
    }
}

-(void)setRootViewController:(UIViewController *)rootViewController {
    %orig;
    if(!gL[CL]) { // If UI is not initialized yet
        initializeUI(self);
    }
}

-(void)addSubview:(UIView *)view {
    %orig;
    if(gL[CL]) { // If UI is initialized
        for(int i = 0; i < 8; i++) {
            if(gL[i]) {
                [self bringSubviewToFront:gL[i]];
            }
        }
        if(wM) [self bringSubviewToFront:wM.superview];
        if(topBannerWebView) [self bringSubviewToFront:topBannerWebView];
        if(iconCircle) [self bringSubviewToFront:iconCircle];
        if(topIcon) [self bringSubviewToFront:topIcon];
    }
}

%new
-(void)hGU:(NSNotification*)n{
    dispatch_async(dispatch_get_main_queue(),^{
        // Update main labels
        NSArray*l=@[gL[CL],gL[TL],gL[FL]];
        for(UIView*lV in l){
            if(!lV)continue;
            UIView*bV=[lV.subviews firstObject];
            if(bV) [GH uGL:bV];
        }
        
        // Update watermark
        if(wM) {
            UIView *wC = wM.superview;
            if(wC) {
                [GH uGL:wC];
            }
        }
    });
}

%new
-(void)hLLT:(NSNotification*)n{
    BOOL sH=[n.userInfo[@"hidden"]boolValue];
    iLLH=sH;
    [UIView animateWithDuration:0.2 animations:^{
        NSArray*l=@[gL[CL],gL[TL],gL[FL],wM];
        for(UIView*l in l)if(l)l.alpha=sH?0.0:1.0;
    }completion:^(BOOL f){
        if(f){
            NSArray*l=@[gL[CL],gL[TL],gL[FL],wM];
            for(UIView*l in l)if(l)l.hidden=sH;
        }
    }];
}

%new
-(void)hMRC:(NSNotification*)n{
    CGFloat r=[n.userInfo[@"radius"]floatValue];
    dispatch_async(dispatch_get_main_queue(),^{
        NSArray*l=@[gL[CL],gL[TL],gL[FL]];
        for(UIView*lV in l){
            if(!lV)continue;
            UIView*bV=[lV.subviews firstObject];
            if(bV)bV.layer.cornerRadius=r;
        }
        if(wM){
            wM.layer.cornerRadius=r;
            wM.clipsToBounds=YES;
        }
    });
}
%end

%hook UIApplication
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if(window) {
            initializeUI(window);
        }
    });
    
    return result;
}
%end

%hook EAGLContext
-(BOOL)presentRenderbuffer:(NSUInteger)t{
    frameTick();
    return %orig;
}
%end

%hook CAMetalDrawable
-(void)present{
    frameTick();
    %orig;
}
-(void)presentAfterMinimumDuration:(CFTimeInterval)d{
    frameTick();
    %orig;
}
-(void)presentAtTime:(CFTimeInterval)t{
    frameTick();
    %orig;
}
%end

%hook UIAlertController
-(void)viewDidAppear:(BOOL)animated {
    %orig;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if(window && gL[CL]) {
        for(int i = 0; i < 8; i++) {
            if(gL[i]) {
                [window bringSubviewToFront:gL[i]];
            }
        }
        if(wM) [window bringSubviewToFront:wM.superview];
    }
}
%end

%hook UIAlertView
-(void)show {
    %orig;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if(window && gL[CL]) {
        for(int i = 0; i < 8; i++) {
            if(gL[i]) {
                [window bringSubviewToFront:gL[i]];
            }
        }
        if(wM) [window bringSubviewToFront:wM.superview];
    }
}
%end

%hook SCLAlertView
-(void)showSuccess:(NSString *)title subTitle:(NSString *)subTitle closeButtonTitle:(NSString *)closeButtonTitle duration:(NSTimeInterval)duration {
    %orig;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if(window && gL[CL]) {
        for(int i = 0; i < 8; i++) {
            if(gL[i]) {
                [window bringSubviewToFront:gL[i]];
            }
        }
        if(wM) [window bringSubviewToFront:wM.superview];
    }
}
%end










