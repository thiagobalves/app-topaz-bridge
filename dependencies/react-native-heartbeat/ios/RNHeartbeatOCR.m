// Copyright 2022 Topaz

#import <Foundation/Foundation.h>
#import "RCTUtils.h"
#import "RCTLog.h"
#import "RNHeartbeatOCR.h"

@interface RNHeartbeatOCR ()

@property (atomic) RCTResponseSenderBlock callback;

@end

@implementation RNHeartbeatOCR

- (void)runWithParams:(NSDictionary *)params
     responseCallback:(RCTResponseSenderBlock)callback {
    self.callback = callback;
    if (@available(iOS 10.0, *)) {
        OCRCameraViewController *ocrCameraViewController = [OCRCameraViewController new];
        ocrCameraViewController.delegate = self;
        NSDictionary *userParams = [params objectForKey:@"USER_PARAMS"] ?: params;
        if ([params objectForKey:@"TEXT_CAPTIONS"]) {
            ocrCameraViewController.textCaptions = [params objectForKey:@"TEXT_CAPTIONS"];
        }
        [ocrCameraViewController setParams:userParams];
        [ocrCameraViewController setLiveCapture:[[params objectForKey:@"LIVECAPTURE"] integerValue] ?: YES];
        [ocrCameraViewController setLandscapeMode:[[params objectForKey:@"LANDSCAPE_MODE"] integerValue] ?: YES];
        [ocrCameraViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        
        UIViewController *presentingController = RCTKeyWindow().rootViewController;
        if(presentingController == nil) {
            [self finishWithError:-2];
            return;
        }
        
        while(presentingController.presentedViewController) {
            presentingController = presentingController.presentedViewController;
        }
        
        [presentingController presentViewController:ocrCameraViewController animated:YES completion:nil];
    } else {
        [self finishWithError:-1];
    }
}

- (void)finishWithError:(NSInteger)errorStatus {
    [self finishWithResult:@{
        @"OCRRESULTCODE": @(errorStatus)
    }];
}

- (void)finishWithResult:(nonnull NSDictionary *)result {
    if (!self.callback) return;
    RCTResponseSenderBlock callback = _callback;
    self.callback = nil;
    long resultCode = [[result objectForKey:@"OCRRESULTCODE"] longValue];
    NSString *message = [NSString stringWithFormat:@"%ld", resultCode];
    NSData *imageBytes = [result objectForKey:@"OCRIMAGE"];
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(@[
            message,
            [result objectForKey:@"OCRRESULT"],
            [[NSString alloc] initWithData:[imageBytes base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding] ?: @""
        ]);
    });
}

@end
