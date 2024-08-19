// Copyright 2022 Topaz

#ifndef RNHeartbeatToken_h
#define RNHeartbeatToken_h

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <Heartbeat/Heartbeat.h>

@interface RNHeartbeatToken : NSObject

- (void)requestAuthorization:(NSDictionary *)params
            responseCallback:(RCTResponseSenderBlock)callback;

- (void)authorize:(NSString *)code
           params:(NSDictionary *)params
 responseCallback:(RCTResponseSenderBlock)callback;

- (void)getToken:(NSDictionary *)params
responseCallback:(RCTResponseSenderBlock)callback;

- (void)checkToken:(NSDictionary *)params
  responseCallback:(RCTResponseSenderBlock)callback;

- (void)dismiss:(NSDictionary *)params
responseCallback:(RCTResponseSenderBlock)callback;

- (void)hasSeed:(NSDictionary *)params
responseCallback:(RCTResponseSenderBlock)callback;

@end

#endif /* RNHeartbeatToken_h */
