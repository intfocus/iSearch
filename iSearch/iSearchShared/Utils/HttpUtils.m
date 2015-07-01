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
#import <UIKit/UIKit.h>
#import "sys/utsname.h"
////https://github.com/tonymillion/Reachability
#import "Reachability.h"
#import "ExtendNSLogFunctionality.h"

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
    NSError *error;
    NSData *received      = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSErrorPrint(error, @"Http#get %@", urlStr);
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
    
    if(response) {
        NSLog(@"POST Response: %@", response);
    } else {
        response = @"No input file specified.";
    }
    return response;
}


/**
 *  检测当前app网络环境
 *
 *  @return 有网络则为true
 */
+ (BOOL) isNetworkAvailable {
    BOOL isExistenceNetwork = NO;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            break;
    }
    
    return isExistenceNetwork;
}
/**
 *  有网络环境时的网络类型
 *
 *  @return 网络类型字符串
 */
+ (NSString *) networkType {
    NSString *_netWorkType = @"无";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWiFi:
            _netWorkType = @"wifi";
            break;
        case ReachableViaWWAN:
            _netWorkType = @"3g";
            break;
    }
    
    return _netWorkType;
}
@end