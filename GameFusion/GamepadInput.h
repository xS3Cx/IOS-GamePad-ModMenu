#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

@interface GamepadInput : NSObject

+ (void)startMonitoring;
+ (void)stopMonitoring;

@end 