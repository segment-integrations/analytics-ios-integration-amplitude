#import <Foundation/Foundation.h>

#if defined(__has_include) && __has_include(<Analytics/Analytics.h>)
#import <Analytics/Analytics.h>
#elif defined(__has_include) && __has_include(<Segment/SEGAnalytics.h>)
#import <Segment/SEGAnalytics.h>
#elif defined(__has_include) && __has_include(<SEGAnalytics.h>)
#import <SEGAnalytics.h>
#else
#import "SEGAnalytics.h"
#endif

#if defined(__has_include) && __has_include(<Amplitude_iOS/Amplitude.h>)
#import <Amplitude_iOS/Amplitude.h>
#elif defined(__has_include) && __has_include(<Amplitude-iOS/Amplitude.h>)
#import <Amplitude-iOS/Amplitude.h>
#else
#import <Amplitude/Amplitude.h>
#endif

typedef void(^SEGAmplitudeSetupBlock)(Amplitude *amplitude);

@interface SEGAmplitudeIntegration : NSObject <SEGIntegration>

@property (nonatomic, strong) NSDictionary *settings;
@property (strong) Amplitude *amplitude;
@property (strong) AMPRevenue *amprevenue;
@property AMPIdentify *identify;
@property NSSet *traitsToIncrement;
@property NSSet *traitsToSetOnce;

- (id)initWithSettings:(NSDictionary *)settings setupBlock:(SEGAmplitudeSetupBlock)setupBlock;
- (id)initWithSettings:(NSDictionary *)settings andAmplitude:(Amplitude *)amplitude andAmpRevenue:(AMPRevenue *)amprevenue andAmpIdentify:(AMPIdentify *)identify setupBlock:(SEGAmplitudeSetupBlock)setupBlock;

@end
