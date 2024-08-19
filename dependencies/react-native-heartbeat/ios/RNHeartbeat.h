// Copyright 2022 Topaz

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

@interface RNHeartbeat : NSObject <RCTBridgeModule>

@end
