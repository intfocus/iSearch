//
//  ApiHelper.m
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ApiHelper.h"
#import "Url+Param.h"
#import "HttpResponse.h"
#import "ExtendNSLogFunctionality.h"

@implementation ApiHelper
/**
 *  用户登录难
 *
 *  @param UID user ID
 *
 *  @return 用户信息
 */
+ (HttpResponse *)login:(NSString *)UID {
    NSString *urlString = [Url login:UID];
    return [self httpGet:urlString];
}

/**
 *  目录同步,获取某分类下的文档列表
 *
 *  @return 文档列表
 */
+ (HttpResponse *)slides:(NSString *)categoryID DeptID:(NSString *)deptID {
    NSString *urlString = [Url slides:categoryID DeptID:deptID];
    return [self httpGet:urlString];
}
/**
 *  目录同步,获取某分类下的分类列表
 *
 *  @return 分类列表
 */
+ (HttpResponse *)categories:(NSString *)categoryID DeptID:(NSString *)deptID {
    NSString *urlString = [Url categories:categoryID DeptID:deptID];
    return [self httpGet:urlString];
}

/**
 *  通知公告列表
 *
 *  @return 数据列表
 */
+ (HttpResponse *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID {
    NSString *urlString = [Url notifications:currentDate DeptID:depthID];
    return [self httpGet:urlString];
}

#pragma mark - asisstant methods
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
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", urlString);
    NSURL *url            = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3];
    NSError *error;
    NSURLResponse *response;
    httpResponse.received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    BOOL isSuccessfully   = NSErrorPrint(error, @"Http#get %@", urlString);
    
    if (isSuccessfully && DEBUG) {
        NSString *mimeType = [response.MIMEType lowercaseString];
        NSString *encodingName = [response.textEncodingName lowercaseString];
        if(![mimeType isEqualToString:@"application/json"]) {
            NSLog(@"%@ mimeType not application/json but %@", urlString, mimeType);
        }
        if(![encodingName isEqualToString:@"utf-8"]) {
            NSLog(@"%@ encodingName not utf-8 but %@", urlString, encodingName);
        }
    }
    if(isSuccessfully && httpResponse.received)
        httpResponse.data = [NSJSONSerialization JSONObjectWithData:httpResponse.received options:NSJSONReadingAllowFragments error:&error];
        isSuccessfully = NSErrorPrint(error, @"NSData convert to NSDictionary - %@", urlString);
        if(!isSuccessfully) {
             [httpResponse.errors addObject:(NSString *)psd([error localizedDescription],@"服务器数据转化JSON失败")];
        }
    
    else
        [httpResponse.errors addObject:(NSString *)psd([error localizedDescription], @"http get未知错误")];
    return httpResponse;
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
@end
