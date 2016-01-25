#import "SEGAmplitudeIntegration.h"
#import <Analytics/SEGAnalyticsUtils.h>
#import <Analytics/SEGAnalytics.h>

@implementation SEGAmplitudeIntegration

- (id)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        self.settings = settings;
        self.amplitude = [Amplitude instance];

        if ([(NSNumber *)[self.settings objectForKey:@"trackSessionEvents"] boolValue]) {
            [Amplitude instance].trackingSessionEvents = true;
        }

        NSString *apiKey = [self.settings objectForKey:@"apiKey"];
        [[Amplitude instance] initializeApiKey:apiKey];
    }
    return self;
}

+ (NSNumber *)extractRevenue:(NSDictionary *)dictionary withKey:(NSString *)revenueKey
{
    id revenueProperty = nil;

    for (NSString *key in dictionary.allKeys) {
        if ([key caseInsensitiveCompare:revenueKey] == NSOrderedSame) {
            revenueProperty = dictionary[key];
            break;
        }
    }

    if (revenueProperty) {
        if ([revenueProperty isKindOfClass:[NSString class]]) {
            // Format the revenue.
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            return [formatter numberFromString:revenueProperty];
        } else if ([revenueProperty isKindOfClass:[NSNumber class]]) {
            return revenueProperty;
        }
    }
    return nil;
}

- (void)identify:(SEGIdentifyPayload *)payload
{
    [self.amplitude setUserId:payload.userId];
    [self.amplitude setUserProperties:payload.traits];
}

-(void)realTrack:(NSString *)event properties:(NSDictionary *)properties
{
    [self.amplitude logEvent:event withEventProperties:properties];

    // Track any revenue.
    NSNumber *revenue = [SEGAmplitudeIntegration extractRevenue:properties withKey:@"revenue"];
    if (revenue) {
        id productId = [properties objectForKey:@"productId"];
        if (!productId || ![productId isKindOfClass:[NSString class]]) {
            productId = nil;
        }
        id quantity = [properties objectForKey:@"quantity"];
        if (!quantity || ![quantity isKindOfClass:[NSNumber class]]) {
            quantity = [NSNumber numberWithInt:1];
        }
        id receipt = [properties objectForKey:@"receipt"];
        if (!receipt || ![receipt isKindOfClass:[NSString class]]) {
            receipt = nil;
        }
        NSLog(@"Number : %@", revenue);
        [self.amplitude logRevenue:productId
                          quantity:[quantity integerValue]
                             price:revenue
                           receipt:receipt];
    }

}

- (void)track:(SEGTrackPayload *)payload
{
    [self realTrack:payload.event properties:payload.properties];
}

- (void)screen:(SEGScreenPayload *)payload
{
    if ([(NSNumber *)[self.settings objectForKey:@"trackAllPages"] boolValue]) {
        NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", payload.name];
        [self realTrack:event properties:payload.properties];
    }
}

- (void)flush
{
    [self.amplitude uploadEvents];
}

@end
