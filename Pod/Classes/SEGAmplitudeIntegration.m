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
        SEGLog(@"[Amplitude initializeApiKey:%@]", apiKey);

        if ([(NSNumber *)[self.settings objectForKey:@"trackSessionEvents"] boolValue]) {
            self.amplitude.trackingSessionEvents = true;
            SEGLog(@"[Amplitude.trackingSessionEvents = true]");
        }
    }
    return self;
}

+ (NSNumber *)extractRevenueOrTotal:(NSDictionary *)dictionary withRevenueKey:(NSString *)revenueKey andTotalKey:(NSString *)totalKey
{
    id revenueOrTotal = nil;

    for (NSString *key in dictionary.allKeys) {
        // This may not be optimal, but we want to ensure that revenue is set if both total and revenue are present
        if ([key caseInsensitiveCompare:revenueKey] == NSOrderedSame) {
            revenueOrTotal = dictionary[key];
            break;
        }

        if ([key caseInsensitiveCompare:totalKey] == NSOrderedSame) {
            revenueOrTotal = dictionary[key];
            break;
        }
    }

    if (revenueOrTotal) {
        if ([revenueOrTotal isKindOfClass:[NSString class]]) {
            // Format the revenue.
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            return [formatter numberFromString:revenueOrTotal];
        } else if ([revenueOrTotal isKindOfClass:[NSNumber class]]) {
            return revenueOrTotal;
        }
    }
    return nil;
}

- (void)identify:(SEGIdentifyPayload *)payload
{
    [self.amplitude setUserId:payload.userId];
    SEGLog(@"[Amplitude setUserId:%@]", payload.userId);
    [self.amplitude setUserProperties:payload.traits];
    SEGLog(@"[Amplitude setUserProperties:%@]", payload.traits);
    NSDictionary *options = payload.integrations[@"Amplitude"];
    NSDictionary *groups = [options isKindOfClass:[NSDictionary class]] ? options[@"groups"] : nil;
    if (groups && [groups isKindOfClass:[NSDictionary class]]) {
        [groups enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            [self.amplitude setGroup:[NSString stringWithFormat:@"%@", key] groupName:obj];
            SEGLog(@"[Amplitude setGroup:%@ groupName:%@];", [NSString stringWithFormat:@"%@", key], obj);
        }];
    }
}

- (void)realTrack:(NSString *)event properties:(NSDictionary *)properties integrations:(NSDictionary *)integrations
{
    NSDictionary *options = integrations[@"Amplitude"];
    NSDictionary *groups = [options isKindOfClass:[NSDictionary class]] ? options[@"groups"] : nil;
    if (groups && [groups isKindOfClass:[NSDictionary class]]) {
        [self.amplitude logEvent:event withEventProperties:properties withGroups:groups];
        SEGLog(@"[Amplitude logEvent:%@ withEventProperties:%@ withGroups:%@];", event, properties, groups);
    } else {
        [self.amplitude logEvent:event withEventProperties:properties];
        SEGLog(@"[Amplitude logEvent:%@ withEventProperties:%@];", event, properties);
    }

    // Track revenue. If revenue is not present fallback on total
    NSNumber *revenueOrTotal = [SEGAmplitudeIntegration extractRevenueOrTotal:properties withRevenueKey:@"revenue" andTotalKey:@"total"];
    if (revenueOrTotal) {
        // Use logRevenueV2 with revenue properties.
        if ([(NSNumber *)[self.settings objectForKey:@"useLogRevenueV2"] boolValue]) {
            id price = [properties objectForKey:@"price"];
            id quantity = [properties objectForKey:@"quantity"];

            // if no price fallback to using revenue
            if (!price || ![price isKindOfClass:[NSNumber class]]) {
                price = revenueOrTotal;
                quantity = [NSNumber numberWithInt:1];
            } else if (!quantity || ![quantity isKindOfClass:[NSNumber class]]) {
                quantity = [NSNumber numberWithInt:1];
            }

            [[self.amprevenue setPrice:price] setQuantity:[quantity integerValue]];
            SEGLog(@"[[AMPRevenue revenue] setPrice:%@] setQuantity: %d];", price, [quantity integerValue]);

            id productId = [properties objectForKey:@"productId"] ?: [properties objectForKey:@"product_id"];
            if (productId && [productId isKindOfClass:[NSString class]] && ![productId isEqualToString:@""]) {
                [self.amprevenue setProductIdentifier:productId];
                SEGLog(@"[[AMPRevenue revenue] setProductIdentifier:%@];", productId);
            }

            //Receipt is meant to be of type NSData
            id receipt = [properties objectForKey:@"receipt"];
            if (receipt && [receipt isKindOfClass:[NSString class]] && ![receipt isEqualToString:@""]) {
                [self.amprevenue setReceipt:receipt];
                SEGLog(@"[[AMPRevenue revenue] setReceipt:%@];", receipt);
            }
            id revenueType = [properties objectForKey:@"revenueType"] ?: [properties objectForKey:@"revenue_type"];
            if (revenueType && [revenueType isKindOfClass:[NSString class]] && ![revenueType isEqualToString:@""]) {
                [self.amprevenue setRevenueType:revenueType];
                SEGLog(@"[AMPRevenue revenue] setRevenueType:%@];", revenueType);
            }
            NSLog(@"Price : %@, Quantity : %@", price, quantity);
            [self.amplitude logRevenueV2:self.amprevenue];
            SEGLog(@"[Amplitude logRevenueV2:%@];", self.amprevenue);

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
            [self.amplitude logRevenue:productId
                              quantity:[quantity integerValue]
                                 price:revenueOrTotal
                               receipt:receipt];
            SEGLog(@"[Amplitude logRevenue:%@ quantity:%d price:%@ receipt:%@];", productId, [quantity integerValue], revenue, receipt);
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
        SEGLog(@"[Amplitude setGroup:@'[Segment] Group' groupName:%@]", groupId);
    }
}

- (void)flush
{
    [self.amplitude uploadEvents];
    SEGLog(@"[Amplitude uploadEvents]");
}

- (void)reset
{
    [self.amplitude regenerateDeviceId];
    SEGLog(@"[Amplitude regnerateDeviceId];");
}


@end
