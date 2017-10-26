#import "SEGAmplitudeIntegration.h"
#import <Analytics/SEGAnalyticsUtils.h>
#import <Analytics/SEGAnalytics.h>


@implementation SEGAmplitudeIntegration

- (id)initWithSettings:(NSDictionary *)settings
{
    return [self initWithSettings:settings andAmplitude:[Amplitude instance] andAmpRevenue:[AMPRevenue revenue] andAmpIdentify:[AMPIdentify identify]];
}

- (id)initWithSettings:(NSDictionary *)settings andAmplitude:(Amplitude *)amplitude andAmpRevenue:(AMPRevenue *)amprevenue andAmpIdentify:(AMPIdentify *)identify
{
    if (self = [super init]) {
        self.settings = settings;
        self.amplitude = amplitude;
        self.amprevenue = amprevenue;
        self.identify = identify;

        NSString *apiKey = self.settings[@"apiKey"];
        [self.amplitude initializeApiKey:apiKey];
        SEGLog(@"[Amplitude initializeApiKey:%@]", apiKey);

        if ([(NSNumber *)self.settings[@"trackSessionEvents"] boolValue]) {
            self.amplitude.trackingSessionEvents = true;
            SEGLog(@"[Amplitude.trackingSessionEvents = true]");
        }

        if ([(NSNumber *)self.settings[@"useAdvertisingIdForDeviceId"] boolValue]) {
            [self.amplitude useAdvertisingIdForDeviceId];
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
            // We want revenue to be used in cases where both total and revenue are present,
            // so we want to continue checking for revenue even if revenueOrTotal is set to the total value
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

    if (self.settings[@"traitsToIncrement"]) {
        [payload.traits enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            [self incrementTrait:key andValue:obj];
        }];
    } else {
        [self.amplitude setUserProperties:payload.traits];
        SEGLog(@"[Amplitude setUserProperties:%@]", payload.traits);
    };

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
        [self trackRevenue:properties andRevenueOrTotal:revenueOrTotal];
    }
}

- (void)trackRevenue:(NSDictionary *)properties andRevenueOrTotal:(NSNumber *)revenueOrTotal
{
    // Use logRevenueV2 with revenue properties.
    if ([(NSNumber *)self.settings[@"useLogRevenueV2"] boolValue]) {
        [self trackLogRevenueV2:properties andRevenueOrTotal:revenueOrTotal];
        return;
    }

    // fallback to logRevenue v1
    NSString *productId = properties[@"productId"] ?: properties[@"product_id"] ?: nil;
    NSNumber *quantity = properties[@"quantity"] ?: [NSNumber numberWithInt:1];
    id receipt = properties[@"receipt"] ?: nil;
    [self.amplitude logRevenue:productId
                      quantity:[quantity integerValue]
                         price:revenueOrTotal
                       receipt:receipt];
    SEGLog(@"[Amplitude logRevenue:%@ quantity:%d price:%@ receipt:%@];", productId, [quantity integerValue], revenueOrTotal, receipt);
}

- (void)trackLogRevenueV2:(NSDictionary *)properties andRevenueOrTotal:(NSNumber *)revenueOrTotal
{
    NSNumber *price = properties[@"price"] ?: revenueOrTotal;
    NSNumber *quantity = properties[@"quantity"] ?: [NSNumber numberWithInt:1];
    [[self.amprevenue setPrice:price] setQuantity:[quantity integerValue]];
    SEGLog(@"[[AMPRevenue revenue] setPrice:%@] setQuantity: %d];", price, [quantity integerValue]);

    NSString *productId = properties[@"productId"] ?: properties[@"product_id"];
    if (productId && ![productId isEqualToString:@""]) {
        [self.amprevenue setProductIdentifier:productId];
        SEGLog(@"[[AMPRevenue revenue] setProductIdentifier:%@];", productId);
    }

    // Amplitude throws a warning that receipt is meant to be of type NSData. Previously, Segment checked for only type NSString. For backwards capability, removed the check
    id receipt = properties[@"receipt"];
    if (receipt) {
        [self.amprevenue setReceipt:receipt];
        SEGLog(@"[[AMPRevenue revenue] setReceipt:%@];", receipt);
    }

    NSString *revenueType = properties[@"revenueType"] ?: properties[@"revenue_type"];
    if (revenueType && ![revenueType isEqualToString:@""]) {
        [self.amprevenue setRevenueType:revenueType];
        SEGLog(@"[AMPRevenue revenue] setRevenueType:%@];", revenueType);
    }

    [self.amplitude logRevenueV2:self.amprevenue];
    SEGLog(@"[Amplitude logRevenueV2:%@];", self.amprevenue);
}

- (void)track:(SEGTrackPayload *)payload
{
    [self realTrack:payload.event properties:payload.properties integrations:payload.integrations];
}

- (void)screen:(SEGScreenPayload *)payload
{
    if ([(NSNumber *)self.settings[@"trackAllPages"] boolValue]) {
        NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", payload.name];
        [self realTrack:event properties:payload.properties integrations:payload.integrations];
    }
}

- (void)group:(SEGGroupPayload *)payload
{
    NSString *groupTypeTrait = self.settings[@"groupTypeTrait"];
    NSString *groupTypeValue = self.settings[@"groupTypeValue"];
    NSString *groupName = payload.traits[groupTypeTrait];
    NSString *groupValue = payload.traits[groupTypeValue];

    if (!groupName || !groupValue) {
        groupName = payload.traits[@"name"] ?: @"[Segment] Group";
        groupValue = payload.groupId;
    }

    [self.amplitude setGroup:groupValue groupName:groupName];
    SEGLog(@"[Amplitude setGroup:%@ groupName:%@]", groupValue, groupName);
}

- (void)flush
{
    [self.amplitude uploadEvents];
    SEGLog(@"[Amplitude uploadEvents]");
}

- (void)reset
{
    [self.amplitude setUserId:nil];
    SEGLog(@"[Amplitude setUserId:nil");

    [self.amplitude regenerateDeviceId];
    SEGLog(@"[Amplitude regnerateDeviceId];");
}

#pragma utils

- (void)incrementTrait:(NSString *)trait andValue:(NSString *)value
{
    __block BOOL isAmountSet = false;

    NSArray *increments = self.settings[@"traitsToIncrement"];
    for (NSString *increment in increments) {
        if ([increment isEqualToString:trait]) {
            [self.amplitude identify:[self.identify add:trait value:value]];
            isAmountSet = @YES;
        }
    }

    if (!isAmountSet) {
        [self.amplitude identify:[self.identify set:trait value:value]];
    }
}


@end
