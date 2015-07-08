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
#define VERSION_URL @"https://tems.takeda.com.cn/iSearch/iSearch.plist"

@implementation Version

- (Version *)init {
    if(self = [super init]) {
        NSDictionary *localVersionInfo =[[NSBundle mainBundle] infoDictionary];
        _current   = localVersionInfo[@"CFBundleShortVersionString"];
        _appName   = localVersionInfo[@"CFBundleExecutable"];
        _lang      = localVersionInfo[@"CFBundleDevelopmentRegion"];
        _suport    = localVersionInfo[@"MinimumOSVersion"];
        _sdkName   = localVersionInfo[@"DTSDKName"];
        _platform  = localVersionInfo[@"DTPlatformName"];
        _dbVersion = (NSString *)psd(localVersionInfo[@"Database Version"], @"NotSet");
        
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:VERSION_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData* plistData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *error;
        NSPropertyListFormat format;
        NSDictionary* plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
        _latest = plist[@"items"][0][@"metadata"][@"version"];
        
        if([self isUpgrade]) {
            _insertURL = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", VERSION_URL];
            NSString *changLog = plist[@"items"][0][@"metadata"][@"changelog"];
            _changeLog = changLog ? _changeLog : @"未设置";
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
    return self.latest && ![self.latest isEqualToString:self.current];
}

- (void)reload {
    NSString *configPath = [[FileUtils getBasePath] stringByAppendingPathComponent:UPGRADE_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    _latest    = configDict[VERSION_LATEST];
    _insertURL = configDict[VERSION_INSERTURL];
    _changeLog = configDict[VERSION_CHANGELOG];
}
- (void)save {
    NSString *configPath = [[FileUtils getBasePath] stringByAppendingPathComponent:UPGRADE_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    configDict[VERSION_CHANGELOG]   = self.changeLog;
    configDict[VERSION_LATEST]      = self.latest;
    configDict[VERSION_INSERTURL]   = self.insertURL;
    configDict[SLIDE_DESC_LOCAL_CREATEAT] = self.localCreatedDate;
    configDict[SLIDE_DESC_LOCAL_UPDATEAT] = self.localUpdatedDate;
    
    [FileUtils writeJSON:configDict Into:configPath];
}
#pragma mark -

@end