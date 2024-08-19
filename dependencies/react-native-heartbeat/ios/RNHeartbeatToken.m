// Copyright 2022 Topaz

#import <Foundation/Foundation.h>
#import "RCTUtils.h"
#import "RNHeartbeatToken.h"

@interface RNHeartbeatToken()

@property (atomic) RCTResponseSenderBlock callback;

@end

@implementation RNHeartbeatToken

- (void)requestAuthorization:(NSDictionary *)params
            responseCallback:(RCTResponseSenderBlock)callback {
    if (self.callback) return;
    self.callback = callback;

    Token *token = [self getTokenObjectWithParams:params];

    [token requestAuthorization:^ {
        [self finishWithStatusCode:0 andWithMessage:@"Heartbeat.Token.requestAuthorization success"];
    } failure: ^(int statusCode) {
        [self finishWithStatusCode:statusCode andWithMessage:@"Heartbeat.Token.requestAuthorization failure"];
    }];
}

- (void)authorize:(NSString *)code params:(NSDictionary *)params responseCallback:(RCTResponseSenderBlock)callback {
    if (self.callback) return;
    self.callback = callback;

    Token *token = [self getTokenObjectWithParams:params];

    [token authorize:code success:^{
        [self finishWithStatusCode:0 andWithMessage:@"Heartbeat.Token.authorize success"];
    } failure:^(int statusCode) {
        [self finishWithStatusCode:statusCode andWithMessage:@"Heartbeat.Token.authorize failure"];
    }];
}

- (void)getToken:(NSDictionary *)params responseCallback:(RCTResponseSenderBlock)callback {
    if (self.callback) return;
    self.callback = callback;

    Token *token = [self getTokenObjectWithParams:params];

    [token getToken:^(TokenResponse *tokenResponse) {
        NSDictionary *responseObject = @{
            @"token": tokenResponse.token ?: @"",
            @"duration": @(tokenResponse.duration)
        };
        [self finishWithArguments:@[@0, responseObject]];
    } failure:^(int statusCode) {
        [self finishWithStatusCode:statusCode andWithMessage:@"Heartbeat.Token.getToken failure"];
    }];
}

- (void)dismiss:(NSDictionary *)params responseCallback:(RCTResponseSenderBlock)callback {
    if (self.callback) return;
    self.callback = callback;

    Token *token = [self getTokenObjectWithParams:params];

    [token dismiss:^{
        [self finishWithStatusCode:0 andWithMessage:@"Heartbeat.Token.dismiss success"];
    } failure:^(int statusCode) {
        [self finishWithStatusCode:statusCode andWithMessage:@"Heartbeat.Token.dismiss failure"];
    }];
}

- (void)checkToken:(NSDictionary *)params responseCallback:(RCTResponseSenderBlock)callback {
    if (self.callback) return;
    self.callback = callback;

    Token *token = [self getTokenObjectWithParams:params];

    [token checkToken:^{
        [self finishWithStatusCode:0 andWithMessage:@"Heartbeat.Token.checkToken success"];
    } failure:^(int statusCode) {
        [self finishWithStatusCode:statusCode andWithMessage:@"Heartbeat.Token.checkToken failure"];
    }];
}

- (void)hasSeed:(NSDictionary *)params responseCallback:(RCTResponseSenderBlock)callback {
    if (self.callback) return;
    self.callback = callback;

    Token *token = [self getTokenObjectWithParams:params];

    if (token.hasSeed) {
        [self finishWithArguments:@[@YES, @"Hearbeat.Token.hasSeed true"]];
    } else {
        [self finishWithArguments:@[@NO, @"Hearbeat.Token.hasSeed false"]];
    }
}

- (Token *)getTokenObjectWithParams:(NSDictionary *)params {
    Token *token = [Token new];

    for (NSString *key in [params keyEnumerator]) {
        [token addParameter:key value:[params valueForKey:key]];
    }

    return token;
}

- (void)finishWithArguments:(NSArray *)arguments {
    if (!self.callback) return;
    RCTResponseSenderBlock callback = self.callback;
    self.callback = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(arguments);
    });
}

- (void)finishWithStatusCode:(int)statusCode andWithMessage:(NSString *)message{
    if (!self.callback) return;
    RCTResponseSenderBlock callback = self.callback;
    self.callback = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        callback(@[@(statusCode), message]);
    });
}

@end
