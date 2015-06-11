//
//  HttpUtils.m
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  ViewCommonUtils.m
//  AudioNote
//
//  Created by lijunjie on 15-1-6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  the functions that called more than two pages will put here.

#import "HttpUtils.h"
#import "const.h"

@implementation HttpUtils

+ (NSString *) httpGet: (NSString *) path {
    NSString *str         = [LOGIN_BASE_URL stringByAppendingFormat:@"%@", path];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url            = [NSURL URLWithString:str];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received      = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response    = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    return response;
    
}

+ (NSString *) httpPost: (NSString *) path Data: (NSString *) _data {
    NSString *str         = [LOGIN_BASE_URL stringByAppendingFormat:@"%@", path];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url            = [NSURL URLWithString:str];
    _data = [_data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"POST URL Data: %@", _data);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [_data dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    NSLog(@"POST Response: %@", response);
    return response;
}

+ (NSString *) login: (NSString *) data {
    return [HttpUtils httpPost: LOGIN_URL_PATH Data:data];
}

+ (BOOL) isNetworkAvailable {
    
    BOOL isExistenceNetwork = NO;
    NSString *netWorkType = @"无";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            netWorkType = @"wifi";
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            netWorkType = @"3g";
            break;
    }
    
    return isExistenceNetwork;
}
+ (NSString *) networkType {
    
    BOOL isExistenceNetwork = NO;
    NSString *_netWorkType = @"无";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            _netWorkType = @"wifi";
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            _netWorkType = @"3g";
            break;
    }
    
    return _netWorkType;
}

+ (NSString*)devicePlatform {
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE:  Machine hardware platform: %@", deviceString);
    return deviceString;
}

+ (NSString *) generateUID {
    // name/os/id/osVersion are necessary.
    NSString *device  = [NSString stringWithFormat:@"device={\"name\":\"%@\"", [[UIDevice currentDevice] name]];
    device = [device stringByAppendingFormat:@",\"model\":\"%@\"", [[UIDevice currentDevice] model]];
    device = [device stringByAppendingFormat:@",\"localizedModel\":\"%@\"", [[UIDevice currentDevice] localizedModel]];
    device = [device stringByAppendingFormat:@",\"os\":\"%@\"", [[UIDevice currentDevice] systemName]];
    device = [device stringByAppendingFormat:@",\"id\":\"%@\"", [[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    device = [device stringByAppendingFormat:@",\"osVersion\":\"%@\"", [[UIDevice currentDevice] systemVersion]];
    device = [device stringByAppendingFormat:@",\"platform\":\"%@\"", [HttpUtils devicePlatform]];
    device = [device stringByAppendingString:@"}"];
    /*
    NSString * response = [HttpUtils httpPostDevice: device];
    
    NSMutableDictionary *mutableDictionary2 = [[NSMutableDictionary alloc] init];
    
    // JSON NSString convert to NSMutableDictionary
    
    NSError *error;
    mutableDictionary2 = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    //NSString *idstr = [mutableDictionary2 objectForKey:@"id"];
    NSString *_code = [mutableDictionary2 objectForKey:@"code"];
    NSString *_uid  = [mutableDictionary2 objectForKey:@"info"];
    NSLog(@"code: %@, uid: %@", _code, _uid);
    
    
    // 将上述数据全部存储到 NSUserDefaults 中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_uid forKey:@"uid"];
    // 这里建议同步存储到磁盘中，但是不是必须的
    [userDefaults synchronize];
    
    return _uid;
     */
    return @"uid";
}
@end