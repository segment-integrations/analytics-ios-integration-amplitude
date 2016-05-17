#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegration.h>

#if defined(__has_include) && __has_include(<Amplitude_iOS/Amplitude.h>)
#import <Amplitude_iOS/Amplitude.h>
#else
#import <Amplitude-iOS/Amplitude.h>
#endif

@interface SEGAmplitudeIntegration : NSObject<SEGIntegration>

@property (nonatomic, strong) NSDictionary *settings;
@property (strong) Amplitude *amplitude;

- (id)initWithSettings:(NSDictionary *)settings;

@end