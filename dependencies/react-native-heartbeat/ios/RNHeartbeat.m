// Copyright 2022 Topaz

#import "RNHeartbeat.h"
#import "RCTUtils.h"
#import "RCTLog.h"
#import "RNHeartbeatOCR.h"
#import "RNHeartbeatFaceAuthorization.h"
#import "RNHeartbeatFileSender.h"
#import "RNHeartbeatToken.h"
#import <Heartbeat/Heartbeat.h>

@interface RNHeartbeat () {
    RNHeartbeatFaceAuthorization *_heartbeatFaceAuthorization;
    RNHeartbeatOCR *_heartbeatOCR;
    RNHeartbeatFileSender *_heartbeatFileSender;
    RNHeartbeatToken *_heartbeatToken;
}
@end

@implementation RNHeartbeat

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(start:(NSString *)clientId success:(RCTResponseSenderBlock)success fail:(RCTResponseSenderBlock)fail) {
    [Heartbeat start:clientId onSuccess:^(int statusCode) {
        success(@[@(statusCode)]);
    } onFailure:^(int statusCode) {
        fail(@[@(statusCode)]);
    }];
}

RCT_EXPORT_METHOD(sendEvent:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    Event * event = [[Event alloc] init];
    for (NSString * key in [params keyEnumerator]) {
        [event addParameter:key value:[params valueForKey:key]];
    }
    [event sendEvent];
    callback(@[[NSNull null], @"Heartbeat.sendEvent requested"]);
}

RCT_EXPORT_METHOD(getSyncID:(RCTResponseSenderBlock)callback) {
    NSString *syncID = [Heartbeat getSyncID];
    callback(@[syncID]);
}

RCT_EXPORT_METHOD(getCurrentLocation:(NSDictionary *)params success:(RCTResponseSenderBlock)success fail:(RCTResponseSenderBlock)fail) {
    @try {
        [Heartbeat getCurrentLocation:params onSuccess:^(NSString * json) {
            success(@[json]);
        } onFailure:^(int statusCode) {
            fail(@[@(statusCode)]);
        }];
    } @catch(NSException *exception) {
        fail(@[@(-1)]);
    }
}

RCT_EXPORT_METHOD(requestAuthorization:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatToken = [RNHeartbeatToken new];
    [_heartbeatToken requestAuthorization:params responseCallback:callback];
}

RCT_EXPORT_METHOD(authorize:(NSString *)code params:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatToken = [RNHeartbeatToken new];
    [_heartbeatToken authorize:code params:params responseCallback:callback];
}

RCT_EXPORT_METHOD(getToken:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatToken = [RNHeartbeatToken new];
    [_heartbeatToken getToken:params responseCallback:callback];
}

RCT_EXPORT_METHOD(dismiss:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatToken = [RNHeartbeatToken new];
    [_heartbeatToken dismiss:params responseCallback:callback];
}

RCT_EXPORT_METHOD(checkToken:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatToken = [RNHeartbeatToken new];
    [_heartbeatToken checkToken:params responseCallback:callback];
}

RCT_EXPORT_METHOD(hasSeed:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatToken = [RNHeartbeatToken new];
    [_heartbeatToken hasSeed:params responseCallback:callback];
}

RCT_EXPORT_METHOD(startCameraOCR:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatOCR = [RNHeartbeatOCR new];
    [_heartbeatOCR runWithParams:params responseCallback:callback];
}

RCT_EXPORT_METHOD(startLivenessFaceAuthorization:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatFaceAuthorization = [RNHeartbeatFaceAuthorization new];
    [_heartbeatFaceAuthorization runWithParams:params responseCallback:callback];
}

RCT_EXPORT_METHOD(sendDocFaceAuthorization:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    _heartbeatFaceAuthorization = [RNHeartbeatFaceAuthorization new];
    _heartbeatFaceAuthorization.type = OFDCAMERA_CAPTUREDOC;
    [_heartbeatFaceAuthorization runWithParams:params responseCallback:callback];
}

RCT_EXPORT_METHOD(sendFilesOCR:(NSDictionary *)params ocrFilesParameters:(NSArray *)ocrFilesParams callback:(RCTResponseSenderBlock)callback) {
    _heartbeatFileSender = [RNHeartbeatFileSender new];
    [_heartbeatFileSender runWithParams:params sendFiles:ocrFilesParams responseCallback:callback];
}

@end
