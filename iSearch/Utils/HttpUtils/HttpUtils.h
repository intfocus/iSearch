//
//  HttpUtils.h
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//  说明:
//  处理网络相关的代码合集.

#ifndef iSearch_HttpUtils_h
#define iSearch_HttpUtils_h
@class HttpResponse;

@interface HttpUtils : NSObject
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
+ (HttpResponse *)httpGet:(NSString *)urlString;

+ (NSDictionary *)httpGet2:(NSString *)urlString;
/**
 *  Http#Post功能代码封装
 *
 *  @param urlString URL
 *  @param Params    参数，格式param1=value1&param2=value2
 *
 *  @return Http#Post 响应内容
 */
+ (HttpResponse *)httpPost:(NSString *)urlString Params:(NSMutableDictionary *)params;

/**
 *  检测当前app网络环境
 *
 *  @return 有网络则为true
 */
+ (BOOL) isNetworkAvailable;
+ (NSString *) networkType;

@end

#endif
