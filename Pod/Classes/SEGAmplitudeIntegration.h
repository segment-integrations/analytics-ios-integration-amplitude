@import Foundation;
@import Analytics;
@import Amplitude_iOS;

@interface SEGAmplitudeIntegration : NSObject<SEGIntegration>

@property (nonatomic, strong) NSDictionary *settings;
@property (strong) Amplitude *amplitude;

- (id)initWithSettings:(NSDictionary *)settings;

@end