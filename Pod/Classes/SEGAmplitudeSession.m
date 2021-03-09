//
//  SEGAmplitudeSession.m
//  CocoapodsExample
//
//  Created by Cody Garvin on 3/4/21.
//  Copyright © 2021 Segment. All rights reserved.
//

#import "SEGAmplitudeSession.h"
@import UIKit;

@interface SEGAmplitudeSession()
@property (nonatomic, strong) NSTimer *sessionTimer;
@property (nonatomic, assign) NSTimeInterval sessionID;
@property (nonatomic, assign) NSTimeInterval fireTime;
@end

@implementation SEGAmplitudeSession

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        _fireTime = 300;
        [self startTimer];
    }
    return self;
}

- (void)dealloc {
    [_sessionTimer invalidate];
    _sessionTimer = nil;
}

- (void)context:(SEGContext * _Nonnull)context next:(SEGMiddlewareNext _Nonnull)next {
    NSMutableDictionary *amplitude = [[NSMutableDictionary alloc] init];
    amplitude[@"session_id"] = @(_sessionID);
    
    SEGContext *changedContext = [context modify:^(id<SEGMutableContext>  _Nonnull ctx) {
        SEGPayload *newPayload = nil;
        NSMutableDictionary *integrations = ctx.payload.integrations.mutableCopy;
        if (integrations == nil) {
            integrations = [[NSMutableDictionary alloc] init];
        }
        integrations[@"Amplitude"] = amplitude;
        
        if ([context.payload isKindOfClass:SEGIdentifyPayload.class]) {
            // Identify Payloads
            newPayload = [[SEGIdentifyPayload alloc] initWithUserId:ctx.payload.userId
                                                        anonymousId:ctx.payload.anonymousId
                                                             traits:[(SEGIdentifyPayload *)ctx.payload traits]
                                                            context:ctx.payload.context
                                                       integrations:integrations];

        } else if ([context.payload isKindOfClass:SEGTrackPayload.class]) {
            // Track Payloads
            SEGTrackPayload *trackPayload = (SEGTrackPayload *)context.payload;
            newPayload = [[SEGTrackPayload alloc] initWithEvent:trackPayload.event
                                                     properties:trackPayload.properties
                                                        context:trackPayload.context
                                                   integrations:integrations];

        } else if ([context.payload isKindOfClass:SEGScreenPayload.class]) {
            // Screen Payloads
            SEGScreenPayload *screenPayload = (SEGScreenPayload *)context.payload;
            newPayload = [[SEGScreenPayload alloc] initWithName:screenPayload.name
                                                       category:screenPayload.category
                                                     properties:screenPayload.properties
                                                        context:screenPayload.context
                                                   integrations:integrations];
            
        } else if ([context.payload isKindOfClass:SEGAliasPayload.class]) {
           // Alias Payloads
           SEGAliasPayload *aliasPayload = (SEGAliasPayload *)context.payload;
           newPayload = [[SEGAliasPayload alloc] initWithNewId:aliasPayload.theNewId
                                                       context:aliasPayload.context
                                                  integrations:integrations];
            
       } else if ([context.payload isKindOfClass:SEGGroupPayload.class]) {
           // Group Payloads
           SEGGroupPayload *groupPayload = (SEGGroupPayload *)context.payload;
           newPayload = [[SEGGroupPayload alloc] initWithGroupId:groupPayload.groupId
                                                          traits:groupPayload.traits
                                                         context:groupPayload.context
                                                    integrations:integrations];

       }

        if (newPayload != nil) {
            ctx.payload = newPayload;
        }

    }];

    next(changedContext);
//    next(context);
}

- (void)onAppForeground:(NSNotification *)notification {
    // start timer
    [self startTimer];
    SEGLog(@"Session ID: %f", _sessionID);
}

- (void)onAppBackground:(NSNotification *)notification {
    // stop timer
    [self stopTimer];
}

- (void)handleTimerFire {
    SEGLog(@"Timer Fired");
    SEGLog(@"Session: %f", _sessionID);
    [self stopTimer];
    [self startTimer];
}

- (void)startTimer {
    self.sessionID = floor([[NSDate date] timeIntervalSince1970]) * 1000;
    self.sessionTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:_fireTime repeats:YES block:^(NSTimer * _Nonnull timer) {
        __weak typeof(self) weakSelf = self;
        [weakSelf handleTimerFire];
    }];
}

- (void)stopTimer {
    [_sessionTimer invalidate];
    _sessionID = -1;
}



@end
