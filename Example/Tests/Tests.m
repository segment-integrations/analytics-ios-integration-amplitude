//
//  Segment-AmplitudeTests.m
//  Segment-AmplitudeTests
//
//  Created by Prateek Srivastava on 11/10/2015.
//  Copyright (c) 2015 Prateek Srivastava. All rights reserved.
//

// https://github.com/Specta/Specta

SpecBegin(InitialSpecs);


describe(@"SEGAmplitudeIntegrationFactory", ^{
    it(@"factory creates integration with basic settings", ^{
        SEGAmplitudeIntegration *integration = [[SEGAmplitudeIntegrationFactory instance] createWithSettings:@{
            @"apiKey" : @"1234"
        } forAnalytics:nil];
        expect(integration.settings).to.equal(@{ @"apiKey" : @"1234" });

    });

    it(@"factory creates integration with trackSessionEvents", ^{
        SEGAmplitudeIntegration *integration = [[SEGAmplitudeIntegrationFactory instance] createWithSettings:@{
            @"apiKey" : @"1234",
            @"trackSessionEvents" : @true
        } forAnalytics:nil];
        expect(integration.settings).to.equal(@{ @"apiKey" : @"1234",
                                                 @"trackSessionEvents" : @true });
    });
});

describe(@"SEGAmplitudeIntegration", ^{

    __block Amplitude *mockAmplitude;
    __block SEGAmplitudeIntegration *integration;

    beforeEach(^{
        mockAmplitude = mock([Amplitude class]);
        integration = [[SEGAmplitudeIntegration alloc] initWithSettings:@{} andAmplitude:mockAmplitude];
    });

    describe(@"Identify", ^{

        it(@"identify without traits", ^{
            SEGIdentifyPayload *payload = [[SEGIdentifyPayload alloc] initWithUserId:@"1111" anonymousId:nil traits:@{} context:@{} integrations:@{}];

            [integration identify:payload];
            [verify(mockAmplitude) setUserId:@"1111"];
        });

        it(@"identify with traits", ^{
            SEGIdentifyPayload *payload = [[SEGIdentifyPayload alloc] initWithUserId:@"7891" anonymousId:nil traits:@{
                @"name" : @"George Costanza",
                @"gender" : @"male",
                @"quality" : @"unstable",
                @"age" : @47
            } context:@{}
                integrations:@{}];
            [integration identify:payload];
            [verify(mockAmplitude) setUserProperties:payload.traits];
        });

        it(@"identify with groups", ^{
            SEGIdentifyPayload *payload = [[SEGIdentifyPayload alloc] initWithUserId:@"7891" anonymousId:nil traits:@{
                @"name" : @"Elaine Marie Benes",
                @"gender" : @"female",
                @"quality" : @"assertiveness",
                @"age" : @36
            } context:@{} integrations:@{ @"Amplitude" : @{
                @"groups" : @{
                    @"jobs" : @[ @"Pendant Publishing" ]
                }
            } }];
            [integration identify:payload];
            [verify(mockAmplitude) setGroup:@"jobs" groupName:@[ @"Pendant Publishing" ]];
        });

    });

    describe(@"Screen", ^{
        it(@"does not call screen if trackAllPages = false", ^{
            integration = [[SEGAmplitudeIntegration alloc] initWithSettings:@{ @"trackAllPages" : @false } andAmplitude:mockAmplitude];

            SEGScreenPayload *payload = [[SEGScreenPayload alloc] initWithName:@"Shirts" properties:@{} context:@{} integrations:@{}];
            [integration screen:payload];
            [verifyCount(mockAmplitude, never()) logEvent:@"Viewed Shirts Screen" withEventProperties:@{}];
        });

        it(@"calls basic screen", ^{
            integration = [[SEGAmplitudeIntegration alloc] initWithSettings:@{ @"trackAllPages" : @true } andAmplitude:mockAmplitude];

            SEGScreenPayload *payload = [[SEGScreenPayload alloc] initWithName:@"Shirts" properties:@{} context:@{} integrations:@{}];
            [integration screen:payload];
            [verify(mockAmplitude) logEvent:@"Viewed Shirts Screen" withEventProperties:@{}];
        });

    });

    describe(@"Group", ^{
        it(@"sets groupId", ^{
            SEGGroupPayload *payload = [[SEGGroupPayload alloc] initWithGroupId:@"322" traits:@{} context:@{} integrations:@{}];
            [integration group:payload];
            [verify(mockAmplitude) setGroup:@"[Segment] Group" groupName:@"322"];
        });
    });

    describe(@"Flush", ^{
        it(@"calls uploadEvents", ^{
            [integration flush];
            [verify(mockAmplitude) uploadEvents];
        });
    });

    describe(@"Reset", ^{
        it(@"calls regenerateDeviceId", ^{
            [integration reset];
            [verify(mockAmplitude) regenerateDeviceId];
        });
    });
});

SpecEnd
