// Copyright 2022 Topaz

#ifndef RNHeartbeatFaceAuthorization_h
#define RNHeartbeatFaceAuthorization_h

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <OFDCamera/OFDCamera.h>
#import <OFDCamera/CameraViewController.h>

@interface RNHeartbeatFaceAuthorization : NSObject <OFDCameraDelegate>

@property (nonatomic) ModeTypes type;

- (void)runWithParams:(NSDictionary *)params
     responseCallback:(RCTResponseSenderBlock)callback;

@end

#endif /* RNHeartbeatFaceAuthorization_h */
