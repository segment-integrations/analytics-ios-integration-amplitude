#import "SEGAmplitudeIntegration.h"
#import <Analytics/SEGAnalyticsUtils.h>
#import <Analytics/SEGAnalytics.h>


@implementation SEGAmplitudeIntegration

- (id)initWithSettings:(NSDictionary *)settings
{
    return [self initWithSettings:settings andAmplitude:[Amplitude instance] andAmpRevenue:[AMPRevenue revenue]];
}

- (id)initWithSettings:(NSDictionary *)settings andAmplitude:(Amplitude *)amplitude andAmpRevenue:(AMPRevenue *)amprevenue
{
    if (self = [super init]) {
        self.settings = settings;
        self.amplitude = amplitude;
        self.amprevenue = amprevenue;

        NSString *apiKey = [self.settings objectForKey:@"apiKey"];
        [self.amplitude initializeApiKey:apiKey];

        if ([(NSNumber *)[self.settings objectForKey:@"trackSessionEvents"] boolValue]) {
            self.amplitude.trackingSessionEvents = true;
        }
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
    NSDictionary *options = payload.integrations[@"Amplitude"];
    NSDictionary *groups = [options isKindOfClass:[NSDictionary class]] ? options[@"groups"] : nil;
    if (groups && [groups isKindOfClass:[NSDictionary class]]) {
        [groups enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            [self.amplitude setGroup:[NSString stringWithFormat:@"%@", key] groupName:obj];
        }];
    }
}

- (void)realTrack:(NSString *)event properties:(NSDictionary *)properties integrations:(NSDictionary *)integrations
{
    NSDictionary *options = integrations[@"Amplitude"];
    NSDictionary *groups = [options isKindOfClass:[NSDictionary class]] ? options[@"groups"] : nil;
    if (groups && [groups isKindOfClass:[NSDictionary class]]) {
        [self.amplitude logEvent:event withEventProperties:properties withGroups:groups];
    } else {
        [self.amplitude logEvent:event withEventProperties:properties];
    }

    // Track revenue.
    NSNumber *revenue = [SEGAmplitudeIntegration extractRevenue:properties withKey:@"revenue"];
    if (revenue) {
        // Use logRevenueV2 with revenue properties.
        if ([(NSNumber *)[self.settings objectForKey:@"useLogRevenueV2"] boolValue]) {
            id price = [properties objectForKey:@"price"];
            id quantity = [properties objectForKey:@"quantity"];

            // if no price fallback to using revenue
            if (!price || ![price isKindOfClass:[NSNumber class]]) {
                price = revenue;
                quantity = [NSNumber numberWithInt:1];
            } else if (!quantity || ![quantity isKindOfClass:[NSNumber class]]) {
                quantity = [NSNumber numberWithInt:1];
            }

            [[self.amprevenue setPrice:price] setQuantity:[quantity integerValue]];
            id productId = [properties objectForKey:@"productId"] ?: [properties objectForKey:@"product_id"];
            if (productId && [productId isKindOfClass:[NSString class]] && ![productId isEqualToString:@""]) {
                [self.amprevenue setProductIdentifier:productId];
            }

            //Receipt is meant to be of type NSData
            id receipt = [properties objectForKey:@"receipt"];
            if (receipt && [receipt isKindOfClass:[NSString class]] && ![receipt isEqualToString:@""]) {
                [self.amprevenue setReceipt:receipt];
            }
            id revenueType = [properties objectForKey:@"revenueType"] ?: [properties objectForKey:@"revenue_type"];
            if (revenueType && [revenueType isKindOfClass:[NSString class]] && ![revenueType isEqualToString:@""]) {
                [self.amprevenue setRevenueType:revenueType];
            }
            NSLog(@"Price : %@, Quantity : %@", price, quantity);
            [self.amplitude logRevenueV2:self.amprevenue];
        } else {
            // fallback to logRevenue v1
            id productId = [properties objectForKey:@"productId"] ?: [properties objectForKey:@"product_id"];
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
}

- (void)track:(SEGTrackPayload *)payload
{
    [self realTrack:payload.event properties:payload.properties integrations:payload.integrations];
}

- (void)screen:(SEGScreenPayload *)payload
{
    if ([(NSNumber *)[self.settings objectForKey:@"trackAllPages"] boolValue]) {
        NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", payload.name];
        [self realTrack:event properties:payload.properties integrations:payload.integrations];
    }
}

- (void)group:(SEGGroupPayload *)payload
{
    NSString *groupId = payload.groupId;
    if (groupId) {
        [self.amplitude setGroup:@"[Segment] Group" groupName:groupId];
    }
}

- (void)flush
{
    [self.amplitude uploadEvents];
}

- (void)reset
{
    [self.amplitude regenerateDeviceId];
}


@end
