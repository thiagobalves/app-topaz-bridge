// Copyright 2022 Topaz

#ifndef RNHeartbeatOCR_h
#define RNHeartbeatOCR_h

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <OFDCamera/OFDCamera.h>
#import <OFDCamera/OCRCameraViewController.h>

@interface RNHeartbeatOCR : NSObject <OCRCameraDelegate>

- (void)runWithParams:(NSDictionary *)params
     responseCallback:(RCTResponseSenderBlock)callback;

@end

#endif /* RNHeartbeatOCR_h */
