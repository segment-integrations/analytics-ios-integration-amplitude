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
#import "SEGAmplitudeIntegration.h"


@interface SEGAmplitudeIntegrationFactory : NSObject <SEGIntegrationFactory>

+ (instancetype)instance;

/**
 This method can be used to set Amplitude's adSupportBlock and locationInfoBlock.
 
 Example:
 
    SEGAmplitudeIntegrationFactory *factory = [SEGAmplitudeIntegrationFactory instanceWithSetupBlock:^{
        amplitude.adSupportBlock = ^{
            return [[ASIdentifierManager sharedManager] advertisingIdentifier];
        };
        amplitude.locationInfoBlock = ^{
            return @{
                @"lat" : @37.7,
                @"lng" : @122.4
            };
        };
    }];
    ...
    [analyticsConfiguration use:factory];
 
 */
+ (instancetype)instanceWithSetupBlock:(SEGAmplitudeSetupBlock)setupBlock;

@end
