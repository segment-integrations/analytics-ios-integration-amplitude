#import "SEGAmplitudeIntegrationFactory.h"
#import "SEGAmplitudeIntegration.h"


@implementation SEGAmplitudeIntegrationFactory {
    __strong SEGAmplitudeSetupBlock setupBlock;
}

+ (instancetype)instance
{
    static dispatch_once_t once;
    static SEGAmplitudeIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)instanceWithSetupBlock:(SEGAmplitudeSetupBlock)setupBlock
{
    SEGAmplitudeIntegrationFactory *factory = [SEGAmplitudeIntegrationFactory instance];
    factory->setupBlock = setupBlock;
    return factory;
}

- (id)init
{
    self = [super init];
    self->setupBlock = nil;
    return self;
}

- (id<SEGIntegration>)createWithSettings:(NSDictionary *)settings forAnalytics:(SEGAnalytics *)analytics
{
    return [[SEGAmplitudeIntegration alloc] initWithSettings:settings setupBlock:setupBlock];
}

- (NSString *)key
{
    return @"Amplitude";
}

@end
