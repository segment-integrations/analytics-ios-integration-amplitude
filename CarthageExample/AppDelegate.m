//
//  AppDelegate.m
//  CarthageExample
//
//  Created by Brandon Sneed on 2/21/20.
//  Copyright © 2020 Brandon Sneed. All rights reserved.
//

#import "AppDelegate.h"
//#import <Segment_Amplitude/SEGAmplitudeIntegrationFactory.h>

@import Amplitude;
@import Segment;
@import Segment_Amplitude;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSString *const SEGMENT_WRITE_KEY = @" ... ";
    SEGAnalyticsConfiguration *config = [SEGAnalyticsConfiguration configurationWithWriteKey:SEGMENT_WRITE_KEY];

    //id test = [SEGAmplitudeIntegrationFactory instance];
    [config use:[SEGAmplitudeIntegrationFactory instance]];

    [SEGAnalytics setupWithConfiguration:config];

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
