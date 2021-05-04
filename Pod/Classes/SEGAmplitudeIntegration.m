#import "SEGAmplitudeIntegration.h"
#if defined(__has_include) && __has_include(<Analytics/Analytics.h>)
#import <Analytics/Analytics.h>
#elif defined(__has_include) && __has_include(<Segment/SEGAnalytics.h>)
#import <Segment/SEGAnalyticsUtils.h>
#import <Segment/SEGAnalytics.h>
#elif defined(__has_include) && __has_include(<SEGAnalytics.h>)
#import <SEGAnalyticsUtils.h>
#import <SEGAnalytics.h>
#else
#import "SEGAnalyticsUtils.h"
#import "SEGAnalytics.h"
#endif


@implementation SEGAmplitudeIntegration

- (id)initWithSettings:(NSDictionary *)settings setupBlock:(SEGAmplitudeSetupBlock)setupBlock
{
    return [self initWithSettings:settings andAmplitude:[Amplitude instance] andAmpRevenue:[AMPRevenue revenue] andAmpIdentify:[AMPIdentify identify] setupBlock:setupBlock];
}

- (id)initWithSettings:(NSDictionary *)settings andAmplitude:(Amplitude *)amplitude andAmpRevenue:(AMPRevenue *)amprevenue andAmpIdentify:(AMPIdentify *)identify setupBlock:(SEGAmplitudeSetupBlock)setupBlock
{
    if (self = [super init]) {
        self.settings = settings;
        self.amplitude = amplitude;
        self.amprevenue = amprevenue;
        self.identify = identify;
        if (self.settings[@"traitsToIncrement"] != (id)[NSNull null]) {
            self.traitsToIncrement = [NSSet setWithArray:self.settings[@"traitsToIncrement"]];
        }

        if (self.settings[@"traitsToSetOnce"] != (id)[NSNull null]) {
            self.traitsToSetOnce = [NSSet setWithArray:self.settings[@"traitsToSetOnce"]];
        }

        // NOTE: As of Amplitude-iOS 7.0.1, this is no longer available.  A callback is used instead.
        
        // Amplitude states that if you want location tracking disabled on startup of the app,
        // Call before initializing the apiKey
        /*if ([(NSNumber *)self.settings[@"enableLocationListening"] boolValue]) {
            [self.amplitude enableLocationListening];
            SEGLog(@"[Ampltidue enableLocationListening]");
        } else {
            [self.amplitude disableLocationListening];
            SEGLog(@"[Ampltidue disableLocationListening]");
        }*/

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
        
        if (setupBlock != nil) {
            setupBlock(self.amplitude);
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

    if ([self.traitsToIncrement count] > 0 || [self.traitsToSetOnce count] > 0) {
        [self incrementOrSetTraits:payload.traits];
    } else {
        [self.amplitude setUserProperties:payload.traits];
        SEGLog(@"[Amplitude setUserProperties:%@]", payload.traits);
    }


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
    __block NSDictionary *groups;
    __block bool outOfSession = false;

    NSDictionary *options = integrations[@"Amplitude"];
    if ([options isKindOfClass:[NSDictionary class]]) {
        groups = [options[@"groups"] isKindOfClass:[NSDictionary class]] ? options[@"groups"] : nil;
        outOfSession = [options[@"outOfSession"] boolValue];
    }

    [self.amplitude logEvent:event withEventProperties:properties withGroups:groups outOfSession:outOfSession];
    SEGLog(@"[Amplitude logEvent:%@ withEventProperties:%@ withGroups:%@ outOfSession:true];", event, properties, groups);

    // Track revenue. If revenue is not present fallback on total
    NSNumber *revenueOrTotal = [SEGAmplitudeIntegration extractRevenueOrTotal:properties withRevenueKey:@"revenue" andTotalKey:@"total"];
    if (revenueOrTotal) {
        [self trackLogRevenueV2:properties andRevenueOrTotal:revenueOrTotal];
    }
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

    [self.amprevenue setEventProperties:properties];
    SEGLog(@"[AMPRevenue revenue] setEventProperties:%@];", properties);

    [self.amplitude logRevenueV2:self.amprevenue];
    SEGLog(@"[Amplitude logRevenueV2:%@];", self.amprevenue);
}

- (void)track:(SEGTrackPayload *)payload
{
    [self realTrack:payload.event properties:payload.properties integrations:payload.integrations];
}

- (void)screen:(SEGScreenPayload *)payload
{
    if ([(NSNumber *)[self.settings objectForKey:@"trackAllPagesV2"] boolValue]) {
        NSMutableDictionary *payloadProps = [NSMutableDictionary dictionaryWithDictionary:payload.properties];
        [payloadProps setValue:payload.name forKey:@"name"];
        [self realTrack:@"Loaded a Screen" properties:payloadProps integrations:payload.integrations];
        return;
    }

    // Deprecated.
    if ([(NSNumber *)self.settings[@"trackAllPages"] boolValue]) {
        NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", payload.name];
        [self realTrack:event properties:payload.properties integrations:payload.integrations];
    }
}

- (void)group:(SEGGroupPayload *)payload
{
    NSString *groupTypeTrait = self.settings[@"groupTypeTrait"];
    NSString *groupTypeValue = self.settings[@"groupValueTrait"];
    NSString *groupName = payload.traits[groupTypeTrait];
    NSString *groupValue = payload.traits[groupTypeValue];

    if (!groupName || !groupValue) {
        groupName = payload.traits[@"name"] ?: @"[Segment] Group";
        groupValue = payload.groupId;
    }

    [self.amplitude setGroup:groupName groupName:groupValue];
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
    
    self.identify = [AMPIdentify identify];
    SEGLog(@"[Amplitude reset identify];");
}

#pragma utils

- (void)incrementOrSetTraits:(NSDictionary *)traits
{
    for (NSString *trait in traits) {
        id value = [traits valueForKey:trait];
        if ([self.traitsToIncrement member:trait]) {
            [self.amplitude identify:[self.identify add:trait value:value]];
            SEGLog(@"[Amplitude add:%@ value:%@]", trait, value);
        } else if ([self.traitsToSetOnce member:trait]) {
            [self.amplitude identify:[self.identify setOnce:trait value:value]];
        } else {
            [self.amplitude identify:[self.identify set:trait value:value]];
            SEGLog(@"[Amplitude set:%@ value:%@]", trait, value);
        }
    }
}

@end
