//
//  ApiHelper.m
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ApiHelper.h"
#import "Url+Param.h"
#import "ExtendNSLogFunctionality.h"

@implementation ApiHelper
/**
 *  用户登录难
 *
 *  @param UID user ID
 *
 *  @return 用户信息
 */
+ (NSMutableDictionary *)login:(NSString *)UID {
    NSString *urlString = [Url login:UID];
    return [self helper:urlString];
}

/**
 *  目录同步,获取某分类下的文档列表
 *
 *  @return 文档列表
 */
+ (NSMutableDictionary *)slides:(NSString *)categoryID DeptID:(NSString *)deptID {
    NSString *urlString = [Url slides:categoryID DeptID:deptID];
    return [self helper:urlString];
}
/**
 *  目录同步,获取某分类下的分类列表
 *
 *  @return 分类列表
 */
+ (NSMutableDictionary *)categories:(NSString *)categoryID DeptID:(NSString *)deptID {
    NSString *urlString = [Url categories:categoryID DeptID:deptID];
    return [self helper:urlString];
}

/**
 *  通知公告列表
 *
 *  @return 数据列表
 */
+ (NSMutableDictionary *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID {
    NSString *urlString = [Url notifications:currentDate DeptID:depthID];
    return [self helper:urlString];
}

#pragma mark - asisstant methods
+ (NSMutableDictionary *)helper:(NSString *)urlString {
    NSDictionary *response = [ApiHelper httpGet:urlString];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(response[HTTP_RESPONSE]) {
        NSError *error;
        dict = [NSJSONSerialization JSONObjectWithData:response[HTTP_RESPONSE]
                                               options:NSJSONReadingAllowFragments
                                                 error:&error];
        BOOL isSuccessfully = NSErrorPrint(error, @"NSData convert to NSDictionary - %@", urlString);
        if(!isSuccessfully) {
            dict[HTTP_ERRORS] = @[(NSString *)psd([error localizedDescription],@"服务器数据转化JSON失败")]; }
    } else {
        dict[HTTP_ERRORS] = response[HTTP_ERRORS];
    }
    return dict;
}
/**
 *  Http#Get功能代码封装
 *
 *  @param path URL Path部分，http://server.com已定义,若要传参直接拼写在Path上
 *
 *  @return Http#Get NSData
 */
+ (NSDictionary *)httpGet:(NSString *)urlString {
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", urlString);
    NSURL *url            = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSError *error;
    NSURLResponse *response;
    NSData *received      = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    BOOL isSuccessfully = NSErrorPrint(error, @"Http#get %@", urlString);
    
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
    NSDictionary *dict;
    if(isSuccessfully && received)
        dict = @{HTTP_RESPONSE:received};
    else
        dict = @{HTTP_ERRORS:@[(NSString *)psd([error localizedDescription], @"http get未知错误")]};
    return dict;
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
