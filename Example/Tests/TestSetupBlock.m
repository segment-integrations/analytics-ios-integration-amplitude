//
//  TestSetupBlock.m
//  Segment-Amplitude_Tests
//
//  Created by Brandon Sneed on 9/23/20.
//  Copyright © 2020 Prateek Srivastava. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SEGAmplitudeIntegrationFactory.h"

@interface TestSetupBlock : XCTestCase

@end

@implementation TestSetupBlock

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSetupBlockCalled {
    __block Amplitude *amp = nil;
    
    SEGAmplitudeIntegrationFactory *factory = [SEGAmplitudeIntegrationFactory instanceWithSetupBlock:^(Amplitude *amplitude) {
        amp = amplitude;
        amplitude.adSupportBlock = ^NSString * _Nonnull{
            return @"1234";
        };
        amplitude.locationInfoBlock = ^NSDictionary * _Nullable{
            return @{
                @"lat" : @37.7,
                @"lng" : @122.4
            };
        };
    }];
    
    SEGAnalytics *analytics = [[SEGAnalytics alloc] init];
    SEGAmplitudeIntegration *integration = [factory createWithSettings:@{} forAnalytics:analytics];
    
    XCTAssertTrue(amp != nil);
    XCTAssertTrue(amp.adSupportBlock != nil);
    XCTAssertTrue(amp.locationInfoBlock != nil);
    
    NSString *idfa = amp.adSupportBlock();
    NSDictionary *location = amp.locationInfoBlock();
    
    XCTAssertTrue([idfa isEqualToString:@"1234"]);
    XCTAssertTrue([[location objectForKey:@"lat"] isEqual:@37.7]);
}

@end
