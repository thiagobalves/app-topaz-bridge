// Copyright 2022 Topaz

#import <Foundation/Foundation.h>
#import "RNHeartbeatFileSender.h"
#import "RCTUtils.h"

@interface RNHeartbeatFileSender () {
    FileSenderViewController *_fileSenderViewController;
}
@property (atomic) RCTResponseSenderBlock callback;
@end

@implementation RNHeartbeatFileSender

- (void)runWithParams:(NSDictionary *)params
            sendFiles:(RNHeartbeatFileSenderFiles)files
     responseCallback:(RCTResponseSenderBlock)callback {
    self.callback = callback;
    if (@available(iOS 10.0, *)) {
        _fileSenderViewController = [FileSenderViewController new];
        _fileSenderViewController.delegate = self;
        NSDictionary *userParams = [params objectForKey:@"USER_PARAMS"] ?: params;
        _fileSenderViewController.files = files;
        _fileSenderViewController.params = userParams;
        _fileSenderViewController.fileType = [userParams objectForKey:@"TYPE"] ?: @"CNHD";
        if ([params objectForKey:@"MAIN_LABEL"]) {
            _fileSenderViewController.mainLabel = [params objectForKey:@"MAIN_LABEL"];
        }
        [_fileSenderViewController setModalPresentationStyle:UIModalPresentationFullScreen];

        UIViewController *presentingController = RCTKeyWindow().rootViewController;
        if (presentingController == nil) {
            [self finishWithError:-2];
            return;
        }
        
        while(presentingController.presentedViewController) {
            presentingController = presentingController.presentedViewController;
        }
        
        [presentingController presentViewController:_fileSenderViewController animated:YES completion:nil];
    } else {
        [self finishWithError:-1];
    }
}

- (void)finishWithError:(NSInteger)errorStatus {
    [self finishWithResult:@{
        @"OCRRESULTCODE": @(errorStatus)
    }];
}

- (void)finishWithResult:(NSDictionary*)result {
    if (!self.callback) return;
    RCTResponseSenderBlock callback = self.callback;
    self.callback = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(@[
            [NSString stringWithFormat:@"%@", [result objectForKey:@"OCRRESULTCODE"]] ?: @"",
            [result objectForKey:@"OCRRESULT"] ?: @""
        ]);
    });
}

@end
