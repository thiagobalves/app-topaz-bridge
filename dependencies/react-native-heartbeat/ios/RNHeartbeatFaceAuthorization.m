// Copyright 2022 Topaz

#import <Foundation/Foundation.h>
#import "RCTUtils.h"
#import "RCTLog.h"
#import "RNHeartbeatFaceAuthorization.h"

@interface RNHeartbeatFaceAuthorization ()

@property (atomic) RCTResponseSenderBlock callback;
@property (atomic) CameraViewController *cameraViewController;

@end

@implementation RNHeartbeatFaceAuthorization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = OFDCAMERA_LIVENESS;
    }
    return self;
}

- (void)runWithParams:(NSDictionary *)params
     responseCallback:(RCTResponseSenderBlock)callback {
    self.callback = callback;
    if (@available(iOS 10.0, *)) {
        self.cameraViewController = [[CameraViewController alloc] initWithDelegate:self];
        NSDictionary *userParams = [params objectForKey:@"USER_PARAMS"] ?: params;
        if ([params objectForKey:@"TEXT_CAPTIONS"]) {
            self.cameraViewController.textCaptions = [params objectForKey:@"TEXT_CAPTIONS"];
        }
        self.cameraViewController.params = userParams;
        self.cameraViewController.mode = self.type;
        self.cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        UIViewController *presentingController = RCTKeyWindow().rootViewController;
        if(presentingController == nil) {
            [self finishWithError:-2];
            return;
        }
        
        while(presentingController.presentedViewController) {
            presentingController = presentingController.presentedViewController;
        }
        
        [presentingController presentViewController:self.cameraViewController animated:YES completion:nil];
    } else {
        [self finishWithError:-1];
    }
}

- (void)finishWithError:(NSInteger)error {
    [self finishWithResult:@{
        @"FACERESULTCODE": @(error)
    }];
}

- (void)finishWithResult:(NSDictionary *)result {
    if (!self.callback) return;
    RCTResponseSenderBlock callback = self.callback;
    self.callback = nil;
    NSMutableArray *images = [NSMutableArray new];
    if ([result objectForKey:@"FACEIMAGES"]) {
        for (NSData *image in result[@"FACEIMAGES"]) {
            [images addObject:[[NSString alloc] initWithData:[image base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding]];
        }
    }
    if ([result objectForKey:@"FACERESULTCODE"]) {
        NSString *message = [NSString stringWithFormat:@"%d", [result[@"FACERESULTCODE"] intValue]];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(@[
                message,
                [images copy]
            ]);
        });
    }
}

@end
