//
//  SlideUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/22.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Version.h"

#import "const.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "AFNetworking.h"
#import "ExtendNSLogFunctionality.h"

@implementation Version

- (Version *)init {
    if(self = [super init]) {
        NSDictionary *localVersionInfo =[[NSBundle mainBundle] infoDictionary];
        _current  = localVersionInfo[@"CFBundleShortVersionString"];
        _appName  = localVersionInfo[@"CFBundleExecutable"];
        _lang     = localVersionInfo[@"CFBundleDevelopmentRegion"];
        _suport   = localVersionInfo[@"MinimumOSVersion"];
        _platform = localVersionInfo[@"DTSDKName"];
        _sdkName  = localVersionInfo[@"DTPlatformName"];
    
        [self reload];
        [self updateTimestamp];
    }
    return self;
}

- (void)updateTimestamp {
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];;
    if(!self.localCreatedDate) { _localCreatedDate = timestamp; }
    _localUpdatedDate = timestamp;
}

- (void)checkUpdate:(void(^)())successBlock FailBloc:(void(^)())failBlock {
    NSString *versionInfoUrl = [NSString stringWithFormat:@"http://fir.im/api/v2/app/version/%@",FIRIM_APP_ID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"token": FIRIM_USER_TOKEN};
    [manager GET:versionInfoUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _latest = responseObject[FIRIM_VERSION];
        
        if([self isUpgrade]) {
            _insertURL = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", responseObject[FIRIM_INSTALL_URL]];
            _changeLog = responseObject[FIRIM_CHANGE_LOG];

            [self updateTimestamp];
            [self save];
            
            successBlock();
        } else {
            NSLog(@"lastestVersion: %@, current version: %@", self.latest, self.current);
            failBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        failBlock();
    }];
}

- (BOOL)isUpgrade {
    return ![self.latest isEqualToString:self.current] && ![self.latest containsString:self.current];
}

- (void)reload {
    NSString *configPath = [[FileUtils getBasePath] stringByAppendingPathComponent:UPGRADE_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    _latest    = configDict[FIRIM_VERSION];
    _insertURL = configDict[FIRIM_INSTALL_URL];
    _changeLog = configDict[FIRIM_CHANGE_LOG];
}
- (void)save {
    NSString *configPath = [[FileUtils getBasePath] stringByAppendingPathComponent:UPGRADE_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    configDict[FIRIM_CHANGE_LOG]    = self.changeLog;
    configDict[FIRIM_VERSION]       = self.latest;
    configDict[FIRIM_INSTALL_URL]   = self.insertURL;
    configDict[SLIDE_DESC_LOCAL_CREATEAT] = self.localCreatedDate;
    configDict[SLIDE_DESC_LOCAL_UPDATEAT] = self.localUpdatedDate;
    
    [FileUtils writeJSON:configDict Into:configPath];
}
#pragma mark -

@end