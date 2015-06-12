//
//  HttpUtils.m
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HttpUtils.h"
#import "const.h"

@interface HttpUtils()

@end

@implementation HttpUtils

/**
 *  Http#Get功能代码封装
 *
 *  @param path URL Path部分，http://server.com已定义,若要传参直接拼写在Path上
 *
 *  @return Http#Get 响应的字符串内容
 */
+ (NSString *) httpGet: (NSString *) path {
    NSString *urlStr = [[NSString alloc] init];
    if([path hasPrefix:@"/"])
        urlStr = [NSString stringWithFormat:@"%@%@", BASE_URL, path];
    else
        urlStr = [BASE_URL stringByAppendingFormat:@"%@", path];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", urlStr);
    NSURL *url            = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received      = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response    = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    return response;
    
}
/**
 *  Http#Post功能代码封装
 *
 *  @param path URL Path部分，http://server.com已定义
 *  @param _data 参数，格式param1=value1&param2=value2
 *
 *  @return Http#Post 响应的字符串内容
 */
+ (NSString *) httpPost: (NSString *) path Data: (NSString *) _data {
    NSString *str         = [BASE_URL stringByAppendingFormat:@"%@", path];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url            = [NSURL URLWithString:str];
    _data = [_data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"POST URL: %@\n Data: %@", str, _data);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *data = [_data dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    if(response)
        NSLog(@"POST Response: %@", response);
    else
        response = @"No input file specified.";
    return response;
}

/**
 *  app登陆时验证用户信息
 *
 *  @param data 验证用户信息的参数, eg: user=username&pwd=password
 *
 *  @return 验证用户结果集: { code: 1, info: {} }, 1为成功，其他为失败
 */
+ (NSString *)login: (NSString *) data {
    return [HttpUtils httpPost: LOGIN_URL_PATH Data:data];
}



/**
 *  检测当前app网络环境
 *
 *  @return 有网络则为true
 */
+ (BOOL) isNetworkAvailable {
    BOOL isExistenceNetwork = NO;
//    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
//    switch ([reach currentReachabilityStatus]) {
//        case NotReachable:
//            break;
//        case ReachableViaWiFi:
//        case ReachableViaWWAN:
//            isExistenceNetwork = YES;
//            break;
//    }
//    
    return isExistenceNetwork;
}
/**
 *  有网络环境时的网络类型
 *
 *  @return 网络类型字符串
 */
+ (NSString *) networkType {
    NSString *_netWorkType = @"无";
//    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
//    switch ([reach currentReachabilityStatus]) {
//        case NotReachable:
//            break;
//        case ReachableViaWiFi:
//            _netWorkType = @"wifi";
//            break;
//        case ReachableViaWWAN:
//            _netWorkType = @"3g";
//            break;
//    }
//    
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

@end