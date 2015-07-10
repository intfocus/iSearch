//
//  Url.m
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "Url.h"
#import "const.h"

@implementation Url

- (Url *)init {
    if(self = [super init]) {
        _base          = BASE_URL;
        _login         = [self concate:LOGIN_URL_PATH];
        _slides        = [self concate:CONTENT_FILE_URL_PATH];
        _categories    = [self concate:CONTENT_URL_PATH];
        _slideDownload = [self concate:CONTENT_DOWNLOAD_URL_PATH];
        _slideList     = [self concate:OFFLINE_URL_PATH];
        _notifications = [self concate:NOTIFICATION_URL_PATH];
        _action        = [self concate:ACTION_LOGGER_URL_PATH];
    }
    return self;
}

#pragma mark - class methods
+ (NSString *)login {
    return [[Url alloc] init].login;
}
+ (NSString *)slides {
    return [[Url alloc] init].slides;
}
+ (NSString *)categories {
    return [[Url alloc] init].categories;
}
+ (NSString *)slideDownload {
    return [[Url alloc] init].slideDownload;
}
+ (NSString *)slideList {
    return [[Url alloc] init].slideList;
}
+ (NSString *)notifications {
    return [[Url alloc] init].notifications;
}
+ (NSString *)action {
    return [[Url alloc] init].action;
}

#pragma mark - asisstant methods
- (NSString *)concate:(NSString *)path {
    NSString *splitStr = ([path hasPrefix:@"/"] ? @"" : @"/");
    return [NSString stringWithFormat:@"%@%@%@", BASE_URL, splitStr, path];
}
@end
