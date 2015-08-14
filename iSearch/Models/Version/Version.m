//
//  SlideUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/22.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sys/utsname.h"
#import "Version.h"

#import "const.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "ExtendNSLogFunctionality.h"

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
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSDictionary *fattributes = [fm attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
        _fileSystemSize     = [fattributes objectForKey:NSFileSystemSize];
        _fileSystemFreeSize = [fattributes objectForKey:NSFileSystemFreeSize];
        
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

- (void)setLatest:(NSString *)latest {
    if(![self.latest isEqualToString:latest]) {
        _latest = latest;
        [self save];
    }
}

- (NSString *)simpleDescription {
    return [NSString stringWithFormat:@"<#%@ version: %@, dbVersion:%@, machine: %@(%@), sdkName: %@, lang: %@>", self.appName,self.current,self.dbVersion, [self machine], [self machineHuman], self.sdkName,self.lang];
}

- (NSString *)machine {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)machineHuman {
    NSString *device = [self machine];
    NSString *human = device;
    
    if ([device isEqualToString:@"x86_64"])     human = @"Simulator";
    else if ([device isEqualToString:@"i386"])  human = @"Simulator";
    
    else if ([device isEqualToString:@"iPad1,1"]) human = @"iPad";
    else if ([device isEqualToString:@"iPad2,1"]) human = @"iPad 2 (A1395)";
    else if ([device isEqualToString:@"iPad2,2"]) human = @"iPad 2 (A1396)";
    else if ([device isEqualToString:@"iPad2,3"]) human = @"iPad 2 (A1397)";
    else if ([device isEqualToString:@"iPad2,4"]) human = @"iPad 2 (A1395+NewChip)";
    else if ([device isEqualToString:@"iPad2,5"]) human = @"iPad Mini 1G (A1432)";
    else if ([device isEqualToString:@"iPad2,6"]) human = @"iPad Mini 1G (A1454)";
    else if ([device isEqualToString:@"iPad2,7"]) human = @"iPad Mini 1G (A1455)";
    
    else if ([device isEqualToString:@"iPad3,1"]) human = @"iPad 3 (A1416)";
    else if ([device isEqualToString:@"iPad3,2"]) human = @"iPad 3 (A1403)";
    else if ([device isEqualToString:@"iPad3,3"]) human = @"iPad 3 (A1430)";
    else if ([device isEqualToString:@"iPad3,4"]) human = @"iPad 4 (A1458)";
    else if ([device isEqualToString:@"iPad3,5"]) human = @"iPad 4 (A1459)";
    else if ([device isEqualToString:@"iPad3,6"]) human = @"iPad 4 (A1460)";
    
    else if ([device isEqualToString:@"iPad4,1"]) human = @"iPad Air (A1474)";
    else if ([device isEqualToString:@"iPad4,2"]) human = @"iPad Air (A1475)";
    else if ([device isEqualToString:@"iPad4,3"]) human = @"iPad Air (A1476)";
    else if ([device isEqualToString:@"iPad4,4"]) human = @"iPad Mini 2G (A1489)";
    else if ([device isEqualToString:@"iPad4,5"]) human = @"iPad Mini 2G (A1490)";
    else if ([device isEqualToString:@"iPad4,6"]) human = @"iPad Mini 2G (A1491)";
    
    else if ([device isEqualToString:@"iPhone1,1"]) human = @"iPhone 1G";
    else if ([device isEqualToString:@"iPhone1,2"]) human = @"iPhone 3G";
    else if ([device isEqualToString:@"iPhone2,1"]) human = @"iPhone 3GS";
    else if ([device isEqualToString:@"iPhone3,1"]) human = @"iPhone 4";
    else if ([device isEqualToString:@"iPhone4,1"]) human = @"iPhone 4S";
    else if ([device isEqualToString:@"iPhone5,2"]) human = @"iPhone 5";
    else if ([device isEqualToString:@"iPhone3,2"]) human = @"Verizon iPhone 4";
    
    else if ([device isEqualToString:@"iPod1,1"]) human = @"iPod Touch 1G";
    else if ([device isEqualToString:@"iPod2,1"]) human = @"iPod Touch 2G";
    else if ([device isEqualToString:@"iPod3,1"]) human = @"iPod Touch 3G";
    else if ([device isEqualToString:@"iPod4,1"]) human = @"iPod Touch 4G";
    
    return human;
}
+ (NSString *)pgy_app_id {
    return PGY_APP_ID;
}
@end