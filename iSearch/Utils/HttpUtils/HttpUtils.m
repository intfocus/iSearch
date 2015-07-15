//
//  HttpUtils.m
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sys/utsname.h"
#import "HttpUtils.h"
#import "const.h"
#import "HttpResponse.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ExtendNSLogFunctionality.h"

@interface HttpUtils()

@end

@implementation HttpUtils


/**
 *  Http#Get功能代码封装
 *
 *  服务器响应处理:
 *  dict{HTTP_ERRORS, HTTP_RESPONSE, HTTP_RESONSE_DATA}
 *  HTTP_ERRORS: 与服务器交互中出现错误，此值不空时，不需再使用其他值
 *  HTTP_RESPONSE: 服务器响应的内容
 *  HTTP_RESPOSNE_DATA: 服务器响应内容转化为NSDictionary
 *
 *  @return Http#Get HttpResponse
 */
+ (HttpResponse *)httpGet:(NSString *)urlString {
    HttpResponse *httpResponse = [[HttpResponse alloc] init];
    NSLog(@"%@", urlString);
    NSURL *url            = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    NSError *error;
    NSURLResponse *response;
    httpResponse.received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    httpResponse.response = response;
    BOOL isOK   = NSErrorPrint(error, @"Http#get %@", urlString);
    if(!isOK) {
        [httpResponse.errors addObject:(NSString *)psd([error localizedDescription], @"http get未知错误")];
    }

    return httpResponse;
}
/**
 *  Http#Post功能代码封装
 *  application/x-www-form-urlencoded
 *
 *  @param urlString URL
 *  @param Params    参数，格式param1=value1&param2=value2
 *
 *  @return Http#Post 响应内容
 */
+ (HttpResponse *)httpPost:(NSString *)urlString Params:(NSMutableDictionary *)params {
    urlString  = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    //params     = [params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error: &error];
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    [request setHTTPBody:tempJsonData];
    
    NSURLResponse *response;
    HttpResponse *httpResponse = [[HttpResponse alloc] init];
    httpResponse.received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    httpResponse.response = (NSHTTPURLResponse *)response;
    BOOL isOK   = NSErrorPrint(error, @"Http#post %@", urlString);
    if(!isOK) {
        [httpResponse.errors addObject:(NSString *)psd([error localizedDescription], @"http get未知错误")];
    }


    return httpResponse;
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