//
//  ApiUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApiUtils.h"

#import "const.h"
#import "User.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "HttpUtils.h"
#import "AFNetworking.h"
#import "ExtendNSLogFunctionality.h"

@interface ApiUtils()

@end
@implementation ApiUtils

+ (NSString *)loginUrl:(NSString *)cookieValue {
   return [NSString stringWithFormat:@"%@?%@=%@&%@=%@", LOGIN_URL_PATH, PARAM_LANG, APP_LANG, LOGIN_PARAM_UID, cookieValue];
}
+ (NSURL *)downloadSlideURL:(NSString *)slideID {
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@=%@",
            BASE_URL, CONTENT_DOWNLOAD_URL_PATH, CONTENT_PARAM_FILE_DWONLOADID, slideID];
    NSLog(@"%@", urlString);
    return [NSURL URLWithString:urlString];
}

+ (NSMutableDictionary *)notifications {
    NSMutableDictionary *notificationDatas = [[NSMutableDictionary alloc] init];
    // 服务器获取成功则写入cache,否则读取cache
    NSString *cachePath = [FileUtils getPathName:NOTIFICATION_DIRNAME FileName:NOTIFICATION_CACHE];
    
    //无网络，则直接读取缓存
    if(![HttpUtils isNetworkAvailable]) {
        if([FileUtils checkFileExist:cachePath isDir:false]) {
            // 读取本地cache
            notificationDatas = [FileUtils readConfigFile:cachePath];
        }
        return notificationDatas;
    }
    
    // 从服务器端获取[公告通知]
    User *user = [[User alloc] init];
    NSString *currentDate = [DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT];
    NSString *notifiction_url = [NSString stringWithFormat:@"%@?%@=%@&%@=%@", NOTIFICATION_URL_PATH, NOTIFICATION_PARAM_DEPTID, user.deptID, NOTIFICATION_PARAM_DATESTR, currentDate];
    
    NSString *response = [HttpUtils httpGet: notifiction_url];
    NSError *error;
    // 确保该实例可以被读取
    notificationDatas = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSErrorPrint(error, @"http get notifications and convert into json.");
    
    // 情况一: 服务器获取公告通知成功
    if(!error) {
        // 写入本地作为cache
        [FileUtils writeJSON:notificationDatas Into:cachePath];
        
        // 情况二: 如果缓存文件存在则读取
    } else if([FileUtils checkFileExist:cachePath isDir:false]) {
        // 读取本地cache
        notificationDatas = [FileUtils readConfigFile:cachePath];
        // 情况三:
    } else {
        NSLog(@"<# HttpGET and cache all failed!>");
    }
    return notificationDatas;
}

+ (NSString *)postActionLog:(NSMutableDictionary *) params {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [ApiUtils apiUrl:ACTION_LOGGER_URL_PATH];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    return @"";
}

+ (NSString *)apiUrl:(NSString *)path {
    NSString *url;
    if([path hasPrefix:@"/"])
        url = [NSString stringWithFormat:@"%@%@", BASE_URL, path];
    else
        url = [BASE_URL stringByAppendingFormat:@"%@", path];
    return url;
}

+ (NSDictionary *) GET {
    __block NSDictionary* response = nil;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [manager GET: @"http://tsa-china.takeda.com.cn/uat/api/Categories_Api.php?lang=zh-CN&did=150&pid=1"
                                          parameters: [NSDictionary dictionary]
                                             success:^(AFHTTPRequestOperation* operation, id responseObject){
                                                 response = responseObject;
                                                 NSLog(@"response (block): %@", response);
                                                 dispatch_semaphore_signal(semaphore);
                                             }
                                             failure:^(AFHTTPRequestOperation* operation, NSError* error){
                                                 NSLog(@"Error: %@", error);
                                                 dispatch_semaphore_signal(semaphore);
                                             }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"response: %@", response);
    return response;
}

+ (NSDictionary *) POST:(NSString *)url Param:(NSMutableDictionary *)parameters {
    __block NSDictionary* response = nil;
    __block NSError* error = nil;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [manager POST: url
      parameters: [NSDictionary dictionaryWithDictionary:parameters]
         success:^(AFHTTPRequestOperation* operation, id responseObject){
             response = responseObject;
             NSLog(@"response (block): %@", response);
             dispatch_semaphore_signal(semaphore);
         }
         failure:^(AFHTTPRequestOperation* operation, NSError* responseError){
             error = responseError;
             NSLog(@"Error: %@", responseError);
             dispatch_semaphore_signal(semaphore);
         }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"response: %@", response);
    return response;
}
@end