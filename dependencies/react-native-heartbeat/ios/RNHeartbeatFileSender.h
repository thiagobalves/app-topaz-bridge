// Copyright 2022 Topaz

#ifndef RNHeartbeatFileSender_h
#define RNHeartbeatFileSender_h

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <OFDCamera/OFDCamera.h>

typedef NSArray<NSDictionary<NSString *, NSString *> *> * RNHeartbeatFileSenderFiles;

@interface RNHeartbeatFileSender : NSObject <FileSenderDelegate>

- (void)runWithParams:(NSDictionary *)params
            sendFiles:(RNHeartbeatFileSenderFiles)files
     responseCallback:(RCTResponseSenderBlock)callback;

@end

#endif /* RNHeartbeatFileSender_h */
